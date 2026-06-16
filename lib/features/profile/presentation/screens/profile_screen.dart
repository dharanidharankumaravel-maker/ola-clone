import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showAvatarSelector(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    final avatars = [
      'Felix', 'Aneka', 'Charlie', 'Jack', 'Sasha', 'Oliver', 'Harley', 'Lulu'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose an Avatar', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('Select a style to customize your profile', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: avatars.length,
                itemBuilder: (context, index) {
                  final seed = avatars[index];
                  final url = 'https://api.dicebear.com/7.x/adventurer/png?seed=$seed';
                  final isSelected = user.profilePhoto == url;

                  return GestureDetector(
                    onTap: () {
                      ref.read(authProvider.notifier).updateUser(
                        user.copyWith(profilePhoto: url),
                      );
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primaryGreen : AppColors.border,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          url,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, size: 30);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryGreen),
            onPressed: () {
              context.push('/profile-setup', extra: false);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _showAvatarSelector(context, ref),
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGreenLight,
                            border: Border.all(color: AppColors.primaryGreen, width: 3),
                          ),
                          alignment: Alignment.center,
                          child: user?.profilePhoto != null
                              ? ClipOval(
                                  child: Image.network(
                                    user!.profilePhoto!,
                                    width: 82,
                                    height: 82,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Text(
                                  user?.name?.isNotEmpty == true ? user!.name![0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () => _showAvatarSelector(context, ref),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.bgCard, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_outlined, size: 14, color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(user?.name ?? 'Set your name', style: AppTextStyles.displayTitle.copyWith(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(user?.phone ?? '', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  if (user?.email != null) ...[
                    const SizedBox(height: 4),
                    Text(user!.email!, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreenLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppColors.primaryGreen),
                        const SizedBox(width: 4),
                        Text(
                          '₹${user?.walletBalance.toStringAsFixed(0) ?? 0}',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Text('Alo Money', style: AppTextStyles.caption.copyWith(color: AppColors.primaryGreen)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad),
            const SizedBox(height: 16),
            
            // Stats Row
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text('${user?.totalRides ?? 0}', style: AppTextStyles.displayTitle.copyWith(fontSize: 20)),
                        Text('Rides', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppColors.border),
                  Expanded(
                    child: Column(
                      children: [
                        Text('${user?.rating.toStringAsFixed(1) ?? "—"}', style: AppTextStyles.displayTitle.copyWith(fontSize: 20)),
                        Text('Rating', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad),
            const SizedBox(height: 16),
 
            // Menu Options
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.history, 'Ride History', () => context.push('/ride-history')),
                  _buildMenuItem(Icons.account_balance_wallet_outlined, 'Alo Wallet', () => context.push('/wallet')),
                  _buildMenuItem(Icons.inventory_2_outlined, 'Alo Parcel', () => context.push('/parcel')),
                  _buildMenuItem(Icons.location_on_outlined, 'Saved Places', () => context.push('/saved-places')),
                  _buildMenuItem(Icons.headset_mic_outlined, 'Help & Support', () => context.push('/support')),
                  _buildMenuItem(Icons.settings_outlined, 'Settings', () => context.push('/settings'), showBorder: false),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad),
            const SizedBox(height: 24),
 
            // Logout
            InkWell(
              onTap: () => _handleLogout(context, ref),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.danger.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: AppColors.danger, size: 20),
                    const SizedBox(width: 8),
                    Text('Log Out', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger)),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
 
  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap, {bool showBorder = true}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: showBorder ? Border(bottom: BorderSide(color: AppColors.border)) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryGreenLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryGreen, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: AppTextStyles.bodyMedium),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
