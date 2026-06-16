import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Start loading user info
    final userFuture = ref.read(authProvider.future);

    // Snappy delay for authentication check and splash display
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (!mounted) return;

    try {
      final user = await userFuture;
      if (user != null && user.id.isNotEmpty) {
        context.go('/');
      } else {
        context.go('/login'); // Direct to login, bypassing onboarding
      }
    } catch (_) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Clean, bold branding text in primary Green
            Text(
              'ALO',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 54,
                fontWeight: FontWeight.w900,
                letterSpacing: 6.0,
                color: AppColors.primaryGreen,
              ),
            )
            .animate()
            .fadeIn(duration: 800.ms)
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              duration: 800.ms,
              curve: Curves.easeOutBack,
            ),
            const SizedBox(height: 8),
            // Minimalist Tagline
            Text(
              'Your ride, simplified',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms),
            const Spacer(),
            // Sleek premium linear progress bar instead of circular progress
            SizedBox(
              width: 120,
              height: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(1.5),
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
