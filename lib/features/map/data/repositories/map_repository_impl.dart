import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/repositories/map_repository.dart';
import '../../domain/entities/app_location.dart';
import '../../../../core/utils/map_utils.dart';

class MapRepositoryImpl implements MapRepository {
  final Dio _dio;

  MapRepositoryImpl(this._dio);

  @override
  Future<List<AppLocation>> searchLocations(String query) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': 1,
          'limit': 8,
          'countrycodes': 'in',
        },
        options: Options(
          headers: {'User-Agent': 'com.ola.customer'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data;
        return results.map((item) {
          return AppLocation(
            latitude: double.tryParse(item['lat']?.toString() ?? '0') ?? 0.0,
            longitude: double.tryParse(item['lon']?.toString() ?? '0') ?? 0.0,
            shortAddress: item['name']?.toString() ?? item['display_name']?.toString().split(',').first ?? '',
            formattedAddress: item['display_name']?.toString() ?? '',
            placeId: item['place_id']?.toString() ?? '',
          );
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<LatLng>> getRoutePolylines(LatLng start, LatLng end) async {
    int retries = 2;
    while (retries > 0) {
      try {
        final response = await _dio.get(
          'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=polyline',
          options: Options(
            sendTimeout: const Duration(seconds: 3),
            receiveTimeout: const Duration(seconds: 3),
          )
        );
        
        if (response.statusCode == 200) {
          final routes = response.data['routes'] as List;
          if (routes.isNotEmpty) {
            final poly = routes[0]['geometry'] as String;
            return MapUtils.decodePolyline(poly);
          }
        }
      } catch (_) {}
      retries--;
      if (retries > 0) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return [start, end];
  }

  @override
  Future<AppLocation?> getReverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'format': 'json',
          'addressdetails': 1,
        },
        options: Options(
          headers: {'User-Agent': 'com.ola.customer'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['error'] != null) return null;
        
        final address = data['address'] as Map<String, dynamic>?;
        final road = address?['road'] ?? address?['neighbourhood'] ?? address?['suburb'] ?? '';
        final city = address?['city'] ?? address?['town'] ?? address?['village'] ?? '';
        
        String shortName = road.isNotEmpty ? road : (data['name'] ?? 'Unknown Location');
        
        return AppLocation(
          latitude: lat,
          longitude: lng,
          shortAddress: shortName,
          formattedAddress: data['display_name'] ?? '$shortName, $city',
          placeId: data['place_id']?.toString() ?? '',
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
