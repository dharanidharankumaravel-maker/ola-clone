import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  String? _errorText;
  bool _isLoading = false;
  bool _isPhoneFocused = false;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isPhoneFocused = _phoneFocusNode.hasFocus;
        });
      }
    });
  }

  Future<void> _onSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 10) {
      setState(() {
        _errorText = 'Enter a valid 10-digit mobile number';
      });
      return;
    }
    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).sendOtp('+91$phone');
      if (!mounted) return;
      context.push('/otp-verification', extra: '+91$phone');
    } catch (e) {
      if (mounted) {
        setState(() => _errorText = 'Failed to send OTP. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Minimalist brand header instead of heavy pulsing graphic
              Text(
                'ALO',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: AppColors.primaryGreen,
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
              
              const SizedBox(height: 32),
                
                const Text('Welcome back 👋', style: AppTextStyles.displayTitle)
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                
                const SizedBox(height: 8),
                
                Text(
                  'Enter your mobile number to continue',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                )
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                
                const SizedBox(height: 40),

                // Form Field Container
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mobile Number',
                      style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Animated Country Code box that highlights in sync with the textfield
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _errorText != null
                                  ? AppColors.danger
                                  : (_isPhoneFocused ? AppColors.primaryGreen : AppColors.border),
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              const Text('+91', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            hintText: 'Enter 10-digit number',
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            errorText: _errorText,
                            onChanged: (val) {
                              if (_errorText != null) {
                                setState(() => _errorText = null);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                
                const SizedBox(height: 24),
                
                // Terms of Service Link with better style
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, height: 1.5),
                    children: [
                      const TextSpan(text: 'By continuing, you agree to our '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 250.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                
                const SizedBox(height: 32),
                
                // Send OTP Button
                PrimaryButton(
                  text: _isLoading ? 'Sending...' : 'Send OTP',
                  onPressed: _isLoading ? null : _onSendOtp,
                  isLoading: _isLoading,
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('New to Alo?', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(width: 4),
                    Text('Learn more →', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryGreen)),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 500.ms),
              ],
            ),
          ),
        ),
      );
  }
}
