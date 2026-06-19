import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/app_location.dart';
import '../../../../core/storage/storage_provider.dart';
import 'dart:convert';

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
  
  void clearDestination() {
    state = LocationState(pickup: state.pickup, destination: null);
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
  static const String _savedPlacesKey = '@ola:saved_places';

  @override
  List<SavedPlace> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedPlacesJson = prefs.getStringList(_savedPlacesKey);
    if (savedPlacesJson == null) {
      final defaultList = [
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
      _saveToPrefs(defaultList);
      return defaultList;
    }
    
    try {
      return savedPlacesJson.map((jsonStr) {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        return SavedPlace(
          title: data['title'] as String,
          subtitle: data['subtitle'] as String?,
          location: AppLocation.fromJson(data['location'] as Map<String, dynamic>),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  void _saveToPrefs(List<SavedPlace> list) {
    final prefs = ref.read(sharedPreferencesProvider);
    final jsonList = list.map((p) => jsonEncode({
      'title': p.title,
      'subtitle': p.subtitle,
      'location': p.location.toJson(),
    })).toList();
    prefs.setStringList(_savedPlacesKey, jsonList);
  }

  void addPlace(SavedPlace place) {
    final filtered = state.where((p) => p.title.toLowerCase() != place.title.toLowerCase()).toList();
    final newList = [...filtered, place];
    state = newList;
    _saveToPrefs(newList);
  }

  void removePlace(SavedPlace place) {
    final newList = state.where((p) => p != place).toList();
    state = newList;
    _saveToPrefs(newList);
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
