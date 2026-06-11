import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_location.dart';
import 'location_provider.dart';

class GhostCar {
  final String id;
  final double latitude;
  final double longitude;
  final double heading;

  GhostCar({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.heading,
  });

  GhostCar copyWith({
    double? latitude,
    double? longitude,
    double? heading,
  }) {
    return GhostCar(
      id: this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
    );
  }
}

class GhostCarsNotifier extends Notifier<List<GhostCar>> {
  Timer? _timer;
  final math.Random _random = math.Random();

  @override
  List<GhostCar> build() {
    ref.listen(locationStreamProvider, (previous, next) {
      if (previous?.value == null && next.value != null && state.isEmpty) {
        _generateInitialCars(next.value!);
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _moveCars();
    });

    ref.onDispose(() {
      _timer?.cancel();
    });

    return [];
  }

  void _generateInitialCars(AppLocation center) {
    final cars = List.generate(4, (i) {
      return GhostCar(
        id: 'ghost_$i',
        latitude: center.latitude + (_random.nextDouble() - 0.5) * 0.01,
        longitude: center.longitude + (_random.nextDouble() - 0.5) * 0.01,
        heading: _random.nextDouble() * 360,
      );
    });
    state = cars;
  }

  void _moveCars() {
    if (state.isEmpty) return;
    
    state = state.map((car) {
      // Move slightly in current heading
      final rad = car.heading * math.pi / 180;
      final dist = 0.0003; // small step
      final newLat = car.latitude + dist * math.cos(rad);
      final newLng = car.longitude + dist * math.sin(rad);
      
      // Randomly turn a bit
      final newHeading = (car.heading + (_random.nextDouble() - 0.5) * 45) % 360;
      
      return car.copyWith(
        latitude: newLat,
        longitude: newLng,
        heading: newHeading,
      );
    }).toList();
  }
}

final ghostCarsProvider = NotifierProvider<GhostCarsNotifier, List<GhostCar>>(() {
  return GhostCarsNotifier();
});
