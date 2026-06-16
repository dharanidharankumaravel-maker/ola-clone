import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/ride_provider.dart';
import '../widgets/driver_card.dart';
import '../../../map/presentation/providers/map_repository_provider.dart';

const Map<String, String> statusLabels = {
  'searching': 'Finding driver...',
  'accepted': 'Driver is on the way',
  'arrived': 'Driver has arrived!',
  'trip_started': 'Trip in progress',
  'completed': 'Trip completed',
  'cancelled': 'Ride cancelled',
};

const Map<String, Color> statusColors = {
  'accepted': AppColors.primaryGreen,
  'arrived': Colors.orange,
  'trip_started': AppColors.primaryGreen,
  'completed': AppColors.primaryGreen,
  'cancelled': Colors.red,
};

class RideTrackingScreen extends ConsumerStatefulWidget {
  const RideTrackingScreen({super.key});

  @override
  ConsumerState<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends ConsumerState<RideTrackingScreen> {
  final MapController _mapController = MapController();
  Timer? _simulationTimer;
  List<LatLng> _routePoints = [];
  double _simulationProgress = 0.0;
  int _tickCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoute();
    });

    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final currentRide = ref.read(currentRideProvider);
      if (currentRide == null || currentRide.driver == null) return;

      _tickCount++;

      if (currentRide.status == 'accepted') {
        if (_tickCount > 3) {
          ref.read(currentRideProvider.notifier).updateRideStatus('arrived');
          _tickCount = 0;
        }
      } else if (currentRide.status == 'arrived') {
        if (_tickCount > 2) {
          ref.read(currentRideProvider.notifier).updateRideStatus('trip_started');
          _tickCount = 0;
        }
      } else if (currentRide.status == 'trip_started') {
        if (_routePoints.isNotEmpty) {
          _simulationProgress += 0.05; // 20 second mock trip
          
          if (_simulationProgress >= 1.0) {
            _simulationProgress = 1.0;
            ref.read(currentRideProvider.notifier).updateRideStatus('completed');
            timer.cancel();
          }
          
          LatLng nextPoint = _routePoints.last;

          if (_routePoints.length == 2) {
            final start = _routePoints.first;
            final end = _routePoints.last;
            final lat = start.latitude + (end.latitude - start.latitude) * _simulationProgress;
            final lng = start.longitude + (end.longitude - start.longitude) * _simulationProgress;
            nextPoint = LatLng(lat, lng);
          } else {
            double totalSegments = (_routePoints.length - 1).toDouble();
            double exactIndex = _simulationProgress * totalSegments;
            int baseIndex = exactIndex.floor();
            
            if (baseIndex >= _routePoints.length - 1) {
              nextPoint = _routePoints.last;
            } else {
              double remainder = exactIndex - baseIndex;
              final p1 = _routePoints[baseIndex];
              final p2 = _routePoints[baseIndex + 1];
              final lat = p1.latitude + (p2.latitude - p1.latitude) * remainder;
              final lng = p1.longitude + (p2.longitude - p1.longitude) * remainder;
              nextPoint = LatLng(lat, lng);
            }
          }
          
          final updatedRide = currentRide.copyWith(
            driver: currentRide.driver!.copyWith(
              latitude: nextPoint.latitude,
              longitude: nextPoint.longitude,
            )
          );
          ref.read(currentRideProvider.notifier).setCurrentRide(updatedRide);
        } else {
          ref.read(currentRideProvider.notifier).updateRideStatus('completed');
          timer.cancel();
        }
      }
    });
  }

  Future<void> _loadRoute() async {
    final currentRide = ref.read(currentRideProvider);
    if (currentRide == null) return;

    final repo = ref.read(mapRepositoryProvider);
    final points = await repo.getRoutePolylines(
      LatLng(currentRide.pickup.latitude, currentRide.pickup.longitude),
      LatLng(currentRide.destination.latitude, currentRide.destination.longitude),
    );
    
    if (mounted) {
      setState(() {
        _routePoints = points;
      });
      if (points.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(points);
        try {
          _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _handleCall(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _handleSOS() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🆘 Emergency SOS'),
        content: const Text('This will share your location with emergency services and Alo Safety team.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final url = Uri.parse('tel:112');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
            child: const Text('Activate SOS', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleShareEta(String rideId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Track my ride: ola://ride/$rideId')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentRide = ref.watch(currentRideProvider);

    if (currentRide == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    ref.listen(currentRideProvider, (previous, next) {
      if (next?.status == 'completed') {
        context.go('/driver-feedback');
      } else if (next?.status == 'cancelled') {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Ride Cancelled'),
            content: const Text('The ride was cancelled.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/');
                },
                child: const Text('OK', style: TextStyle(color: AppColors.primaryGreen)),
              )
            ],
          )
        );
      }
    });

    final status = currentRide.status;
    final color = statusColors[status] ?? AppColors.primaryGreen;
    
    LatLng target = LatLng(currentRide.pickup.latitude, currentRide.pickup.longitude);
    if (currentRide.driver != null && (status == 'accepted' || status == 'trip_started')) {
      target = LatLng(currentRide.driver!.latitude, currentRide.driver!.longitude);
    }
    
    if (currentRide.driver != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.move(target, 15);
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
              initialCenter: target,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ola.customer',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints.isNotEmpty ? _routePoints : [
                      LatLng(currentRide.pickup.latitude, currentRide.pickup.longitude),
                      LatLng(currentRide.destination.latitude, currentRide.destination.longitude),
                    ],
                    color: AppColors.primaryGreen,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(currentRide.pickup.latitude, currentRide.pickup.longitude),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Colors.green, size: 40),
                  ),
                  Marker(
                    point: LatLng(currentRide.destination.latitude, currentRide.destination.longitude),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                  if (currentRide.driver != null)
                    Marker(
                      point: LatLng(currentRide.driver!.latitude, currentRide.driver!.longitude),
                      width: 40,
                      height: 40,
                      child: Transform.rotate(
                        angle: currentRide.driver!.heading * (3.14159 / 180),
                        child: const Icon(Icons.directions_car, color: Colors.blue, size: 40),
                      ),
                    ),
                ],
              ),
            ],
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    // Could pop sheet or shrink it
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
                  ),
                ),
                GestureDetector(
                  onTap: _handleSOS,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Text('SOS', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ),

          if (currentRide.eta != null && (status == 'accepted' || status == 'trip_started'))
            Positioned(
              top: MediaQuery.of(context).padding.top + 76,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, color: color, size: 16),
                      const SizedBox(width: 8),
                      Text('${currentRide.eta} min away', style: AppTextStyles.bodyMedium.copyWith(color: color, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 12),
                        Text(statusLabels[status] ?? 'Unknown status', style: AppTextStyles.bodyMedium.copyWith(color: color, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  if (currentRide.driver != null)
                    DriverCard(
                      driver: currentRide.driver!,
                      otp: currentRide.otp ?? '----',
                      onCall: () => _handleCall(currentRide.driver!.phone),
                      onMessage: () {},
                      onShareEta: () => _handleShareEta(currentRide.id),
                    ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
