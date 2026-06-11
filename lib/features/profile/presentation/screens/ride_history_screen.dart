import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../ride/presentation/providers/ride_provider.dart';

class RideHistoryScreen extends ConsumerWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rides = ref.watch(rideHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Your Rides', style: AppTextStyles.h3),
      ),
      body: rides.isEmpty
          ? const Center(
              child: Text('No rides yet', style: AppTextStyles.bodyMedium),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rides.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final ride = rides[index];
                final isCompleted = ride.status == 'completed';

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(ride.createdAt, style: AppTextStyles.bodyMedium),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted ? AppColors.primaryGreenLight : AppColors.dangerLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isCompleted ? 'Completed' : 'Cancelled',
                              style: AppTextStyles.caption.copyWith(
                                color: isCompleted ? AppColors.primaryGreen : AppColors.danger,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: const Divider(color: AppColors.border),
                      ),
                      Row(
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.circle, size: 12, color: AppColors.primaryGreen),
                              Container(height: 20, width: 2, color: AppColors.border),
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.danger),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ride.pickup.shortAddress ?? 'Pickup', style: AppTextStyles.bodyMedium),
                                const SizedBox(height: 12),
                                Text(ride.destination.shortAddress ?? 'Dropoff', style: AppTextStyles.bodyMedium),
                              ],
                            ),
                          ),
                          Text('₹${ride.fareEstimate.total.toStringAsFixed(0)}', style: AppTextStyles.h3),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            ride.rideType == 'bike' ? Icons.pedal_bike : Icons.directions_car,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text('${ride.rideType.toUpperCase()} • ${ride.id}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
