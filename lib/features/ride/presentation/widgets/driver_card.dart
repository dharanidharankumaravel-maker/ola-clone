import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/ride.dart';

class DriverCard extends StatelessWidget {
  final Driver driver;
  final String otp;
  final VoidCallback onCall;
  final VoidCallback onMessage;
  final VoidCallback onShareEta;

  const DriverCard({
    super.key,
    required this.driver,
    required this.otp,
    required this.onCall,
    required this.onMessage,
    required this.onShareEta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.bgSurface,
      child: Column(
        children: [
          Row(
            children: [
              // Driver Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.border,
                  image: driver.image.isNotEmpty
                      ? DecorationImage(image: NetworkImage(driver.image), fit: BoxFit.cover)
                      : null,
                ),
                child: driver.image.isEmpty
                    ? Icon(Icons.person, color: AppColors.textSecondary)
                    : null,
              ),
              const SizedBox(width: 16),
              // Driver Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        const SizedBox(width: 4),
                        Text(driver.rating.toString(), style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              // OTP Block
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text('OTP', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    Text(otp, style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen, letterSpacing: 2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Vehicle Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.vehicleNumber, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text(driver.vehicleModel, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                Icon(Icons.directions_car, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(Icons.call, 'Call', onCall),
              _buildActionButton(Icons.message, 'Message', onMessage),
              _buildActionButton(Icons.share, 'Share ETA', onShareEta),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgCard,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
