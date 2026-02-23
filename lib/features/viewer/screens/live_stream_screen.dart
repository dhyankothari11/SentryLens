import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class LiveStreamScreen extends StatefulWidget {
  final String deviceId;
  const LiveStreamScreen({super.key, required this.deviceId});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen>
    with TickerProviderStateMixin {
  bool _isConnecting = true;
  bool _showControls = true;
  bool _isFullscreen = false;
  String _latency = '< 1s';
  Timer? _hideControlsTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  final Map<String, String> _deviceNames = {
    'front_door': 'Front Door',
    'living_room': 'Living Room',
    'garage': 'Garage',
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _scanAnimation = CurvedAnimation(
      parent: _scanController,
      curve: Curves.linear,
    );

    // Simulate connecting
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _isConnecting = false);
      _scheduleHideControls();
    });
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _onTap() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleHideControls();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    final deviceName = _deviceNames[widget.deviceId] ?? 'Camera';

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onTap,
        child: Stack(
          children: [
            // Stream feed
            if (_isConnecting)
              _buildConnectingState()
            else
              AnimatedBuilder(
                animation: _scanAnimation,
                builder: (_, __) => CustomPaint(
                  painter: _StreamPainter(_scanAnimation.value),
                  size: Size.infinite,
                ),
              ),

            // LIVE indicator
            if (!_isConnecting)
              Positioned(
                top: 48,
                right: 20,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (_, child) =>
                      Opacity(opacity: _pulseAnimation.value, child: child),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 6),
                        SizedBox(width: 5),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Top controls
            if (_showControls)
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.edgeToEdge,
                              );
                              context.pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                deviceName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Latency $_latency',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Screenshot
                          _StreamControl(
                            icon: Icons.camera_alt_outlined,
                            onTap: () => HapticFeedback.lightImpact(),
                          ),
                          const SizedBox(width: 8),
                          // Fullscreen
                          _StreamControl(
                            icon: _isFullscreen
                                ? Icons.fullscreen_exit_rounded
                                : Icons.fullscreen_rounded,
                            onTap: () =>
                                setState(() => _isFullscreen = !_isFullscreen),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom info bar
            if (_showControls && !_isConnecting)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 36),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.videocam_rounded,
                          color: Colors.white54,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          deviceName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.signal_wifi_4_bar_rounded,
                                color: AppColors.success,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'HD • 1080p',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectingState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, child) =>
                  Opacity(opacity: _pulseAnimation.value, child: child),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.videocam_rounded,
                  color: AppColors.accent,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Connecting to stream...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            const SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                color: AppColors.accent,
                backgroundColor: Colors.white12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreamControl extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StreamControl({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _StreamPainter extends CustomPainter {
  final double progress;
  final Random _rng = Random(7);
  _StreamPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0A0F1A),
    );

    // Scan line
    final scanY = progress * size.height;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          AppColors.accent.withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, scanY - 30, size.width, 60));
    canvas.drawRect(Rect.fromLTWH(0, scanY - 30, size.width, 60), scanPaint);

    // Grid overlay
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Simulated moving elements
    final objPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    final animX =
        (progress * size.width * 0.3 + size.width * 0.3) % (size.width * 0.6) +
        size.width * 0.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(animX, size.height * 0.5),
          width: 40,
          height: 90,
        ),
        const Radius.circular(4),
      ),
      objPaint,
    );

    // Noise
    final noise = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 80; i++) {
      noise.color = Colors.white.withValues(alpha: _rng.nextDouble() * 0.02);
      canvas.drawCircle(
        Offset(
          _rng.nextDouble() * size.width,
          (_rng.nextDouble() + progress) % 1.0 * size.height,
        ),
        0.8,
        noise,
      );
    }
  }

  @override
  bool shouldRepaint(_StreamPainter old) => old.progress != progress;
}
