import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../map/presentation/providers/location_provider.dart';
import '../../../map/presentation/providers/map_repository_provider.dart';
import '../providers/ride_provider.dart';
import '../../domain/entities/ride_option.dart';

class RideSelectionScreen extends ConsumerStatefulWidget {
  const RideSelectionScreen({super.key});

  @override
  ConsumerState<RideSelectionScreen> createState() => _RideSelectionScreenState();
}

class _RideSelectionScreenState extends ConsumerState<RideSelectionScreen> {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  void _selectCategory(String category, List<RideOption> allOptions) {
    ref.read(selectedRideCategoryProvider.notifier).update(category);
    
    final filtered = allOptions.where((option) {
      if (category == 'rentals') {
        return option.type.startsWith('rentals_');
      } else if (category == 'outstation') {
        return option.type.startsWith('outstation_');
      } else {
        return !option.type.startsWith('rentals_') && !option.type.startsWith('outstation_');
      }
    }).toList();
    
    if (filtered.isNotEmpty) {
      ref.read(selectedRideTypeProvider.notifier).update(filtered[0].type);
    }
  }

  Widget _buildCategoryTab(String title, String category, List<RideOption> allOptions, String selectedCategory) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _selectCategory(category, allOptions);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreenLight : AppColors.bgCard,
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _fitMapToRoute() {
    if (_routePoints.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(_routePoints);
      _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
    }
  }

  Future<void> _loadRoute() async {
    final locationState = ref.read(locationProvider);
    final pickup = locationState.pickup;
    final destination = locationState.destination;
    if (pickup != null && destination != null) {
      final repo = ref.read(mapRepositoryProvider);
      final points = await repo.getRoutePolylines(
        LatLng(pickup.latitude, pickup.longitude),
        LatLng(destination.latitude, destination.longitude),
      );
      if (mounted) {
        setState(() {
          _routePoints = points;
        });
        _fitMapToRoute();
        
        // Dynamic fare calculation
        double totalMeters = 0;
        final distanceCalc = const Distance();
        for (int i = 0; i < points.length - 1; i++) {
          totalMeters += distanceCalc.distance(points[i], points[i+1]);
        }
        // Increase raw polyline distance slightly to account for real road curves if straight line
        final double distanceKm = (totalMeters > 0 ? (totalMeters * 1.2) / 1000 : 5.2).clamp(1.0, 500.0);
        final int durationMins = (distanceKm * 3.5).ceil();

        _generateDynamicOptions(distanceKm, durationMins);
      }
    } else {
      _generateDynamicOptions(5.2, 15);
    }
  }

