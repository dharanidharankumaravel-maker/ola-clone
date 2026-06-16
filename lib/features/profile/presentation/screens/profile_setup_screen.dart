import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final bool isNewUser;
  
  const ProfileSetupScreen({super.key, this.isNewUser = true});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _avatarUrl;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).value;
      if (user != null) {
        _nameController.text = user.name ?? '';
        _emailController.text = user.email ?? '';
        setState(() {
          _avatarUrl = user.profilePhoto;
        });
      }
    });
  }

  void _showAvatarSelector() {
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
                  final isSelected = _avatarUrl == url;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _avatarUrl = url;
                      });
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

  void _onSubmit() async {
    if (_nameController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);
    
    // Simulate API Call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    
    // Save the name, email, and photo
    final user = ref.read(authProvider).value;
    if (user != null) {
      ref.read(authProvider.notifier).updateUser(
        user.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
          profilePhoto: _avatarUrl,
        )
      );
    }
    
    context.go('/');
  }

  void _onSkip() {
    context.go('/');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                widget.isNewUser ? 'Set up your profile' : 'Complete your profile',
                style: AppTextStyles.displayTitle,
              ),
              const SizedBox(height: 8),
              Text(
                'Tell us a bit about yourself',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),

              // Photo Placeholder with network selector
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _showAvatarSelector,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.bgCard,
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: _avatarUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  _avatarUrl!,
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.person_outline, size: 36, color: AppColors.textSecondary),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showAvatarSelector,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.bgSurface, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, size: 14, color: AppColors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text('Add Photo', style: AppTextStyles.label.copyWith(color: AppColors.primaryGreen)),
              ),
              const SizedBox(height: 48),

              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: 'Email (optional)',
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(Icons.mail_outline, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),

              PrimaryButton(
                text: 'Get Started',
                onPressed: _onSubmit,
                isLoading: _isSubmitting,
              ),
              const SizedBox(height: 16),
              
              if (!widget.isNewUser)
                Center(
                  child: TextButton(
                    onPressed: _onSkip,
                    child: Text(
                      'Skip for now',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
