import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/auth_provider.dart';

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

    // Artificial delay to show logo
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;

    try {
      final user = await userFuture;
      if (user != null && user.id.isNotEmpty) {
        context.go('/');
      } else {
        context.go('/onboarding');
      }
    } catch (_) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/splash.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
