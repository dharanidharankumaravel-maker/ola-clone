import 'package:latlong2/latlong.dart';
import '../entities/app_location.dart';

abstract class MapRepository {
  Future<List<AppLocation>> searchLocations(String query);
  Future<List<LatLng>> getRoutePolylines(LatLng start, LatLng end);
  Future<AppLocation?> getReverseGeocode(double lat, double lng);
}
