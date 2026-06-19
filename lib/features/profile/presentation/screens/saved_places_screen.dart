import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../map/domain/entities/app_location.dart';
import '../../../map/presentation/providers/location_provider.dart';

class SavedPlacesScreen extends ConsumerWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedPlaces = ref.watch(savedPlacesProvider);
    final homePlace = savedPlaces.where((p) => p.title.toLowerCase() == 'home').firstOrNull;
    final workPlace = savedPlaces.where((p) => p.title.toLowerCase() == 'work').firstOrNull;
    final otherPlaces = savedPlaces.where((p) => p.title.toLowerCase() != 'home' && p.title.toLowerCase() != 'work').toList();

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgSurface,
        appBar: AppBar(
          backgroundColor: AppColors.bgSurface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
        title: const Text('Saved Places', style: AppTextStyles.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSavedPlace(
            title: 'Home',
            subtitle: homePlace?.subtitle ?? 'Add home address',
            icon: Icons.home_outlined,
            isAdded: homePlace != null,
            onDelete: homePlace != null ? () => ref.read(savedPlacesProvider.notifier).removePlace(homePlace) : null,
          ),
          const SizedBox(height: 16),
          _buildSavedPlace(
            title: 'Work',
            subtitle: workPlace?.subtitle ?? 'Add work address',
            icon: Icons.work_outline,
            isAdded: workPlace != null,
            onDelete: workPlace != null ? () => ref.read(savedPlacesProvider.notifier).removePlace(workPlace) : null,
          ),
          const SizedBox(height: 24),
          const Text('Other Places', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 16),
          
          ...otherPlaces.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildSavedPlace(
              title: p.title,
              subtitle: p.subtitle ?? '',
              icon: Icons.location_on_outlined,
              isAdded: true,
              onDelete: () => ref.read(savedPlacesProvider.notifier).removePlace(p),
            ),
          )),
          
          GestureDetector(
            onTap: () async {
              final result = await context.push<AppLocation>('/map-picker');
              if (result != null) {
                ref.read(savedPlacesProvider.notifier).addPlace(
                  SavedPlace(
                    title: result.shortAddress ?? 'Saved Place',
                    subtitle: result.formattedAddress,
                    location: result,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('New place saved!'), backgroundColor: AppColors.primaryGreen),
                );
              }
            },
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
    ));
  }

  Widget _buildSavedPlace({required String title, required String subtitle, required IconData icon, required bool isAdded, VoidCallback? onDelete}) {
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
            PopupMenuButton(
              icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
              color: AppColors.bgSurface,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Text('Remove', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete' && onDelete != null) {
                  onDelete();
                }
              },
            ),
        ],
      ),
    );
  }
}
