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
    return MapUtils.fetchRoute(start, end);
  }
}
