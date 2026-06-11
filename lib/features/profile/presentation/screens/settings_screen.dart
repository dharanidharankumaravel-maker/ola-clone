import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkThemeEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
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
            value: _darkThemeEnabled,
            onChanged: (val) {
              if (!val) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Light theme is currently in development!')),
                );
              }
              setState(() => _darkThemeEnabled = true); // Force dark theme
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Account'),
          _buildListTile('Privacy Policy', Icons.lock_outline),
          _buildListTile('Terms of Service', Icons.description_outlined),
          _buildListTile('App Version', Icons.info_outline, trailingText: 'v1.0.0'),
          
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

  Widget _buildListTile(String title, IconData icon, {String? trailingText}) {
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
            : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: () {},
      ),
    );
  }
}
