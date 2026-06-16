import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../ride/presentation/providers/ride_provider.dart';
import '../../../ride/domain/entities/ride.dart';

class RideHistoryScreen extends ConsumerStatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  ConsumerState<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends ConsumerState<RideHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pastRides = ref.watch(rideHistoryProvider);
    final upcomingRides = ref.watch(scheduledRidesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Your Rides', style: AppTextStyles.h3),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGreen,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Past'),
            Tab(text: 'Upcoming'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRideList(pastRides, isUpcoming: false),
          _buildRideList(upcomingRides, isUpcoming: true),
        ],
      ),
    );
  }

  Widget _buildRideList(List<Ride> rides, {required bool isUpcoming}) {
    if (rides.isEmpty) {
      return Center(
        child: Text(
          isUpcoming ? 'No upcoming rides' : 'No past rides',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rides.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final ride = rides[index];
        final isCompleted = ride.status == 'completed';
        final isScheduled = ride.status == 'scheduled';
        
        String displayDate = ride.createdAt;
        if (isScheduled && ride.scheduledAt != null) {
          try {
            final dt = DateTime.parse(ride.scheduledAt!);
            displayDate = DateFormat('MMM dd, yyyy • hh:mm a').format(dt);
          } catch (_) {}
        }

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
                  Text(displayDate, style: AppTextStyles.bodyMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.primaryGreenLight : (isScheduled ? Colors.blue.withOpacity(0.15) : AppColors.dangerLight),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isScheduled ? 'Scheduled' : (isCompleted ? 'Completed' : 'Cancelled'),
                      style: AppTextStyles.caption.copyWith(
                        color: isCompleted ? AppColors.primaryGreen : (isScheduled ? Colors.blue : AppColors.danger),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: AppColors.border),
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Icon(Icons.circle, size: 12, color: AppColors.primaryGreen),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  if (isScheduled)
                    GestureDetector(
                      onTap: () {
                        ref.read(scheduledRidesProvider.notifier).cancelRide(ride.id);
                      },
                      child: Text('Cancel', style: AppTextStyles.caption.copyWith(color: AppColors.danger, fontWeight: FontWeight.bold)),
                    )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
