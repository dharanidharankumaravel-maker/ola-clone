import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/profile_setup_screen.dart';
import '../../features/map/presentation/screens/home_map_screen.dart';
import '../../features/map/presentation/screens/destination_search_screen.dart';
import '../../features/map/presentation/screens/map_picker_screen.dart';
import '../../features/map/presentation/screens/quick_book_screen.dart';
import '../../features/ride/presentation/screens/ride_selection_screen.dart';
import '../../features/ride/presentation/screens/schedule_ride_screen.dart';
import '../../features/ride/presentation/screens/driver_search_screen.dart';
import '../../features/ride/presentation/screens/ride_tracking_screen.dart';
import '../../features/ride/presentation/screens/payment_method_screen.dart';
import '../../features/profile/presentation/screens/wallet_screen.dart';
import '../../features/ride/presentation/screens/parcel_screen.dart';
import '../../features/ride/presentation/screens/parcel_details_screen.dart';
import '../../features/ride/presentation/screens/parcel_location_search_screen.dart';
import '../../features/ride/presentation/screens/driver_feedback_screen.dart';

import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/ride_history_screen.dart';
import '../../features/profile/presentation/screens/saved_places_screen.dart';
import '../../features/profile/presentation/screens/support_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/otp-verification',
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return OTPVerificationScreen(phone: phone);
      },
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) {
        final isNewUser = state.extra as bool? ?? true;
        return ProfileSetupScreen(isNewUser: isNewUser);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/destination-search',
      builder: (context, state) {
        final extra = state.extra;
        bool isPickup = false;
        String? returnRoute;
        bool returnLocation = false;
        if (extra is bool) {
          isPickup = extra;
        } else if (extra is Map) {
          isPickup = extra['isPickup'] ?? false;
          returnRoute = extra['returnRoute'] as String?;
          returnLocation = extra['returnLocation'] ?? false;
        }
        return DestinationSearchScreen(isPickup: isPickup, returnRoute: returnRoute, returnLocation: returnLocation);
      },
    ),
    GoRoute(
      path: '/map-picker',
      builder: (context, state) {
        final isPickup = state.extra as bool? ?? true;
        return MapPickerScreen(isPickup: isPickup);
      },
    ),
    GoRoute(
      path: '/ride-selection',
      builder: (context, state) => const RideSelectionScreen(),
    ),
    GoRoute(
      path: '/schedule-ride-booking',
      builder: (context, state) => const ScheduleRideScreen(),
    ),
    GoRoute(
      path: '/payment-method',
      builder: (context, state) => const PaymentMethodScreen(),
    ),
    GoRoute(
      path: '/wallet',
      builder: (context, state) => const WalletScreen(),
    ),
    GoRoute(
      path: '/ride-history',
      builder: (context, state) => const RideHistoryScreen(),
    ),
    GoRoute(
      path: '/saved-places',
      builder: (context, state) => const SavedPlacesScreen(),
    ),
    GoRoute(
      path: '/support',
      builder: (context, state) => const SupportScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/parcel-details',
      builder: (context, state) {
        final category = state.extra as String? ?? 'Others';
        return ParcelDetailsScreen(category: category);
      },
    ),
    GoRoute(
      path: '/parcel-location-search',
      builder: (context, state) {
        final isPickup = state.extra as bool? ?? true;
        return ParcelLocationSearchScreen(isPickup: isPickup);
      },
    ),
    GoRoute(
      path: '/driver-search',
      builder: (context, state) => const DriverSearchScreen(),
    ),
    GoRoute(
      path: '/ride-tracking',
      builder: (context, state) => const RideTrackingScreen(),
    ),
    GoRoute(
      path: '/driver-feedback',
      builder: (context, state) => const DriverFeedbackScreen(),
    ),
    // Deep link route for tracking a specific ride
    GoRoute(
      path: '/ride/:id',
      builder: (context, state) {
        final rideId = state.pathParameters['id'];
        return const RideTrackingScreen();
      },
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainShellScaffold(state: state, child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeMapScreen(),
        ),
        GoRoute(
          path: '/parcel',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const ParcelScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOut)),
                ),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/quick-book',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const QuickBookScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOut)),
                ),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/schedule-ride',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const ScheduleRideScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOut)),
                ),
                child: child,
              );
            },
          ),
        ),
      ],
    ),
  ],
);

class MainShellScaffold extends StatelessWidget {
  final GoRouterState state;
  final Widget child;

  const MainShellScaffold({
    super.key,
    required this.state,
    required this.child,
  });

  int _getSelectedIndex(String path) {
    if (path == '/') return 0;
    if (path.startsWith('/parcel')) return 1;
    if (path.startsWith('/quick-book')) return 2;
    if (path.startsWith('/schedule-ride')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final path = state.uri.path;
    final selectedIndex = _getSelectedIndex(path);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          if (index == 0) {
            context.go('/');
          } else if (index == 1) {
            context.go('/parcel');
          } else if (index == 2) {
            context.go('/quick-book');
          } else if (index == 3) {
            context.go('/schedule-ride');
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          const BottomNavigationBarItem(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: Icon(Icons.home_outlined, size: 24),
            ),
            activeIcon: SizedBox(
              width: 24,
              height: 24,
              child: Icon(Icons.home, size: 24),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: Transform.scale(
                scale: 1.4, // Visually enlarges without expanding layout footprint
                child: Image.asset(
                  'assets/scooter_white_parcel.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  color: selectedIndex == 1 ? AppColors.primaryGreen : AppColors.textSecondary,
                ),
              ),
            ),
            label: 'Parcel',
          ),
          const BottomNavigationBarItem(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: Icon(Icons.bolt_outlined, size: 24),
            ),
            activeIcon: SizedBox(
              width: 24,
              height: 24,
              child: Icon(Icons.bolt, size: 24),
            ),
            label: 'Quickbook',
          ),
          const BottomNavigationBarItem(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: Icon(Icons.calendar_month_outlined, size: 24),
            ),
            activeIcon: SizedBox(
              width: 24,
              height: 24,
              child: Icon(Icons.calendar_month, size: 24),
            ),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}
