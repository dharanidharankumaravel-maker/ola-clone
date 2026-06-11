import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for past rides
    final List<Map<String, dynamic>> rides = [
      {
        'id': 'CRN-89472',
        'date': 'Today, 10:45 AM',
        'status': 'Completed',
        'amount': '₹245',
        'pickup': 'Central Station',
        'drop': 'Express Avenue Mall',
        'vehicle': 'Prime Sedan',
      },
      {
        'id': 'CRN-89331',
        'date': 'Yesterday, 6:30 PM',
        'status': 'Cancelled',
        'amount': '₹0',
        'pickup': 'Tidel Park',
        'drop': 'Velachery',
        'vehicle': 'Mini',
      },
      {
        'id': 'CRN-89102',
        'date': '04 Jun, 9:15 AM',
        'status': 'Completed',
        'amount': '₹180',
        'pickup': 'Airport',
        'drop': 'Guindy',
        'vehicle': 'Bike',
      },
    ];

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
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rides.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final ride = rides[index];
          final isCompleted = ride['status'] == 'Completed';

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
                    Text(ride['date'], style: AppTextStyles.bodyMedium),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.primaryGreenLight : AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ride['status'],
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
                  child: Divider(color: AppColors.border),
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        Icon(Icons.circle, size: 12, color: AppColors.primaryGreen),
                        Container(height: 20, width: 2, color: AppColors.border),
                        Icon(Icons.location_on_outlined, size: 14, color: AppColors.danger),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ride['pickup'], style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 12),
                          Text(ride['drop'], style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                    Text(ride['amount'], style: AppTextStyles.h3),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      ride['vehicle'] == 'Bike'
                          ? Icons.pedal_bike
                          : Icons.directions_car,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text('${ride['vehicle']} • ${ride['id']}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
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

