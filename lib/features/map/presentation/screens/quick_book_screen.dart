import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/location_provider.dart';
import '../../domain/entities/app_location.dart';
import '../../../ride/presentation/providers/ride_provider.dart';

class QuickBookScreen extends ConsumerStatefulWidget {
  const QuickBookScreen({super.key});

  @override
  ConsumerState<QuickBookScreen> createState() => _QuickBookScreenState();
}

class _QuickBookScreenState extends ConsumerState<QuickBookScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentLocationAsync = ref.read(locationStreamProvider);
      final locationState = ref.read(locationProvider);
      
      if (locationState.pickup == null && currentLocationAsync.value != null) {
        ref.read(locationProvider.notifier).setPickup(currentLocationAsync.value!);
      }
    });
  }

  void _handleSelectDestination(AppLocation place) {
    ref.read(locationProvider.notifier).setDestination(place);
    ref.read(selectedRideCategoryProvider.notifier).update('daily');
    ref.read(selectedRideTypeProvider.notifier).update(null);
    context.pushReplacement('/ride-selection');
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final currentLocationAsync = ref.watch(locationStreamProvider);
    final savedPlaces = ref.watch(savedPlacesProvider);
    
    final currentPickup = locationState.pickup ?? currentLocationAsync.value;

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Quick Book', style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Location (Pickup)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Location', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(
                            currentPickup?.shortAddress ?? 'Fetching location...',
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Where to?', style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary)),
            ),

            // Saved and Recent Places
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (savedPlaces.isNotEmpty) ...[
                    Text('Saved Places', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    ...savedPlaces.map((place) => _buildPlaceItem(
                      title: place.title,
                      subtitle: place.subtitle ?? '',
                      icon: Icons.favorite,
                      iconColor: Colors.red,
                      onTap: () => _handleSelectDestination(place.location),
                    )),
                    const SizedBox(height: 24),
                  ],
                  
                  Text('Recent Places', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  // Mock Recent Places
                  _buildPlaceItem(
                    title: 'Central Station',
                    subtitle: 'Park Town, Chennai',
                    icon: Icons.history,
                    iconColor: AppColors.textSecondary,
                    onTap: () {
                      _handleSelectDestination(AppLocation(
                        latitude: 13.0827,
                        longitude: 80.2707,
                        shortAddress: 'Central Station',
                        formattedAddress: 'Park Town, Chennai',
                      ));
                    },
                  ),
                  _buildPlaceItem(
                    title: 'Airport',
                    subtitle: 'Meenambakkam, Chennai',
                    icon: Icons.history,
                    iconColor: AppColors.textSecondary,
                    onTap: () {
                      _handleSelectDestination(AppLocation(
                        latitude: 12.9716,
                        longitude: 80.1898,
                        shortAddress: 'Airport',
                        formattedAddress: 'Meenambakkam, Chennai',
                      ));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}
