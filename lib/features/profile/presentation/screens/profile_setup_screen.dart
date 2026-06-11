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
  bool _isSubmitting = false;

  void _onSubmit() async {
    if (_nameController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);
    
    // Simulate API Call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    
    // Actually save the name
    final user = ref.read(authProvider).value;
    if (user != null) {
      ref.read(authProvider.notifier).updateUser(
        user.copyWith(name: _nameController.text.trim())
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

              // Photo Placeholder
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bgCard,
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.person_outline, size: 36, color: AppColors.textSecondary),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
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
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: 'Email (optional)',
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.mail_outline, color: AppColors.textSecondary),
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
