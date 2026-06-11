import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Saved Places', style: AppTextStyles.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSavedPlace(
            title: 'Home',
            subtitle: 'Add home address',
            icon: Icons.home_outlined,
            isAdded: false,
          ),
          const SizedBox(height: 16),
          _buildSavedPlace(
            title: 'Work',
            subtitle: 'Tech Park, OMR, Chennai',
            icon: Icons.work_outline,
            isAdded: true,
          ),
          const SizedBox(height: 24),
          const Text('Other Places', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Icon(Icons.add_circle_outline, color: AppColors.primaryGreen, size: 28),
                const SizedBox(width: 16),
                Text('Add a new place', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryGreen)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPlace({required String title, required String subtitle, required IconData icon, required bool isAdded}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.caption.copyWith(color: isAdded ? AppColors.textSecondary : AppColors.primaryGreen)),
              ],
            ),
          ),
          if (isAdded)
            Icon(Icons.more_vert, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

