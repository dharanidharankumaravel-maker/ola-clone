import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Log Out', style: AppTextStyles.sectionTitle),
        content: Text('Are you sure you want to log out?', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Log Out', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings', style: AppTextStyles.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Preferences'),
          _buildSwitchTile(
            title: 'Push Notifications',
            icon: Icons.notifications_none,
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          _buildSwitchTile(
            title: 'Location Services',
            icon: Icons.location_on_outlined,
            value: _locationEnabled,
            onChanged: (val) => setState(() => _locationEnabled = val),
          ),
          _buildSwitchTile(
            title: 'Dark Theme',
            icon: Icons.dark_mode_outlined,
            value: isDark,
            onChanged: (val) {
              ref.read(themeModeProvider.notifier).setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Account'),
          _buildListTile('Privacy Policy', Icons.lock_outline),
          _buildListTile('Terms of Service', Icons.description_outlined),
          _buildListTile('App Version', Icons.info_outline, trailingText: 'v1.0.0'),
          _buildListTile(
            'Log Out',
            Icons.logout,
            trailingText: 'Sign out',
            onTap: () => _handleLogout(context, ref),
          ),
          
          const SizedBox(height: 32),
          Center(
            child: TextButton(
              onPressed: () {
                // Handle delete account
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ref.read(authProvider.notifier).logout();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Account deleted successfully')),
                          );
                          context.go('/');
                        }, 
                        child: const Text('Delete', style: TextStyle(color: Colors.red))
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Delete Account', style: TextStyle(color: AppColors.danger)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(title, style: AppTextStyles.sectionTitle.copyWith(color: AppColors.primaryGreen)),
    );
  }

  Widget _buildSwitchTile({required String title, required IconData icon, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        title: Text(title, style: AppTextStyles.bodyMedium),
        secondary: Icon(icon, color: AppColors.textSecondary),
        value: value,
        activeColor: AppColors.primaryGreen,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, {String? trailingText, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(title, style: AppTextStyles.bodyMedium),
        trailing: trailingText != null 
            ? Text(trailingText, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary))
            : Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap ?? () {},
      ),
    );
  }
}
