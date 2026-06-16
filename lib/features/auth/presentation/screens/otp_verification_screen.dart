import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        _showSimulatedNotification(randomOtp);
        
        // Simulate auto-fetch and auto-fill of the received OTP code
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            setState(() {
              _otp = randomOtp;
            });
            _handleVerify();
          }
        });
      }
    });
  }

  void _showSimulatedNotification(String otp) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E28),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.sms_outlined, color: AppColors.black, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'MESSAGES',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            'now',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your Alo verification code is $otp. Do not share this with anyone.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )
      .animate()
      .slideY(begin: -1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad)
      .then(delay: 5.seconds)
      .slideY(begin: 0, end: -1.5, duration: 400.ms, curve: Curves.easeInQuad),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 6), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void _showErrorNotification() {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C1E21),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.danger.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'VERIFICATION ERROR',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Incorrect OTP. Please check the code and try again.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )
      .animate()
      .slideY(begin: -1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad)
      .then(delay: 4.seconds)
      .slideY(begin: 0, end: -1.5, duration: 400.ms, curve: Curves.easeInQuad),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 5), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
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
    
    if (_otp != _expectedOtp) {
      setState(() {
        _hasError = true;
      });
      _showErrorNotification();
      return;
    }

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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clean Back Button with container/hover effect style
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ).animate().fade(duration: 300.ms).slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 24),
              
              const Text('Verify OTP', style: AppTextStyles.displayTitle)
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
              
              const SizedBox(height: 8),
              
              Text(
                'We sent a 4-digit code to\n$maskedPhone',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, height: 1.5),
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
              
              const SizedBox(height: 48),

              OTPInput(
                length: 4,
                hasError: _hasError,
                value: _otp,
                onChanged: (val) {
                  setState(() {
                    _otp = val;
                    if (_hasError) {
                      _hasError = false;
                    }
                    if (val.length == 4) {
                      _handleVerify();
                    }
                  });
                },
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
              
              const SizedBox(height: 40),

              PrimaryButton(
                text: isVerifying ? 'Verifying...' : 'Verify OTP',
                onPressed: _handleVerify,
                isLoading: isVerifying,
                disabled: _otp.length < 4,
              )
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 500.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
              
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
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: _handleResend,
                        child: Text(
                          _isResending ? 'Sending...' : "Didn't receive? Resend OTP",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms),
              
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
