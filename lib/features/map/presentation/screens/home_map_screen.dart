import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';

import 'dart:async';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/location_provider.dart';
import '../providers/map_repository_provider.dart';
import '../providers/ghost_cars_provider.dart';
import '../../../ride/presentation/providers/ride_provider.dart';

class HomeMapScreen extends ConsumerStatefulWidget {
  const HomeMapScreen({super.key});

  @override
  ConsumerState<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends ConsumerState<HomeMapScreen> {
  final MapController _mapController = MapController();
  bool _hasCentered = false;
  Timer? _debounceTimer;
  bool _isFetchingReverseGeocode = false;
  bool _isDragging = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocationAsync = ref.watch(locationStreamProvider);
    final locationState = ref.watch(locationProvider);
    final currentPickup = locationState.pickup;

    // Center camera on first location update
    currentLocationAsync.whenData((location) {
      if (location != null && !_hasCentered) {
        _hasCentered = true;
        try {
          _mapController.move(
            LatLng(location.latitude, location.longitude),
            15,
          );
        } catch (_) {}
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: Stack(
        children: [
          // 1. The Map
          currentLocationAsync.when(
            data: (location) {
              final initialPos = location != null
                  ? LatLng(location.latitude, location.longitude)
                  : const LatLng(13.0827, 80.2707); // Default to Chennai

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialPos,
                  initialZoom: 15,
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture) {
                      if (!_isDragging) {
                        setState(() => _isDragging = true);
                      }
                      
                      _debounceTimer?.cancel();
                      _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
                        if (!mounted) return;
                        setState(() {
                          _isDragging = false;
                          _isFetchingReverseGeocode = true;
                        });
                        
                        final repo = ref.read(mapRepositoryProvider);
                        final center = _mapController.camera.center;
                        final address = await repo.getReverseGeocode(center.latitude, center.longitude);
                        
                        if (mounted && address != null) {
                          ref.read(locationProvider.notifier).setPickup(address);
                        }
                        
                        if (mounted) {
                          setState(() => _isFetchingReverseGeocode = false);
                        }
                      });
                    }
                  },
                  onMapReady: () {
                    if (location != null && !_hasCentered) {
                      _hasCentered = true;
                      _mapController.move(
                        LatLng(location.latitude, location.longitude),
                        15,
                      );
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.ola.customer',
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final ghostCars = ref.watch(ghostCarsProvider);
                      return MarkerLayer(
                        markers: ghostCars.map((car) {
                          return Marker(
                            point: LatLng(car.latitude, car.longitude),
                            width: 32,
                            height: 32,
                            child: Transform.rotate(
                              angle: car.heading * 3.14159 / 180,
                              child: Image.asset('assets/car_top.png', 
                                errorBuilder: (_,__,___) => Icon(Icons.directions_car, color: AppColors.textSecondary, size: 24),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  // User's blue dot
                  if (location != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(location.latitude, location.longitude),
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withOpacity(0.2),
                            ),
                            child: const Center(
                              child: Icon(Icons.my_location, color: Colors.blue, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
            error: (e, s) => Center(child: Text('Error getting location: $e')),
          ),

          // 2. Top Bar Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _buildCircularButton(
                  icon: Icons.menu,
                  onTap: () {
                    context.push('/profile');
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(selectedRideTypeProvider.notifier).update(null);
                      context.push('/destination-search', extra: true);
                    },
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isDragging || _isFetchingReverseGeocode 
                                ? 'Fetching location...' 
                                : (currentPickup?.shortAddress ?? currentLocationAsync.value?.shortAddress ?? 'Fetching location...'),
                              style: AppTextStyles.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Center Pin (Drag to select location)
          IgnorePointer(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40), // offset by half icon height to put tip on center
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isDragging ? 'Drop pin here' : 'Pick up here',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.location_on,
                      size: 40,
                      color: _isDragging ? AppColors.textSecondary : AppColors.primaryGreen,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Bottom Sheet Overlay
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.45,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (currentPickup == null && currentLocationAsync.value != null) {
                          ref.read(locationProvider.notifier).setPickup(currentLocationAsync.value!);
                        }
                        ref.read(selectedRideTypeProvider.notifier).update(null);
                        context.push('/destination-search', extra: false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.primaryGreen, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: AppColors.textPrimary),
                            const SizedBox(width: 12),
                            Text('Enter Destination', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCategory('assets/image 24.png', Icons.directions_car, 'Daily', onTap: () {
                          if (currentPickup == null && currentLocationAsync.value != null) {
                            ref.read(locationProvider.notifier).setPickup(currentLocationAsync.value!);
                          }
                          ref.read(selectedRideCategoryProvider.notifier).update('daily');
                          ref.read(selectedRideTypeProvider.notifier).update(null);
                          context.push('/destination-search', extra: false);
                        }),
                        _buildCategory(null, Icons.key, 'Rentals', onTap: () {
                          if (currentPickup == null && currentLocationAsync.value != null) {
                            ref.read(locationProvider.notifier).setPickup(currentLocationAsync.value!);
                          }
                          ref.read(selectedRideCategoryProvider.notifier).update('rentals');
                          ref.read(selectedRideTypeProvider.notifier).update(null);
                          context.push('/destination-search', extra: false);
                        }),
                        _buildCategory(null, Icons.map_outlined, 'Outstation', onTap: () {
                          if (currentPickup == null && currentLocationAsync.value != null) {
                            ref.read(locationProvider.notifier).setPickup(currentLocationAsync.value!);
                          }
                          ref.read(selectedRideCategoryProvider.notifier).update('outstation');
                          ref.read(selectedRideTypeProvider.notifier).update(null);
                          context.push('/destination-search', extra: false);
                        }),
                        _buildCategory(null, Icons.inventory_2_outlined, 'Parcel', onTap: () {
                          context.push('/parcel');
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildRecentSearch('Central Station', 'Park Town, Chennai', true, () {
                            if (currentPickup == null && currentLocationAsync.value != null) {
                              ref.read(locationProvider.notifier).setPickup(currentLocationAsync.value!);
                            }
                            context.push('/destination-search', extra: false);
                          }),
                          _buildRecentSearch('Airport', 'Meenambakkam, Chennai', false, () {
                            if (currentPickup == null && currentLocationAsync.value != null) {
                              ref.read(locationProvider.notifier).setPickup(currentLocationAsync.value!);
                            }
                            context.push('/destination-search', extra: false);
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildCategory(String? assetPath, IconData fallbackIcon, String title, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: assetPath != null
                  ? Image.asset(assetPath, width: 44, height: 44, fit: BoxFit.contain)
                  : Icon(fallbackIcon, color: AppColors.primaryGreen, size: 28),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRecentSearch(String title, String subtitle, bool showDivider, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: showDivider ? null : const BorderRadius.vertical(bottom: Radius.circular(12)),
          border: showDivider ? Border(bottom: BorderSide(color: AppColors.border)) : null,
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

