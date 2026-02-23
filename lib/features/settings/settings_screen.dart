import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _motionAlerts = true;
  bool _soundAlerts = true;
  bool _emailAlerts = false;
  bool _nightModeSchedule = false;
  double _globalSensitivity = 0.6;
  String _retention = '24 hours';
  TimeOfDay _nightStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _nightEnd = const TimeOfDay(hour: 6, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader(title: 'Notifications'),
          _SettingsTile(
            icon: Icons.notifications_active_rounded,
            title: 'Motion Alerts',
            subtitle: 'Get notified on motion detection',
            trailing: Switch(
              value: _motionAlerts,
              onChanged: (v) => setState(() => _motionAlerts = v),
            ),
          ),
          _SettingsTile(
            icon: Icons.volume_up_rounded,
            title: 'Sound Alerts',
            subtitle: 'Play sound on alert',
            trailing: Switch(
              value: _soundAlerts,
              onChanged: (v) => setState(() => _soundAlerts = v),
            ),
          ),
          _SettingsTile(
            icon: Icons.email_outlined,
            title: 'Email Alerts',
            subtitle: 'Send email for critical events',
            trailing: Switch(
              value: _emailAlerts,
              onChanged: (v) => setState(() => _emailAlerts = v),
            ),
          ),
          const SizedBox(height: 8),
          _SectionHeader(title: 'Motion Detection'),
          _SensitivityTile(
            value: _globalSensitivity,
            onChanged: (v) => setState(() => _globalSensitivity = v),
          ),
          const SizedBox(height: 8),
          _SectionHeader(title: 'Scheduling'),
          _SettingsTile(
            icon: Icons.nightlight_round,
            title: 'Night Mode Schedule',
            subtitle: 'Auto-switch sensitivity at night',
            trailing: Switch(
              value: _nightModeSchedule,
              onChanged: (v) => setState(() => _nightModeSchedule = v),
            ),
          ),
          if (_nightModeSchedule) ...[
            _TimeTile(
              label: 'Night Start',
              time: _nightStart,
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: _nightStart,
                );
                if (t != null) setState(() => _nightStart = t);
              },
            ),
            _TimeTile(
              label: 'Night End',
              time: _nightEnd,
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: _nightEnd,
                );
                if (t != null) setState(() => _nightEnd = t);
              },
            ),
          ],
          const SizedBox(height: 8),
          _SectionHeader(title: 'Storage'),
          _RetentionTile(
            current: _retention,
            options: const ['24 hours', '7 days', '30 days'],
            onSelect: (v) => setState(() => _retention = v),
          ),
          const SizedBox(height: 8),
          _SectionHeader(title: 'Security'),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'App Lock',
            subtitle: 'Use biometrics or PIN to unlock',
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textHint,
            ),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.devices_other_rounded,
            title: 'Active Sessions',
            subtitle: 'Manage logged-in devices',
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textHint,
            ),
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: '1.0.0 (build 1)',
            trailing: null,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTheme.dark.textTheme.bodySmall?.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.bgCard.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.textMuted, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.dark.textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                    ),
                  ),
                  Text(subtitle, style: AppTheme.dark.textTheme.bodySmall),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _SensitivityTile extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _SensitivityTile({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.sensors_rounded,
                color: AppColors.textMuted,
                size: 18,
              ),
              const SizedBox(width: 14),
              Text(
                'Motion Sensitivity',
                style: AppTheme.dark.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${(value * 100).toInt()}%',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Slider(value: value, onChanged: onChanged),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Low', style: AppTheme.dark.textTheme.bodySmall),
              Text('High', style: AppTheme.dark.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 50),
            Text(
              label,
              style: AppTheme.dark.textTheme.titleMedium?.copyWith(
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text(
              time.format(context),
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _RetentionTile extends StatelessWidget {
  final String current;
  final List<String> options;
  final ValueChanged<String> onSelect;
  const _RetentionTile({
    required this.current,
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cloud_outlined,
                color: AppColors.textMuted,
                size: 18,
              ),
              const SizedBox(width: 14),
              Text(
                'Video Retention',
                style: AppTheme.dark.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: options.map((o) {
              final isSelected = o == current;
              final isFree = o == '24 hours';
              return GestureDetector(
                onTap: () => onSelect(o),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : AppColors.bgPrimary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        o,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!isFree) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