  void _generateDynamicOptions(double distance, int duration) {
    ref.read(isEstimatingProvider.notifier).update(true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final options = <RideOption>[];
      
      if (distance < 100) {
        options.addAll([
          RideOption(
            type: 'micro',
            name: 'Alo Micro',
            description: 'Compact hatchbacks, pocket-friendly',
            icon: 'assets/micro_icon.png',
            seats: 4,
            available: true,
            eta: 3,
            fareEstimate: FareEstimate(
              baseFare: 40,
              distanceFare: distance * 10,
              timeFare: duration * 1.5,
              surgeMultiplier: 1,
              total: 40 + (distance * 10) + (duration * 1.5),
              currency: 'INR',
              distance: distance,
              duration: duration,
            ),
          ),
          RideOption(
            type: 'mini',
            name: 'Alo Mini',
            description: 'Comfy, economical hatchbacks',
            icon: 'assets/mini_icon.png',
            seats: 4,
            available: true,
            eta: 3,
            fareEstimate: FareEstimate(
              baseFare: 50,
              distanceFare: distance * 12,
              timeFare: duration * 1.5,
              surgeMultiplier: 1,
              total: 50 + (distance * 12) + (duration * 1.5),
              currency: 'INR',
              distance: distance,
              duration: duration,
            ),
          ),
          RideOption(
            type: 'prime',
            name: 'Prime Sedan',
            description: 'Spacious, top-rated sedans',
            icon: 'assets/prime_sedan_icon.png',
            seats: 4,
            available: true,
            eta: 5,
            fareEstimate: FareEstimate(
              baseFare: 70,
              distanceFare: distance * 15,
              timeFare: duration * 2.0,
              surgeMultiplier: 1,
              total: 70 + (distance * 15) + (duration * 2.0),
              currency: 'INR',
              distance: distance,
              duration: duration,
            ),
          ),
          RideOption(
            type: 'suv',
            name: 'Prime SUV',
            description: 'Spacious SUVs for family trips',
            icon: 'assets/prime_suv.png',
            seats: 6,
            available: true,
            eta: 6,
            fareEstimate: FareEstimate(
              baseFare: 100,
              distanceFare: distance * 20,
              timeFare: duration * 2.5,
              surgeMultiplier: 1,
              total: 100 + (distance * 20) + (duration * 2.5),
              currency: 'INR',
              distance: distance,
              duration: duration,
            ),
          ),
          RideOption(
            type: 'auto',
            name: 'Alo Auto',
            description: 'Auto rickshaw at your doorstep',
            icon: 'assets/auto_icon.png',
            seats: 3,
            available: true,
            eta: 4,
            fareEstimate: FareEstimate(
              baseFare: 30,
              distanceFare: distance * 8,
              timeFare: duration * 1.0,
              surgeMultiplier: 1,
              total: 30 + (distance * 8) + (duration * 1.0),
              currency: 'INR',
              distance: distance,
              duration: duration,
            ),
          ),
          RideOption(
            type: 'bike',
            name: 'Alo Bike',
            description: 'Quick and economical bike rides',
            icon: 'assets/bike_icon.png',
            seats: 1,
            available: true,
            eta: 2,
            fareEstimate: FareEstimate(
              baseFare: 20,
              distanceFare: distance * 6,
              timeFare: duration * 1.0,
              surgeMultiplier: 1,
              total: 20 + (distance * 6) + (duration * 1.0),
              currency: 'INR',
              distance: distance,
              duration: duration,
            ),
          ),
          RideOption(
            type: 'scooter',
            name: 'Alo Scooter',
            description: 'Beat the traffic on a scooter',
            icon: 'assets/scooter_icon.png',
            seats: 1,
            available: true,
            eta: 3,
            fareEstimate: FareEstimate(
              baseFare: 25,
              distanceFare: distance * 7,
              timeFare: duration * 1.0,
              surgeMultiplier: 1,
              total: 25 + (distance * 7) + (duration * 1.0),
              currency: 'INR',
              distance: distance,
              duration: duration,
            ),
          ),
        ]);
      }
          
      // Rentals options
      if (distance < 50) {
        options.addAll([
          RideOption(
            type: 'rentals_micro',
            name: 'Rentals Micro',
            description: '1 Hr • 10 Km Package',
            icon: 'assets/micro_icon.png',
            seats: 4,
            available: true,
            eta: 5,
            fareEstimate: FareEstimate(
              baseFare: 200,
              distanceFare: 0,
              timeFare: 0,
              surgeMultiplier: 1,
              total: 250,
              currency: 'INR',
              distance: distance,
              duration: duration,
            ),
          ),
          RideOption(
            type: 'rentals_mini',
            name: 'Rentals Mini',
            description: '2 Hr • 20 Km Package',
            icon: 'assets/mini_icon.png',
            seats: 4,
            available: true,
            eta: 4,
            fareEstimate: FareEstimate(
              baseFare: 350,
              distanceFare: 0,
              timeFare: 0,
              surgeMultiplier: 1,
              total: 450,
              currency: 'INR',
              distance: distance,
              duration: duration,
            ),
          ),
          RideOption(
            type: 'rentals_prime',
            name: 'Rentals Sedan',
            description: '4 Hr • 40 Km Package',
            icon: 'assets/prime_sedan_icon.png',
            seats: 4,
            available: true,
            eta: 6,
            fareEstimate: FareEstimate(
              baseFare: 700,
              distanceFare: 0,
              timeFare: 0,
              surgeMultiplier: 1,
              total: 800,
              currency: 'INR',
              distance: distance,
              duration: duration,
            ),
          ),
          RideOption(
            type: 'rentals_suv',
            name: 'Rentals SUV',
            description: '8 Hr • 80 Km Package',
            icon: 'assets/prime_suv.png',
            seats: 6,
            available: true,
            eta: 7,
            fareEstimate: FareEstimate(
              baseFare: 1300,
              distanceFare: 0,
              timeFare: 0,
              surgeMultiplier: 1,
              total: 1500,
              currency: 'INR',
              distance: distance,
              duration: duration,
            ),
          ),
        ]);
      }
          
      // Outstation options
      if (distance >= 40) {
        options.addAll([
          RideOption(
            type: 'outstation_mini',
            name: 'Outstation Mini',
            description: 'Intercity hatchback, pocket-friendly',
            icon: 'assets/mini_icon.png',
            seats: 4,
            available: true,
            eta: 15,
            fareEstimate: FareEstimate(
              baseFare: 1000,
              distanceFare: distance > 20 ? (distance - 20) * 15 : 0,
              timeFare: 0,
              surgeMultiplier: 1,
              total: 1000 + (distance > 20 ? (distance - 20) * 15 : 0),
              currency: 'INR',
              distance: distance,
              duration: duration,
            ),
          ),
          RideOption(
            type: 'outstation_prime',
            name: 'Outstation Sedan',
            description: 'Comfortable sedan for long journeys',
            icon: 'assets/prime_sedan_icon.png',
            seats: 4,
            available: true,
            eta: 12,
            fareEstimate: FareEstimate(
              baseFare: 1500,
              distanceFare: distance > 20 ? (distance - 20) * 18 : 0,
              timeFare: 0,
              surgeMultiplier: 1,
              total: 1500 + (distance > 20 ? (distance - 20) * 18 : 0),
              currency: 'INR',
              distance: distance,
              duration: duration,
            ),
          ),
          RideOption(
            type: 'outstation_suv',
            name: 'Outstation SUV',
            description: 'Spacious SUV for intercity family travel',
            icon: 'assets/prime_suv.png',
            seats: 6,
            available: true,
            eta: 18,
            fareEstimate: FareEstimate(
              baseFare: 2200,
              distanceFare: distance > 20 ? (distance - 20) * 25 : 0,
              timeFare: 0,
              surgeMultiplier: 1,
              total: 2200 + (distance > 20 ? (distance - 20) * 25 : 0),
              currency: 'INR',
              distance: distance,
              duration: duration,
            ),
          ),
        ]);
      }
        
        final existingCategory = ref.read(selectedRideCategoryProvider);
        final hasDaily = options.any((o) => !o.type.startsWith('rentals_') && !o.type.startsWith('outstation_') && o.type != 'parcel');
        final hasRentals = options.any((o) => o.type.startsWith('rentals_'));
        final hasOutstation = options.any((o) => o.type.startsWith('outstation_'));
        
        if (existingCategory == 'outstation' && !hasOutstation) {
          ref.read(selectedRideCategoryProvider.notifier).update(hasDaily ? 'daily' : (hasRentals ? 'rentals' : 'daily'));
        } else if (existingCategory == 'rentals' && !hasRentals) {
          ref.read(selectedRideCategoryProvider.notifier).update(hasDaily ? 'daily' : (hasOutstation ? 'outstation' : 'daily'));
        } else if (existingCategory == 'daily' && !hasDaily) {
          ref.read(selectedRideCategoryProvider.notifier).update(hasOutstation ? 'outstation' : (hasRentals ? 'rentals' : 'outstation'));
        }
        
        final existingType = ref.read(selectedRideTypeProvider);
        if (existingType != null && existingType.isNotEmpty) {
          final selectedIndex = options.indexWhere((o) => o.type == existingType);
          if (selectedIndex != -1) {
            final selectedOption = options.removeAt(selectedIndex);
            options.insert(0, selectedOption);
            ref.read(rideOptionsProvider.notifier).update(options);
            ref.read(isEstimatingProvider.notifier).update(false);
            return;
          }
        }
        
        ref.read(rideOptionsProvider.notifier).update(options);
        ref.read(selectedRideTypeProvider.notifier).update(options[0].type);
        ref.read(isEstimatingProvider.notifier).update(false);
      });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoute();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final rideOptions = ref.watch(rideOptionsProvider);
    final selectedRideType = ref.watch(selectedRideTypeProvider);
    final isEstimating = ref.watch(isEstimatingProvider);
    final promoDiscount = ref.watch(promoDiscountProvider);
    final paymentMethod = ref.watch(paymentMethodProvider);

