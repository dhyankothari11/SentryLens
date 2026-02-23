import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/onboarding/mode_selection_screen.dart';
import '../../features/camera/screens/camera_screen.dart';
import '../../features/viewer/screens/viewer_dashboard_screen.dart';
import '../../features/viewer/screens/live_stream_screen.dart';
import '../../features/events/event_timeline_screen.dart';
import '../../features/devices/device_management_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../theme/app_colors.dart';

// Splash placeholder widget
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (_, __) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/mode-select',
      name: 'mode-select',
      builder: (_, __) => const ModeSelectionScreen(),
    ),
    GoRoute(
      path: '/camera',
      name: 'camera',
      builder: (_, __) => const CameraScreen(),
    ),
    GoRoute(
      path: '/viewer',
      name: 'viewer',
      builder: (_, __) => const ViewerDashboardScreen(),
      routes: [
        GoRoute(
          path: 'live/:deviceId',
          name: 'live-stream',
          builder: (_, state) => LiveStreamScreen(
            deviceId: state.pathParameters['deviceId'] ?? '',
          ),
        ),
        GoRoute(
          path: 'events',
          name: 'events',
          builder: (_, __) => const EventTimelineScreen(),
        ),
        GoRoute(
          path: 'devices',
          name: 'devices',
          builder: (_, __) => const DeviceManagementScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (_, __) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (_, __) => const ProfileScreen(),
    ),
  ],
);
