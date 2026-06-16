import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../map/domain/entities/app_location.dart';
import '../../../map/presentation/providers/location_provider.dart';
import '../../domain/entities/ride.dart';
import '../providers/ride_provider.dart';

class DriverSearchScreen extends ConsumerStatefulWidget {
  const DriverSearchScreen({super.key});

  @override
  ConsumerState<DriverSearchScreen> createState() => _DriverSearchScreenState();
}

class _DriverSearchScreenState extends ConsumerState<DriverSearchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Mock: Finding driver after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      final locationState = ref.read(locationProvider);
      final rideType = ref.read(selectedRideTypeProvider);
      final options = ref.read(rideOptionsProvider);
      final useOlaMoney = ref.read(useOlaMoneyProvider);

      final pickup = locationState.pickup ?? const AppLocation(
        latitude: 13.0827,
        longitude: 80.2707,
        shortAddress: 'Current Location',
        formattedAddress: 'Current Location, Chennai',
      );
      final destination = locationState.destination;
      
      if (destination != null && rideType != null) {
        final selectedOption = options.firstWhere((o) => o.type == rideType);
        
        final mockDriver = Driver(
          id: 'drv_1',
          name: 'Ramesh Kumar',
          rating: 4.8,
          phone: '+91 98765 43210',
          vehicleNumber: 'TN 58 AB 1234',
          vehicleModel: 'Maruti Dzire',
          image: '',
          latitude: pickup.latitude + 0.005,
          longitude: pickup.longitude + 0.005,
          heading: 90.0,
        );

        final mockRide = Ride(
          id: 'ride_${DateTime.now().millisecondsSinceEpoch}',
          userId: 'usr_1',
          status: 'accepted',
          pickup: pickup,
          destination: destination,
          distance: selectedOption.fareEstimate.distance,
          duration: selectedOption.fareEstimate.duration,
          rideType: selectedOption.type,
          fareEstimate: selectedOption.fareEstimate,
          paymentMethod: useOlaMoney ? 'ola_money' : 'cash',
          driver: mockDriver,
          eta: 5,
          otp: '1234',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );

        ref.read(currentRideProvider.notifier).setCurrentRide(mockRide);
        context.pushReplacement('/ride-tracking');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Please select your ride again.')),
          );
          context.go('/');
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleCancel() {
    // Show confirmation dialog, then go back
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Ride?'),
        content: const Text('Are you sure you want to cancel finding a driver?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep Waiting', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/');
            },
            child: const Text('Cancel Ride', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Radar Pulse Animation
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ...List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          // offset each pulse ring by 1/3 phase
                          double phase = (_pulseController.value + (index / 3)) % 1.0;
                          double scale = 0.3 + (phase * 2.2);
                          double opacity = 1.0 - phase;
                          return Transform.scale(
                            scale: scale,
                            child: Opacity(
                              opacity: opacity * 0.5,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primaryGreen, width: 2),
                                  color: AppColors.primaryGreen.withOpacity(0.2),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreenLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryGreen, width: 2),
                      ),
                      child: const Icon(Icons.directions_car, size: 40, color: AppColors.primaryGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              Text('Finding your driver', style: AppTextStyles.h2.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Text('Matching you with the best driver nearby...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
              
              const SizedBox(height: 32),

              // Trip Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(locationState.pickup?.shortAddress ?? 'Pickup', style: AppTextStyles.bodyMedium, maxLines: 1)),
                      ],
                    ),
                    Container(
                      height: 12,
                      width: 1,
                      color: AppColors.border,
                      margin: const EdgeInsets.only(left: 3.5),
                      alignment: Alignment.centerLeft,
                    ),
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(locationState.destination?.shortAddress ?? 'Destination', style: AppTextStyles.bodyMedium, maxLines: 1)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tips
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.textSecondary, size: 16),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Your driver will receive a 4-digit OTP for trip verification', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary))),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text('Free cancellation within 5 minutes of booking', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              
              // Cancel Button
              GestureDetector(
                onTap: _handleCancel,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    border: Border.all(color: AppColors.danger, width: 1.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cancel_outlined, color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Text('Cancel Ride', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger, fontWeight: FontWeight.bold)),
                    ],
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
