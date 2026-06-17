import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/app_location.dart';

final currentLocationProvider = FutureProvider<AppLocation?>((ref) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return null;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return null;
  }

  try {
    final position = await Geolocator.getCurrentPosition(
      timeLimit: const Duration(seconds: 3),
    );
    return AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      shortAddress: 'Current Location',
      formattedAddress: 'Your Current Location',
    );
  } catch (e) {
    // If it times out or fails (common on emulators without location set), return default Chennai
    return const AppLocation(
      latitude: 13.0827,
      longitude: 80.2707,
      shortAddress: 'Chennai, Tamil Nadu',
      formattedAddress: 'Chennai, Tamil Nadu, India',
    );
  }
});

final locationStreamProvider = StreamProvider<AppLocation?>((ref) async* {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    yield const AppLocation(
      latitude: 13.0827,
      longitude: 80.2707,
      shortAddress: 'Chennai, Tamil Nadu',
      formattedAddress: 'Chennai, Tamil Nadu, India',
    );
    return;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      yield const AppLocation(
        latitude: 13.0827,
        longitude: 80.2707,
        shortAddress: 'Chennai, Tamil Nadu',
        formattedAddress: 'Chennai, Tamil Nadu, India',
      );
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    yield const AppLocation(
      latitude: 13.0827,
      longitude: 80.2707,
      shortAddress: 'Chennai, Tamil Nadu',
      formattedAddress: 'Chennai, Tamil Nadu, India',
    );
    return;
  }

  // Get initial location first
  try {
    final position = await Geolocator.getCurrentPosition(
      timeLimit: const Duration(seconds: 3),
    );
    yield AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      shortAddress: 'Current Location',
      formattedAddress: 'Your Current Location',
    );
  } catch (_) {
    yield const AppLocation(
      latitude: 13.0827,
      longitude: 80.2707,
      shortAddress: 'Chennai, Tamil Nadu',
      formattedAddress: 'Chennai, Tamil Nadu, India',
    );
  }

  // Stream updates
  try {
    await for (final position in Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    )) {
      yield AppLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        shortAddress: 'Current Location',
        formattedAddress: 'Your Current Location',
      );
    }
  } catch (_) {}
});

class LocationState {
  final AppLocation? pickup;
  final AppLocation? destination;

  const LocationState({this.pickup, this.destination});

  LocationState copyWith({
    AppLocation? pickup,
    AppLocation? destination,
  }) {
    return LocationState(
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
    );
  }
}

class LocationNotifier extends Notifier<LocationState> {
  @override
  LocationState build() => const LocationState();

  void setPickup(AppLocation location) {
    state = state.copyWith(pickup: location);
  }

  void setDestination(AppLocation location) {
    state = state.copyWith(destination: location);
  }
  
  void clear() {
    state = const LocationState();
  }
}

final locationProvider = NotifierProvider<LocationNotifier, LocationState>(() {
  return LocationNotifier();
});

class SavedPlace {
  final String title;
  final String? subtitle;
  final AppLocation location;

  SavedPlace({required this.title, this.subtitle, required this.location});
}

class SavedPlacesNotifier extends Notifier<List<SavedPlace>> {
  @override
  List<SavedPlace> build() => [
    SavedPlace(
      title: 'Work',
      subtitle: 'Tech Park, OMR, Chennai',
      location: const AppLocation(
        latitude: 12.9716,
        longitude: 80.2536,
        shortAddress: 'Tech Park',
        formattedAddress: 'Tech Park, OMR, Chennai',
      ),
    ),
  ];

  void addPlace(SavedPlace place) {
    state = [...state, place];
  }

  void removePlace(SavedPlace place) {
    state = state.where((p) => p != place).toList();
  }

  bool isSaved(AppLocation location) {
    return state.any((p) => 
      p.location.latitude == location.latitude && 
      p.location.longitude == location.longitude
    );
  }
}

final savedPlacesProvider = NotifierProvider<SavedPlacesNotifier, List<SavedPlace>>(() {
  return SavedPlacesNotifier();
});
