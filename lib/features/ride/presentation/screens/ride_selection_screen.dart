import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../map/domain/entities/app_location.dart';
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

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    final repo = ref.read(mapRepositoryProvider);
    final points = await repo.getRoutePolylines(start, end);
    if (mounted) {
      setState(() {
        _routePoints = points;
      });
      _fitMapToRoute();
    }
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
      await _fetchRoute(
        LatLng(pickup.latitude, pickup.longitude),
        LatLng(destination.latitude, destination.longitude),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoute();
      ref.read(isEstimatingProvider.notifier).update(true);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        final options = [
          const RideOption(
            type: 'bike',
            name: 'Ola Bike',
            description: 'Quick and economical bike rides',
            icon: 'assets/image 23.png',
            seats: 1,
            available: true,
            eta: 2,
            fareEstimate: FareEstimate(
              baseFare: 20,
              distanceFare: 30,
              timeFare: 10,
              surgeMultiplier: 1,
              total: 60,
              currency: 'INR',
              distance: 5.2,
              duration: 15,
            ),
          ),
          const RideOption(
            type: 'auto',
            name: 'Ola Auto',
            description: 'Auto rickshaw at your doorstep',
            icon: 'assets/image 30.png',
            seats: 3,
            available: true,
            eta: 4,
            fareEstimate: FareEstimate(
              baseFare: 30,
              distanceFare: 50,
              timeFare: 12,
              surgeMultiplier: 1,
              total: 100,
              currency: 'INR',
              distance: 5.2,
              duration: 15,
            ),
          ),
          const RideOption(
            type: 'mini',
            name: 'Ola Mini',
            description: 'Comfy, economical hatchbacks',
            icon: 'assets/image 24.png',
            seats: 4,
            available: true,
            eta: 3,
            fareEstimate: FareEstimate(
              baseFare: 50,
              distanceFare: 60,
              timeFare: 15,
              surgeMultiplier: 1,
              total: 150,
              currency: 'INR',
              distance: 5.2,
              duration: 15,
            ),
          ),
          const RideOption(
            type: 'prime',
            name: 'Prime Sedan',
            description: 'Spacious, top-rated sedans',
            icon: 'assets/image 26.png',
            seats: 4,
            available: true,
            eta: 5,
            fareEstimate: FareEstimate(
              baseFare: 70,
              distanceFare: 75,
              timeFare: 22.5,
              surgeMultiplier: 1,
              total: 220,
              currency: 'INR',
              distance: 5.2,
              duration: 15,
            ),
          ),
          const RideOption(
            type: 'suv',
            name: 'Prime SUV',
            description: 'Spacious SUVs for family trips',
            icon: 'assets/image 28.png',
            seats: 6,
            available: true,
            eta: 6,
            fareEstimate: FareEstimate(
              baseFare: 100,
              distanceFare: 110,
              timeFare: 35,
              surgeMultiplier: 1,
              total: 320,
              currency: 'INR',
              distance: 5.2,
              duration: 15,
            ),
          ),
        ];
        ref.read(rideOptionsProvider.notifier).update(options);
        ref.read(selectedRideTypeProvider.notifier).update(options[0].type);
        ref.read(isEstimatingProvider.notifier).update(false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final rideOptions = ref.watch(rideOptionsProvider);
    final selectedRideType = ref.watch(selectedRideTypeProvider);
    final isEstimating = ref.watch(isEstimatingProvider);
    final promoDiscount = ref.watch(promoDiscountProvider);

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

    final selectedOption = rideOptions.where((o) => o.type == selectedRideType).firstOrNull;
    final finalFare = (selectedOption?.fareEstimate.total ?? 0) - promoDiscount;

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
                decoration: const BoxDecoration(
                  color: AppColors.bgCard,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),
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
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                              itemCount: rideOptions.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final option = rideOptions[index];
                                final isSelected = selectedRideType == option.type;
                                return GestureDetector(
                                  onTap: () => ref.read(selectedRideTypeProvider.notifier).update(option.type),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primaryGreenLight.withOpacity(0.3) : AppColors.bgCard,
                                      border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.border, width: 1.5),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          option.icon,
                                          width: 50,
                                          height: 36,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) => Icon(
                                            Icons.directions_car,
                                            size: 36,
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
                                                const Icon(Icons.person, size: 14, color: AppColors.textSecondary),
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
                            Row(
                              children: [
                                const Icon(Icons.money, color: AppColors.primaryGreen, size: 20),
                                const SizedBox(width: 8),
                                Text('Cash', style: AppTextStyles.bodyMedium),
                                const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                              ],
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
                              onTap: () => context.push('/schedule-ride'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.bgCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Icon(Icons.calendar_month, color: AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PrimaryButton(
                          text: selectedRideType == null ? 'Select a Ride' : 'Book ${rideOptions.firstWhere((o) => o.type == selectedRideType, orElse: () => rideOptions[0]).name}',
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
}