    final selectedCategory = ref.watch(selectedRideCategoryProvider);

    final filteredOptions = rideOptions.where((option) {
      if (selectedCategory == 'rentals') {
        return option.type.startsWith('rentals_');
      } else if (selectedCategory == 'outstation') {
        return option.type.startsWith('outstation_');
      } else {
        return !option.type.startsWith('rentals_') && !option.type.startsWith('outstation_');
      }
    }).toList();

    final pickup = locationState.pickup;
    final destination = locationState.destination;

    if (pickup != null && destination != null) {
      final bounds = LatLngBounds.fromPoints([
        LatLng(pickup.latitude, pickup.longitude),
        LatLng(destination.latitude, destination.longitude),
      ]);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)));
        } catch (_) {}
      });
    }

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                pickup?.latitude ?? 13.0827,
                pickup?.longitude ?? 80.2707,
              ),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ola.customer',
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: AppColors.primaryGreen,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (pickup != null)
                    Marker(
                      point: LatLng(pickup.latitude, pickup.longitude),
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.green, size: 40),
                    ),
                  if (destination != null)
                    Marker(
                      point: LatLng(destination.latitude, destination.longitude),
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Builder(
              builder: (context) {
                final savedPlaces = ref.watch(savedPlacesProvider);
                final locationToSave = destination;
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
                            content: const Text('Destination added to saved places!'), 
                            backgroundColor: AppColors.primaryGreen,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: isSaved ? Colors.red : AppColors.textPrimary,
                    ),
                  ),
                );
              }
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.5,
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
                child: isEstimating
                    ? ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                        itemCount: 4,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: AppColors.border.withOpacity(0.5));
                        },
                      )
                    : Column(
                        children: [
                          if (rideOptions.length > 1)
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: AppColors.border)),
                              ),
                              child: Builder(
                                builder: (context) {
                                  final hasDaily = rideOptions.any((o) => !o.type.startsWith('rentals_') && !o.type.startsWith('outstation_') && o.type != 'parcel');
                                  final hasRentals = rideOptions.any((o) => o.type.startsWith('rentals_'));
                                  final hasOutstation = rideOptions.any((o) => o.type.startsWith('outstation_'));
                                  
                                  List<Widget> tabs = [];
                                  if (hasDaily) tabs.add(Expanded(child: _buildCategoryTab('Daily', 'daily', rideOptions, selectedCategory)));
                                  if (hasRentals) tabs.add(Expanded(child: _buildCategoryTab('Rentals', 'rentals', rideOptions, selectedCategory)));
                                  if (hasOutstation) tabs.add(Expanded(child: _buildCategoryTab('Outstation', 'outstation', rideOptions, selectedCategory)));
                                  
                                  List<Widget> rowChildren = [];
                                  for (int i = 0; i < tabs.length; i++) {
                                    rowChildren.add(tabs[i]);
                                    if (i < tabs.length - 1) rowChildren.add(const SizedBox(width: 8));
                                  }
                                  
                                  return Row(children: rowChildren);
                                }
                              ),
                            ),
                          Expanded(
                            child: ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              itemCount: rideOptions.length == 1 ? 1 : filteredOptions.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final option = rideOptions.length == 1 ? rideOptions[0] : filteredOptions[index];
                                final isSelected = selectedRideType == option.type;
                                
                                String resolvedIcon = option.icon;

                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    ref.read(selectedRideTypeProvider.notifier).update(option.type);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primaryGreenLight.withOpacity(0.3) : AppColors.bgCard,
                                      border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.border, width: 1.5),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        resolvedIcon.endsWith('.svg')
                                            ? SvgPicture.asset(
                                                resolvedIcon,
                                                width: 64,
                                                height: 48,
                                                fit: BoxFit.contain,
                                              )
                                            : Image.asset(
                                                resolvedIcon,
                                                width: 64,
                                                height: 48,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stackTrace) => Icon(
                                                  Icons.directions_car,
                                                  size: 48,
                                                  color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                                                ),
                                              ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(option.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 4),
                                              Text(option.description, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.person, size: 14, color: AppColors.textSecondary),
                                                Text('${option.seats}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                              ],
                                            ),
                                            Text('${option.eta} min away', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                            if (option.type == 'prime')
                                              Text('Top rated', style: AppTextStyles.caption.copyWith(color: AppColors.primaryGreen)),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text('₹${(option.fareEstimate.total - promoDiscount).toStringAsFixed(0)}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                            if (promoDiscount > 0)
                                              Text('₹${option.fareEstimate.total.toStringAsFixed(0)}', style: AppTextStyles.caption.copyWith(decoration: TextDecoration.lineThrough, color: AppColors.textSecondary)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                  // Bottom Action Bar
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
                    ),
                    child: Column(
                      children: [
                        // Payment selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: AppColors.bgSurface,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                  builder: (ctx) {
                                    return SafeArea(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Select Payment Method', style: AppTextStyles.h3),
                                            const SizedBox(height: 16),
                                            _buildPaymentOption(ctx, ref, 'cash', 'Cash', Icons.money, Colors.orange),
                                            _buildPaymentOption(ctx, ref, 'ola_money', 'Alo Money', Icons.account_balance_wallet, AppColors.primaryGreen),
                                            _buildPaymentOption(ctx, ref, 'upi', 'UPI', Icons.qr_code, Colors.purple),
                                            _buildPaymentOption(ctx, ref, 'card', 'Card', Icons.credit_card, Colors.blue),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    paymentMethod == 'cash' ? Icons.money : 
                                    paymentMethod == 'ola_money' ? Icons.account_balance_wallet : 
                                    paymentMethod == 'upi' ? Icons.qr_code : Icons.credit_card, 
                                    color: AppColors.primaryGreen, size: 20
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    paymentMethod == 'cash' ? 'Cash' : 
                                    paymentMethod == 'ola_money' ? 'Alo Money' : 
                                    paymentMethod == 'upi' ? 'UPI' : 'Card', 
                                    style: AppTextStyles.bodyMedium
                                  ),
                                  Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                                ],
                              ),
                            ),
                            if (promoDiscount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.primaryGreenLight, borderRadius: BorderRadius.circular(4)),
                                child: Text('Promo Applied', style: AppTextStyles.caption.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                              )
                            else
                              GestureDetector(
                                onTap: () => context.push('/payment-method'),
                                child: Text('Offers', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.push('/schedule-ride-booking'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.bgCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Icon(Icons.calendar_month, color: AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PrimaryButton(
                                text: selectedRideType == null || rideOptions.isEmpty
                                    ? 'Select a Ride'
                                    : 'Book ${rideOptions.firstWhere((o) => o.type == selectedRideType, orElse: () => rideOptions[0]).name}',
                                onPressed: () {
                                  // Navigate to search screen
                                  context.push('/driver-search');
                                },
                                disabled: rideOptions.isEmpty || selectedRideType == null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ).animate().slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutQuart),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, WidgetRef ref, String id, String title, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: AppTextStyles.bodyMedium),
      onTap: () {
        ref.read(paymentMethodProvider.notifier).update(id);
        Navigator.pop(context);
      },
    );
  }
}
