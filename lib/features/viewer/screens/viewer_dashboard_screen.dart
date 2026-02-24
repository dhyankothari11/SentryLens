import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

// Provides a real-time stream of all active WebRTC rooms for this user
final activeRoomsProvider =
    StreamProvider.autoDispose<List<QueryDocumentSnapshot>>((ref) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return Stream.value([]);

      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('rooms')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    });

class ViewerDashboardScreen extends StatefulWidget {
  const ViewerDashboardScreen({super.key});

  @override
  State<ViewerDashboardScreen> createState() => _ViewerDashboardScreenState();
}

class _ViewerDashboardScreenState extends State<ViewerDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<_EventData> _events = [
    _EventData(
      camera: 'Front Door',
      time: '2 min ago',
      duration: '12s',
      severity: EventSeverity.alert,
    ),
    _EventData(
      camera: 'Living Room',
      time: '18 min ago',
      duration: '8s',
      severity: EventSeverity.motion,
    ),
    _EventData(
      camera: 'Living Room',
      time: '1 hr ago',
      duration: '24s',
      severity: EventSeverity.motion,
    ),
    _EventData(
      camera: 'Front Door',
      time: '3 hrs ago',
      duration: '5s',
      severity: EventSeverity.motion,
    ),
    _EventData(
      camera: 'Garage',
      time: '5 hrs ago',
      duration: '15s',
      severity: EventSeverity.alert,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _selectedTab == 0
                    ? _buildDashboard()
                    : _buildEventsTab(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.goNamed(
                  'live-stream',
                  pathParameters: {'deviceId': 'front_door'},
                );
              },
              backgroundColor: AppColors.accent,
              icon: const Icon(
                Icons.play_circle_outline_rounded,
                color: Colors.white,
              ),
              label: Text(
                'View Live',
                style: AppTheme.dark.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final user = ref.watch(authStateProvider).valueOrNull;
                  final displayName = user?.displayName ?? 'SentryLens User';
                  return Text(
                    displayName,
                    style: AppTheme.dark.textTheme.headlineMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
              Consumer(
                builder: (context, ref, child) {
                  final roomCount = ref
                      .watch(activeRoomsProvider)
                      .maybeWhen(
                        data: (rooms) => rooms.length,
                        orElse: () => 0,
                      );
                  return Text(
                    '$roomCount cameras online',
                    style: AppTheme.dark.textTheme.bodySmall,
                  );
                },
              ),
            ],
          ),
          const Spacer(),
          // Notification bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 26,
                ),
                onPressed: () {},
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.textPrimary,
              size: 26,
            ),
            onPressed: () => context.pushNamed('profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return ListView(
      padding: const EdgeInsets.only(top: 20, bottom: 100),
      children: [
        // Status summary cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final count = ref
                      .watch(activeRoomsProvider)
                      .maybeWhen(
                        data: (rooms) => rooms.length,
                        orElse: () => 0,
                      );
                  return _StatCard(
                    label: 'Online',
                    value: '$count',
                    color: AppColors.success,
                    icon: Icons.videocam_rounded,
                  );
                },
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Events Today',
                value: '${_events.length}',
                color: AppColors.accent,
                icon: Icons.motion_photos_on_rounded,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Alerts',
                value:
                    '${_events.where((e) => e.severity == EventSeverity.alert).length}',
                color: AppColors.warning,
                icon: Icons.warning_amber_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // My Cameras
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text('My Cameras', style: AppTheme.dark.textTheme.titleMedium),
              const Spacer(),
              GestureDetector(
                onTap: () => context.goNamed('devices'),
                child: Text(
                  'Manage',
                  style: AppTheme.dark.textTheme.bodySmall?.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 164, // Increased to prevent bottom overflow
          child: Consumer(
            builder: (context, ref, child) {
              final activeRoomsAsync = ref.watch(activeRoomsProvider);

              return activeRoomsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
                error: (e, st) => Center(
                  child: Text(
                    'Error: $e',
                    style: AppTheme.dark.textTheme.bodySmall,
                  ),
                ),
                data: (rooms) {
                  if (rooms.isEmpty) {
                    return Center(
                      child: Text(
                        'No cameras currently online.\nGo to Set as Camera to add one.',
                        textAlign: TextAlign.center,
                        style: AppTheme.dark.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: rooms.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _DeviceCard(room: rooms[i]),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        // Recent Events
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text('Recent Events', style: AppTheme.dark.textTheme.titleMedium),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _selectedTab = 1),
                child: Text(
                  'See all',
                  style: AppTheme.dark.textTheme.bodySmall?.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...(_events.take(3).map((e) => _EventTile(event: e))),
      ],
    );
  }

  Widget _buildEventsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Motion', 'Alert', 'Today', 'This Week']
                .map((f) => _FilterChip(label: f, isSelected: f == 'All'))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        ..._events.map((e) => _EventTile(event: e)),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                isSelected: _selectedTab == 0,
                onTap: () => setState(() => _selectedTab = 0),
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: 'Events',
                isSelected: _selectedTab == 1,
                onTap: () => setState(() => _selectedTab = 1),
              ),
              _NavItem(
                icon: Icons.videocam_outlined,
                label: 'Devices',
                isSelected: false,
                onTap: () => context.goNamed('devices'),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                isSelected: false,
                onTap: () => context.pushNamed('settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent : AppColors.textHint,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.textHint,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(label, style: AppTheme.dark.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final QueryDocumentSnapshot room;
  const _DeviceCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final roomId = room.id;
    final shortId = roomId.substring(0, 8);

    return GestureDetector(
      onTap: () =>
          context.goNamed('live-stream', pathParameters: {'deviceId': roomId}),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Camera preview placeholder
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.videocam_rounded,
                  color: AppColors.accent.withValues(alpha: 0.6),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Camera-$shortId',
              style: AppTheme.dark.textTheme.titleMedium?.copyWith(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.battery_full_rounded,
                  size: 12,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text('100%', style: AppTheme.dark.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final _EventData event;
  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = event.severity == EventSeverity.alert
        ? AppColors.accent
        : AppColors.warning;
    final icon = event.severity == EventSeverity.alert
        ? Icons.warning_amber_rounded
        : Icons.motion_photos_on_rounded;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.severity == EventSeverity.alert
                      ? 'Motion Alert'
                      : 'Motion Detected',
                  style: AppTheme.dark.textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(event.camera, style: AppTheme.dark.textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(event.time, style: AppTheme.dark.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                event.duration,
                style: AppTheme.dark.textTheme.bodySmall?.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.play_circle_outline_rounded,
            color: AppColors.textHint,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.accent : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textMuted,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

enum EventSeverity { motion, alert }

class _EventData {
  final String camera, time, duration;
  final EventSeverity severity;
  _EventData({
    required this.camera,
    required this.time,
    required this.duration,
    required this.severity,
  });
}
