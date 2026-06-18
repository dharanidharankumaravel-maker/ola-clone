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
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_animate/flutter_animate.dart';

class HomeMapScreen extends ConsumerStatefulWidget {
  const HomeMapScreen({super.key});

  @override
  ConsumerState<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends ConsumerState<HomeMapScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController _mapController = MapController();
  bool _hasCentered = false;
  Timer? _debounceTimer;
  bool _isFetchingReverseGeocode = false;
  String _selectedHomeCategory = 'Daily';
  bool _isDragging = false;
  bool _highlightDestination = false;

  void _triggerDestinationPrompt(String categoryName) {
    if (ref.read(locationProvider).destination == null) {
      setState(() {
        _highlightDestination = true;
      });
      
      // Auto-open the destination search screen (or parcel) to save a click
      if (categoryName == 'Parcel') {
        context.push('/parcel');
      } else {
        context.push('/destination-search', extra: false);
      }
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _highlightDestination = false;
          });
        }
      });
    } else {
      // Destination is already set, so tapping the vehicle should take us to confirmation!
      if (categoryName == 'Parcel') {
        context.push('/parcel');
      } else {
        context.push('/ride-selection');
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      key: _scaffoldKey,
      backgroundColor: AppColors.bgSurface,
      drawer: _buildDrawer(),
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
                    _scaffoldKey.currentState?.openDrawer();
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
                    Animate(
                      key: ValueKey(_highlightDestination),
                      effects: _highlightDestination ? [
                        const ShakeEffect(duration: Duration(milliseconds: 500), hz: 6),
                        const ScaleEffect(duration: Duration(milliseconds: 150), begin: Offset(1.0, 1.0), end: Offset(1.02, 1.02)),
                      ] : [],
                      child: GestureDetector(
                        onTap: () {
                          if (currentPickup == null && currentLocationAsync.value != null) {
                            ref.read(locationProvider.notifier).setPickup(currentLocationAsync.value!);
                          }
                          
                          switch (_selectedHomeCategory) {
                            case 'Daily':
                              ref.read(selectedRideCategoryProvider.notifier).update('daily');
                              ref.read(selectedRideTypeProvider.notifier).update(null);
                              break;
                            case 'Bike':
                              ref.read(selectedRideCategoryProvider.notifier).update('daily');
                              ref.read(selectedRideTypeProvider.notifier).update('bike');
                              break;
                            case 'Auto':
                              ref.read(selectedRideCategoryProvider.notifier).update('daily');
                              ref.read(selectedRideTypeProvider.notifier).update('auto');
                              break;
                            case 'Scooter':
                              ref.read(selectedRideCategoryProvider.notifier).update('daily');
                              ref.read(selectedRideTypeProvider.notifier).update('scooter');
                              break;
                            case 'Rentals':
                              ref.read(selectedRideCategoryProvider.notifier).update('rentals');
                              ref.read(selectedRideTypeProvider.notifier).update(null);
                              break;
                            case 'Outstation':
                              ref.read(selectedRideCategoryProvider.notifier).update('outstation');
                              ref.read(selectedRideTypeProvider.notifier).update(null);
                              break;
                            case 'Parcel':
                              ref.read(selectedRideCategoryProvider.notifier).update('parcel');
                              ref.read(selectedRideTypeProvider.notifier).update(null);
                              break;
                          }
                          
                          if (_selectedHomeCategory == 'Parcel') {
                            context.push('/parcel');
                          } else {
                            context.push('/destination-search', extra: false);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.bgSurface,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: _highlightDestination ? AppColors.accentOrange : AppColors.primaryGreen, 
                              width: _highlightDestination ? 2.5 : 1.5
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_highlightDestination ? AppColors.accentOrange : AppColors.primaryGreen).withOpacity(_highlightDestination ? 0.3 : 0.1),
                                blurRadius: _highlightDestination ? 12 : 4,
                                spreadRadius: _highlightDestination ? 2 : 0,
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
                    ),
                    const SizedBox(height: 24),
  
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildCategory('assets/daily.png', Icons.directions_car, 'Daily', isSelected: _selectedHomeCategory == 'Daily', onTap: () {
                            setState(() => _selectedHomeCategory = 'Daily');
                            _triggerDestinationPrompt('Daily');
                          }),
                          _buildCategory('assets/bike_icon.png', Icons.motorcycle, 'Bike', isSelected: _selectedHomeCategory == 'Bike', onTap: () {
                            setState(() => _selectedHomeCategory = 'Bike');
                            _triggerDestinationPrompt('Bike');
                          }),
                          _buildCategory('assets/auto_icon.png', Icons.electric_rickshaw, 'Auto', isSelected: _selectedHomeCategory == 'Auto', onTap: () {
                            setState(() => _selectedHomeCategory = 'Auto');
                            _triggerDestinationPrompt('Auto');
                          }),
                          _buildCategory('assets/scooter_icon.png', Icons.moped, 'Scooter', isSelected: _selectedHomeCategory == 'Scooter', onTap: () {
                            setState(() => _selectedHomeCategory = 'Scooter');
                            _triggerDestinationPrompt('Scooter');
                          }),
                          _buildCategory('assets/rental_icon.png', Icons.key, 'Rentals', isSelected: _selectedHomeCategory == 'Rentals', onTap: () {
                            setState(() => _selectedHomeCategory = 'Rentals');
                            _triggerDestinationPrompt('Rentals');
                          }),
                          _buildCategory('assets/outstation_icon.png', Icons.map_outlined, 'Outstation', isSelected: _selectedHomeCategory == 'Outstation', onTap: () {
                            setState(() => _selectedHomeCategory = 'Outstation');
                            _triggerDestinationPrompt('Outstation');
                          }),
                          _buildCategory('assets/parcel.svg', Icons.inventory_2_outlined, 'Parcel', isSelected: _selectedHomeCategory == 'Parcel', onTap: () {
                            setState(() => _selectedHomeCategory = 'Parcel');
                            _triggerDestinationPrompt('Parcel');
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
  
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      alignment: Alignment.center,
                      child: Text(
                        '#AloOnTheMove',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.primaryGreen.withOpacity(0.8),
                          letterSpacing: 1.2,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/ola_banner.jpg',
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/ola_on_the_move.jpg',
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/ola_ride_save.png',
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(),
                      ),
                    ),
                    const SizedBox(height: 24),
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

  Widget _buildCategory(String imagePath, IconData icon, String label, {required bool isSelected, required VoidCallback onTap}) {
    final double imageScale;
    if (label == 'Parcel') {
      imageScale = 0.8;
    } else {
      imageScale = 1.0;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 72,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreenLight.withOpacity(0.3) : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.border, width: isSelected ? 2 : 1),
              ),
              child: Center(
                child: Transform.scale(
                  scale: imageScale,
                  alignment: Alignment.center,
                  child: imagePath.endsWith('.svg') 
                      ? SvgPicture.asset(
                          imagePath, 
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        )
                      : (imagePath.isNotEmpty 
                          ? Image.asset(
                              imagePath, 
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              errorBuilder: (context, error, stackTrace) => Icon(icon, size: 36, color: AppColors.textSecondary),
                            )
                          : Icon(icon, size: 36, color: AppColors.textSecondary)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.caption.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
            ), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
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

  Widget _buildDrawer() {
    final user = ref.watch(authProvider).value;
    
    return Drawer(
      backgroundColor: AppColors.bgSurface,
      child: SafeArea(
        child: Column(
          children: [
            // Profile Header
            InkWell(
              onTap: () {
                context.pop(); // Close drawer
                context.push('/profile');
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryGreenLight,
                        border: Border.all(color: AppColors.primaryGreen, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: user?.profilePhoto != null
                          ? ClipOval(
                              child: Image.network(
                                user!.profilePhoto!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text(
                              user?.name?.isNotEmpty == true ? user!.name![0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.name ?? 'Set your name', style: AppTextStyles.h3),
                          const SizedBox(height: 4),
                          Text(user?.phone ?? '', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(Icons.history, 'Ride History', () {
                    context.pop();
                    context.push('/ride-history');
                  }),
                  _buildDrawerItem(Icons.account_balance_wallet_outlined, 'Alo Wallet', () {
                    context.pop();
                    context.push('/wallet');
                  }),
                  _buildDrawerItem(Icons.inventory_2_outlined, 'Alo Parcel', () {
                    context.pop();
                    context.push('/parcel');
                  }),
                  _buildDrawerItem(Icons.location_on_outlined, 'Saved Places', () {
                    context.pop();
                    context.push('/saved-places');
                  }),
                  _buildDrawerItem(Icons.headset_mic_outlined, 'Help & Support', () {
                    context.pop();
                    context.push('/support');
                  }),
                  _buildDrawerItem(Icons.settings_outlined, 'Settings', () {
                    context.pop();
                    context.push('/settings');
                  }),
                ],
              ),
            ),
            
            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('App Version 1.0.0', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 24),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}

