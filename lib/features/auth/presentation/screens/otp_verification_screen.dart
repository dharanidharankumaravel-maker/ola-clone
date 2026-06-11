import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../widgets/otp_input.dart';
import '../providers/auth_provider.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  final String phone;

  const OTPVerificationScreen({super.key, required this.phone});

  @override
  ConsumerState<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  String _otp = '';
  bool _hasError = false;
  bool _isResending = false;
  int _countdown = 60;
  String _expectedOtp = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _simulateOtpReceive();
  }

  void _simulateOtpReceive() {
    final randomOtp = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString().substring(0, 4);
    _expectedOtp = randomOtp;
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your Ola code is $randomOtp. Do not share this with anyone.'),
            backgroundColor: AppColors.bgCard,
          ),
        );
      }
    });
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (_otp.length != 4) return;
    
    /* if (_otp != _expectedOtp) {
      setState(() {
        _hasError = true;
        _otp = ''; 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect OTP. Please check your code')),
      );
      return;
    } */

    setState(() {
      _hasError = false;
    });

    await ref.read(authProvider.notifier).verifyOtp(widget.phone, _otp);
    
    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.hasValue && authState.value != null) {
      context.go('/'); 
    }
  }

  void _handleResend() async {
    if (_countdown > 0) return;
    setState(() => _isResending = true);
    
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _isResending = false;
      _hasError = false;
    });
    
    _startCountdown();
    _simulateOtpReceive();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isVerifying = authState.isLoading;
    final maskedPhone = widget.phone.replaceAll(RegExp(r'\+91(\d{5})(\d{5})'), '+91 *****\$2');

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 28),
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 16),
              const Text('Verify OTP', style: AppTextStyles.displayTitle),
              const SizedBox(height: 8),
              Text(
                'We sent a 4-digit code to\n$maskedPhone',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 48),

              OTPInput(
                length: 4,
                hasError: _hasError,
                onChanged: (val) {
                  setState(() {
                    _otp = val;
                    if (val.length == 4) {
                      _handleVerify();
                    }
                  });
                },
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                text: isVerifying ? 'Verifying...' : 'Verify OTP',
                onPressed: _handleVerify,
                isLoading: isVerifying,
                disabled: _otp.length < 4,
              ),
              const SizedBox(height: 24),

              Center(
                child: _countdown > 0
                    ? Text.rich(
                        TextSpan(
                          text: 'Resend OTP in ',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          children: [
                            TextSpan(
                              text: '${_countdown}s',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryGreen),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: _handleResend,
                        child: Text(
                          _isResending ? 'Sending...' : "Didn't receive? Resend OTP",
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryGreen),
                        ),
                      ),
              ),
              const Spacer(),
              Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Text(
                    'Change mobile number',
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
