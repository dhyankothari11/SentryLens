import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  final List<_Device> _devices = [
    _Device(
      id: 'front_door',
      name: 'Front Door',
      location: 'Entrance',
      isOnline: true,
      battery: 87,
      uptime: '14h 22m',
      eventsToday: 3,
    ),
    _Device(
      id: 'living_room',
      name: 'Living Room',
      location: 'Ground Floor',
      isOnline: true,
      battery: 62,
      uptime: '6h 45m',
      eventsToday: 7,
    ),
    _Device(
      id: 'garage',
      name: 'Garage',
      location: 'Basement',
      isOnline: false,
      battery: 15,
      uptime: '—',
      eventsToday: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Devices'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Add device button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _showAddDeviceSheet(context);
            },
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Camera',
                        style: AppTheme.dark.textTheme.titleMedium,
                      ),
                      Text(
                        'Pair another device as camera',
                        style: AppTheme.dark.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.qr_code_rounded,
                    color: AppColors.accent,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'My Cameras (${_devices.length})',
            style: AppTheme.dark.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ..._devices.map(
            (d) => _DeviceDetailCard(
              device: d,
              onDelete: () =>
                  setState(() => _devices.removeWhere((x) => x.id == d.id)),
              onRename: (name) => setState(
                () => _devices.firstWhere((x) => x.id == d.id).name == name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDeviceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add Camera Device',
              style: AppTheme.dark.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Install SentryLens on the old phone, then scan the QR code below to pair it.',
              style: AppTheme.dark.textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // QR placeholder
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code_2_rounded,
                  color: AppColors.textMuted,
                  size: 100,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DeviceDetailCard extends StatelessWidget {
  final _Device device;
  final VoidCallback onDelete;
  final ValueChanged<String> onRename;

  const _DeviceDetailCard({
    required this.device,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = device.isOnline
        ? AppColors.success
        : AppColors.textHint;

    return Dismissible(
      key: Key(device.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.accent,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.videocam_rounded,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: AppTheme.dark.textTheme.titleMedium,
                      ),
                      Text(
                        device.location,
                        style: AppTheme.dark.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        device.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                _Stat(
                  label: 'Battery',
                  value: '${device.battery}%',
                  icon: Icons.battery_full_rounded,
                ),
                _Stat(
                  label: 'Uptime',
                  value: device.uptime,
                  icon: Icons.schedule_rounded,
                ),
                _Stat(
                  label: 'Events',
                  value: '${device.eventsToday}',
                  icon: Icons.motion_photos_on_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _Stat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.textHint, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.dark.textTheme.titleMedium?.copyWith(fontSize: 14),
          ),
          Text(label, style: AppTheme.dark.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Device {
  final String id, location, uptime;
  String name;
  final bool isOnline;
  final int battery, eventsToday;
  _Device({
    required this.id,
    required this.name,
    required this.location,
    required this.isOnline,
    required this.battery,
    required this.uptime,
    required this.eventsToday,
  });
}
