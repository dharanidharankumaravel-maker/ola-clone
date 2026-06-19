import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/map_repository_provider.dart';
import '../providers/location_provider.dart';
import '../../domain/entities/app_location.dart';

class MapPickerScreen extends ConsumerStatefulWidget {
  final bool isPickup;
  const MapPickerScreen({super.key, this.isPickup = true});

  @override
  ConsumerState<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends ConsumerState<MapPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _isDragging = false;
  bool _isFetchingReverseGeocode = false;
  Timer? _debounceTimer;
  AppLocation? _currentSelection;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onMapMoved(MapCamera position, bool hasGesture) {
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
        
        if (mounted) {
          setState(() {
            _currentSelection = address;
            if (address != null) {
              _searchController.text = address.shortAddress ?? '';
            }
            _isFetchingReverseGeocode = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationStreamProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            locationAsync.when(
              data: (location) {
                final initialPos = location != null
                    ? LatLng(location.latitude, location.longitude)
                    : const LatLng(13.0827, 80.2707);

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialPos,
                    initialZoom: 15,
                    onPositionChanged: _onMapMoved,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.ola.customer',
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
              error: (e, s) => const Center(child: Text('Error loading map')),
            ),
            
            // Search / Title Bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Search or move map',
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                          border: InputBorder.none,
                        ),
                        readOnly: true, // Only allows map movement for now
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Heart Button
            Positioned(
              top: 80,
              right: 16,
              child: Builder(
                builder: (context) {
                  final savedPlaces = ref.watch(savedPlacesProvider);
                  final locationToSave = _currentSelection;
                  final isSaved = locationToSave != null && savedPlaces.any((p) => 
                    p.location.latitude == locationToSave.latitude && 
                    p.location.longitude == locationToSave.longitude
                  );
                  
                  return GestureDetector(
                    onTap: () {
                      if (locationToSave != null) {
                        if (isSaved) {
                          final place = savedPlaces.firstWhere((p) => 
                            p.location.latitude == locationToSave.latitude && 
                            p.location.longitude == locationToSave.longitude
                          );
                          ref.read(savedPlacesProvider.notifier).removePlace(place);
                        } else {
                          ref.read(savedPlacesProvider.notifier).addPlace(
                            SavedPlace(
                              title: locationToSave.shortAddress ?? 'Saved Place',
                              subtitle: locationToSave.formattedAddress,
                              location: locationToSave,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Added to saved places!'), 
                              backgroundColor: AppColors.primaryGreen,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? Colors.red : AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  );
                }
              ),
            ),
            
            // Center Pin
            IgnorePointer(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
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
                          _isDragging ? 'Drop pin here' : (_isFetchingReverseGeocode ? 'Fetching...' : 'Select Location'),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        Icons.location_on,
                        size: 40,
                        color: _isDragging ? AppColors.textSecondary : (widget.isPickup ? AppColors.primaryGreen : Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -4))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _currentSelection?.formattedAddress ?? 'Move map to select a place',
                            style: AppTextStyles.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'Confirm Location',
                      onPressed: () {
                        if (_currentSelection != null) {
                          context.pop(_currentSelection);
                        }
                      },
                      disabled: _currentSelection == null || _isFetchingReverseGeocode,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
