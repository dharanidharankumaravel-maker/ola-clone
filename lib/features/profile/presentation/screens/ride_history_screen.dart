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
        return _ExpansionRideCard(
          ride: rides[index],
          isUpcoming: isUpcoming,
          ref: ref,
        );
      },
    );
  }
}

class _ExpansionRideCard extends StatelessWidget {
  final Ride ride;
  final bool isUpcoming;
  final WidgetRef ref;

  const _ExpansionRideCard({
    required this.ride,
    required this.isUpcoming,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
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
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(displayDate, style: AppTextStyles.bodyMedium),
                      if (ride.parcelDetails != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                          child: Text('Parcel', style: AppTextStyles.caption.copyWith(color: Colors.orange[800], fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
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
                  Text('₹${(ride.fareEstimate.total + (ride.tipAmount ?? 0)).toStringAsFixed(0)}', style: AppTextStyles.h3),
                ],
              ),
            ],
          ),
          children: [
            Divider(color: AppColors.border),
            const SizedBox(height: 12),
            _buildDetailRow('Trip ID', ride.id),
            _buildDetailRow(ride.parcelDetails != null ? 'Delivery Partner' : 'Driver Name', ride.driver?.name ?? 'N/A'),
            _buildDetailRow('Distance Travelled', '${ride.distance.toStringAsFixed(1)} km'),
            _buildDetailRow('Amount Paid', '₹${(ride.fareEstimate.total + (ride.tipAmount ?? 0)).toStringAsFixed(0)}'),
            if (ride.parcelDetails != null) ...[
              _buildDetailRow('Sender', ride.parcelDetails!.senderName),
              _buildDetailRow('Receiver', ride.parcelDetails!.receiverName),
              _buildDetailRow('Contents', ride.parcelDetails!.contents),
            ],
            _buildDetailRow('Payment Type', ride.paymentMethod.toUpperCase()),
            _buildDetailRow('Tip Offered', '₹${(ride.tipAmount ?? 0).toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading invoice...')),
                  );
                },
                icon: const Icon(Icons.download, color: AppColors.primaryGreen),
                label: const Text('Download Invoice', style: TextStyle(color: AppColors.primaryGreen)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            if (isScheduled) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    ref.read(scheduledRidesProvider.notifier).cancelRide(ride.id);
                  },
                  child: Text('Cancel Ride', style: AppTextStyles.caption.copyWith(color: AppColors.danger, fontWeight: FontWeight.bold)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
