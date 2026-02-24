import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  String? _roomId;
  Timer? _heartbeatTimer;

  // Stream controllers to notify UI of stream state changes
  final _localStreamController = StreamController<MediaStream?>.broadcast();
  final _remoteStreamController = StreamController<MediaStream?>.broadcast();
  final _connectionStateController =
      StreamController<RTCPeerConnectionState>.broadcast();

  Stream<MediaStream?> get localStreamStream => _localStreamController.stream;
  Stream<MediaStream?> get remoteStreamStream => _remoteStreamController.stream;
  Stream<RTCPeerConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  String? get roomId => _roomId;

  // STUN/TURN servers
  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
    ],
  };

  Future<void> initLocalStream() async {
    final mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth':
              '640', // ResolutionPreset.medium roughly matches 480p/720p
          'minHeight': '480',
          'minFrameRate': '15',
        },
        'facingMode': 'environment', // Back camera
      },
    };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(
        mediaConstraints,
      );
      _localStreamController.add(_localStream);
      debugPrint('Local stream initialized successfully.');
    } catch (e) {
      debugPrint('Error accessing local media: $e');
      rethrow;
    }
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_configuration);

    // Add local tracks to peer connection
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
    }

    // Listen for remote remote tracks
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      debugPrint('Received remote track: ${event.track.kind}');
      if (event.track.kind == 'video' && event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        _remoteStreamController.add(_remoteStream);
      }
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('PeerConnectionState: $state');
      _connectionStateController.add(state);
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('ICE Connection State: $state');
    };
  }

  /// Called by the CAMERA device
  /// Creates a room, sets the local offer, and waits for a viewer to answer
  Future<String> createRoom() async {
    if (_auth.currentUser == null) throw Exception('User not authenticated');
    final userId = _auth.currentUser!.uid;

    await _createPeerConnection();

    // The document where we will store the offer/answer signaling data
    final roomRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('rooms')
        .doc();
    _roomId = roomRef.id;
    debugPrint('Created room with ID: $_roomId');

    // Add local ICE candidates to Firestore as they are generated
    final callerCandidatesRef = roomRef.collection('callerCandidates');
    _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate != null) {
        callerCandidatesRef.add(candidate.toMap());
      }
    };

    // Create SDP Offer
    final RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    await roomRef.set({
      'offer': offer.toMap(),
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Listen for the viewer's Answer
    roomRef.snapshots().listen((snapshot) async {
      if (!snapshot.exists) return;
      final data = snapshot.data() as Map<String, dynamic>;
      if (_peerConnection?.getRemoteDescription() != null) return;

      if (data.containsKey('answer')) {
        debugPrint('Got answer from viewer. Setting remote description.');
        final answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );
        await _peerConnection!.setRemoteDescription(answer);
        await roomRef.update({'status': 'connected'});
      }
    });

    // Listen for viewer's ICE Candidates
    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          _peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      }
    });

    // Keep room alive
    _startHeartbeat(roomRef);

    return _roomId!;
  }

  /// Called by the VIEWER device
  /// Joins an existing room using the roomId and generates an answer
  Future<void> joinRoom(String ownerId, String roomId) async {
    _roomId = roomId;
    final roomRef = _firestore
        .collection('users')
        .doc(ownerId)
        .collection('rooms')
        .doc(roomId);

    final roomSnapshot = await roomRef.get();
    if (!roomSnapshot.exists) {
      throw Exception('Room not found or camera offline');
    }

    await _createPeerConnection();

    // Send our ICE candidates to the Camera
    final calleeCandidatesRef = roomRef.collection('calleeCandidates');
    _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate != null) {
        calleeCandidatesRef.add(candidate.toMap());
      }
    };

    // Set Remote Description (Camera's offer)
    final data = roomSnapshot.data() as Map<String, dynamic>;
    final offer = data['offer'];
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );

    // Create SDP Answer and send to Camera
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    await roomRef.update({'answer': answer.toMap()});

    // Listen for Camera's ICE Candidates
    roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          _peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      }
    });
  }

  void _startHeartbeat(DocumentReference roomRef) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      try {
        roomRef.update({'lastPing': FieldValue.serverTimestamp()});
      } catch (e) {
        debugPrint('Heartbeat failed: $e');
      }
    });
  }

  Future<void> hangUp() async {
    _heartbeatTimer?.cancel();
    _localStream?.getTracks().forEach((track) => track.stop());
    _remoteStream?.getTracks().forEach((track) => track.stop());

    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _peerConnection?.close();

    _localStream = null;
    _remoteStream = null;
    _peerConnection = null;

    if (_roomId != null && _auth.currentUser != null) {
      final userId = _auth.currentUser!.uid;
      final roomRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('rooms')
          .doc(_roomId);

      try {
        await roomRef.delete();
      } catch (e) {
        debugPrint('Failed to delete room: $e');
      }
      _roomId = null;
    }
  }
}

final webRTCServiceProvider = Provider<WebRTCService>((ref) {
  final service = WebRTCService();
  ref.onDispose(() => service.hangUp());
  return service;
});
