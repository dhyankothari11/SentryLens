import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class EventTimelineScreen extends StatelessWidget {
  const EventTimelineScreen({super.key});

  final List<_TimelineEvent> events = const [
    _TimelineEvent(
      camera: 'Front Door',
      time: '15:42',
      date: 'Today',
      duration: '12s',
      severity: 'alert',
    ),
    _TimelineEvent(
      camera: 'Living Room',
      time: '15:24',
      date: 'Today',
      duration: '8s',
      severity: 'motion',
    ),
    _TimelineEvent(
      camera: 'Living Room',
      time: '14:07',
      date: 'Today',
      duration: '24s',
      severity: 'motion',
    ),
    _TimelineEvent(
      camera: 'Front Door',
      time: '12:33',
      date: 'Today',
      duration: '5s',
      severity: 'motion',
    ),
    _TimelineEvent(
      camera: 'Garage',
      time: '10:15',
      date: 'Today',
      duration: '15s',
      severity: 'alert',
    ),
    _TimelineEvent(
      camera: 'Front Door',
      time: '09:02',
      date: 'Today',
      duration: '7s',
      severity: 'motion',
    ),
    _TimelineEvent(
      camera: 'Living Room',
      time: '22:48',
      date: 'Yesterday',
      duration: '19s',
      severity: 'alert',
    ),
    _TimelineEvent(
      camera: 'Garage',
      time: '21:11',
      date: 'Yesterday',
      duration: '6s',
      severity: 'motion',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<_TimelineEvent>>{};
    for (final e in events) {
      grouped.putIfAbsent(e.date, () => []).add(e);
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Event Timeline'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'All',
                'Motion',
                'Alert',
                'Today',
                'This Week',
              ].map((f) => _Chip(label: f, isSelected: f == 'All')).toList(),
            ),
          ),
          const SizedBox(height: 24),
          // Timeline groups
          ...grouped.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DateHeader(date: entry.key),
                const SizedBox(height: 12),
                ...entry.value.map((e) => _TimelineTile(event: e)),
                const SizedBox(height: 20),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            date,
            style: AppTheme.dark.textTheme.labelMedium?.copyWith(
              color: AppColors.accent,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final _TimelineEvent event;
  const _TimelineTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final isAlert = event.severity == 'alert';
    final color = isAlert ? AppColors.accent : AppColors.warning;
    final icon = isAlert
        ? Icons.warning_amber_rounded
        : Icons.motion_photos_on_rounded;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              Expanded(
                child: Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: AppColors.border,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // Event card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAlert ? 'Motion Alert' : 'Motion Detected',
                          style: AppTheme.dark.textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.camera,
                          style: AppTheme.dark.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 11,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.time,
                              style: AppTheme.dark.textTheme.bodySmall,
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.timer_outlined,
                              size: 11,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.duration,
                              style: AppTheme.dark.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Thumbnail placeholder
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.play_circle_outline_rounded,
                      color: AppColors.textHint,
                      size: 24,
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
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _Chip({required this.label, required this.isSelected});

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

class _TimelineEvent {
  final String camera, time, date, duration, severity;
  const _TimelineEvent({
    required this.camera,
    required this.time,
    required this.date,
    required this.duration,
    required this.severity,
  });
}
