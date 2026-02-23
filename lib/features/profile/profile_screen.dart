import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.25),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'U',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.bgPrimary,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'User Name',
                  style: AppTheme.dark.textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'user@example.com',
                  style: AppTheme.dark.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                // Plan badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.warning,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Free Plan',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Stats row
          Row(
            children: [
              _StatBox(label: 'Cameras', value: '3'),
              const SizedBox(width: 12),
              _StatBox(label: 'Events', value: '128'),
              const SizedBox(width: 12),
              _StatBox(label: 'Storage', value: '1.2 GB'),
            ],
          ),

          const SizedBox(height: 28),

          // Upgrade CTA
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.2),
                  AppColors.accent.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upgrade to Premium',
                        style: AppTheme.dark.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unlock 30-day retention, AI detection & more',
                        style: AppTheme.dark.textTheme.bodySmall?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Upgrade'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Account section
          _SectionLabel(label: 'Account'),
          _ProfileTile(
            icon: Icons.people_outline_rounded,
            label: 'Family Members',
            subtitle: 'Manage access for 0 members',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.shield_outlined,
            label: 'Privacy & Security',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.star_border_rounded,
            label: 'Rate SentryLens',
            onTap: () {},
          ),

          const SizedBox(height: 16),
          _SectionLabel(label: 'Account Actions'),
          _ProfileTile(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            isDestructive: true,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.bgSurface,
                  title: Text(
                    'Sign Out',
                    style: AppTheme.dark.textTheme.titleLarge,
                  ),
                  content: Text(
                    'Are you sure you want to sign out?',
                    style: AppTheme.dark.textTheme.bodyMedium,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.goNamed('login');
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTheme.dark.textTheme.headlineMedium?.copyWith(
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTheme.dark.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label.toUpperCase(),
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

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.accent : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDestructive
                ? AppColors.accent.withValues(alpha: 0.2)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.dark.textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                      color: isDestructive
                          ? AppColors.accent
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTheme.dark.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(
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
