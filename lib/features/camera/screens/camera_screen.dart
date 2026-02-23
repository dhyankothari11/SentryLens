import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _isMotionDetected = false;
  bool _isAudioEnabled = true;
  bool _isNightMode = false;
  double _sensitivity = 0.5;
  String _status = 'STANDBY';
  Timer? _motionTimer;
  Timer? _simulationTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _borderController;
  late Animation<double> _borderAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _borderController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _borderController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // Simulate motion detection every 8 seconds for demo
    _simulationTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted && _status != 'STANDBY') _triggerMotion();
    });
  }

  void _triggerMotion() {
    setState(() {
      _isMotionDetected = true;
      _status = 'DETECTING';
    });
    _borderController.forward();
    HapticFeedback.heavyImpact();
    _motionTimer?.cancel();
    _motionTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isMotionDetected = false;
          _status = _isRecording ? 'LIVE' : 'STANDBY';
        });
        _borderController.reverse();
      }
    });
  }

  Color get _statusColor {
    switch (_status) {
      case 'LIVE':
        return AppColors.accent;
      case 'DETECTING':
        return AppColors.accent;
      case 'STANDBY':
      default:
        return AppColors.success;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _borderController.dispose();
    _fadeController.dispose();
    _motionTimer?.cancel();
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Simulated camera feed
            _CameraPreviewSimulator(isNightMode: _isNightMode),

            // Motion detection border flash
            AnimatedBuilder(
              animation: _borderAnimation,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.accent.withValues(
                      alpha: _borderAnimation.value * 0.8,
                    ),
                    width: 4,
                  ),
                ),
              ),
            ),

            // Top HUD
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(context),
                  const Spacer(),
                  // Motion alert banner
                  if (_isMotionDetected) _buildMotionBanner(),
                  // Bottom controls
                  _buildBottomPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () => context.goNamed('mode-select'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Device name
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.videocam_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Camera Device',
                    style: AppTheme.dark.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Status pill
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, child) => Opacity(
              opacity: _status == 'LIVE' || _status == 'DETECTING'
                  ? _pulseAnimation.value
                  : 1.0,
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _statusColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _status,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotionBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.accent,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            'Motion Detected!',
            style: AppTheme.dark.textTheme.bodyMedium?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            'Now',
            style: AppTheme.dark.textTheme.bodySmall?.copyWith(
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sensitivity slider
          Row(
            children: [
              const Icon(
                Icons.sensors_rounded,
                color: AppColors.textMuted,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text('Sensitivity', style: AppTheme.dark.textTheme.bodySmall),
              const Spacer(),
              Text(
                '${(_sensitivity * 100).toInt()}%',
                style: AppTheme.dark.textTheme.bodySmall?.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: AppColors.accent,
              overlayColor: AppColors.accent.withValues(alpha: 0.1),
              trackHeight: 3,
            ),
            child: Slider(
              value: _sensitivity,
              onChanged: (v) => setState(() => _sensitivity = v),
            ),
          ),
          const SizedBox(height: 12),
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ControlButton(
                icon: _isRecording
                    ? Icons.stop_rounded
                    : Icons.fiber_manual_record_rounded,
                label: _isRecording ? 'Stop' : 'Record',
                color: AppColors.accent,
                isActive: _isRecording,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _isRecording = !_isRecording;
                    _status = _isRecording ? 'LIVE' : 'STANDBY';
                  });
                },
              ),
              _ControlButton(
                icon: _isAudioEnabled
                    ? Icons.mic_rounded
                    : Icons.mic_off_rounded,
                label: 'Audio',
                color: AppColors.info,
                isActive: _isAudioEnabled,
                onTap: () => setState(() => _isAudioEnabled = !_isAudioEnabled),
              ),
              _ControlButton(
                icon: Icons.motion_photos_on_rounded,
                label: 'Test',
                color: AppColors.warning,
                isActive: false,
                onTap: _triggerMotion,
              ),
              _ControlButton(
                icon: _isNightMode
                    ? Icons.nightlight_round
                    : Icons.wb_sunny_rounded,
                label: 'Night',
                color: AppColors.success,
                isActive: _isNightMode,
                onTap: () => setState(() => _isNightMode = !_isNightMode),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isActive
                  ? color.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? color.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? color : Colors.white60,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraPreviewSimulator extends StatefulWidget {
  final bool isNightMode;
  const _CameraPreviewSimulator({required this.isNightMode});

  @override
  State<_CameraPreviewSimulator> createState() =>
      _CameraPreviewSimulatorState();
}

class _CameraPreviewSimulatorState extends State<_CameraPreviewSimulator>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    _scanAnimation = CurvedAnimation(
      parent: _scanController,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isNightMode
        ? const Color(0xFF0A1628)
        : const Color(0xFF111827);
    return Container(
      color: bgColor,
      child: AnimatedBuilder(
        animation: _scanAnimation,
        builder: (_, __) => CustomPaint(
          painter: _CameraFeedPainter(_scanAnimation.value, widget.isNightMode),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _CameraFeedPainter extends CustomPainter {
  final double progress;
  final bool isNightMode;
  final Random _rng = Random(42);

  _CameraFeedPainter(this.progress, this.isNightMode);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw scan line
    final scanY = progress * size.height;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          (isNightMode ? AppColors.success : AppColors.accent).withValues(
            alpha: 0.3,
          ),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, scanY - 40, size.width, 80));
    canvas.drawRect(Rect.fromLTWH(0, scanY - 40, size.width, 80), scanPaint);

    // Draw corner brackets (camera frame)
    final bracketPaint = Paint()
      ..color = (isNightMode ? AppColors.success : Colors.white).withValues(
        alpha: 0.3,
      )
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const bSize = 24.0;
    const margin = 40.0;
    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(margin, margin + bSize)
        ..lineTo(margin, margin)
        ..lineTo(margin + bSize, margin),
      bracketPaint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - margin - bSize, margin)
        ..lineTo(size.width - margin, margin)
        ..lineTo(size.width - margin, margin + bSize),
      bracketPaint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(margin, size.height - margin - bSize)
        ..lineTo(margin, size.height - margin)
        ..lineTo(margin + bSize, size.height - margin),
      bracketPaint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - margin - bSize, size.height - margin)
        ..lineTo(size.width - margin, size.height - margin)
        ..lineTo(size.width - margin, size.height - margin - bSize),
      bracketPaint,
    );

    // Noise grain effect
    final grainPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 120; i++) {
      final x = _rng.nextDouble() * size.width;
      final y = (_rng.nextDouble() + progress) % 1.0 * size.height;
      grainPaint.color = Colors.white.withValues(
        alpha: _rng.nextDouble() * 0.03,
      );
      canvas.drawCircle(Offset(x, y), 1, grainPaint);
    }

    // Night mode green tint
    if (isNightMode) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = AppColors.success.withValues(alpha: 0.05),
      );
    }
  }

  @override
  bool shouldRepaint(_CameraFeedPainter old) =>
      old.progress != progress || old.isNightMode != isNightMode;
}
