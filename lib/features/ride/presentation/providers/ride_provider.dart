import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ride_option.dart';
import '../../domain/entities/ride.dart';

class RideOptionsNotifier extends Notifier<List<RideOption>> {
  @override
  List<RideOption> build() => [];
  void update(List<RideOption> value) => state = value;
}
final rideOptionsProvider = NotifierProvider<RideOptionsNotifier, List<RideOption>>(() => RideOptionsNotifier());

class SelectedRideTypeNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? value) => state = value;
}
final selectedRideTypeProvider = NotifierProvider<SelectedRideTypeNotifier, String?>(() => SelectedRideTypeNotifier());

class IsEstimatingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void update(bool value) => state = value;
}
final isEstimatingProvider = NotifierProvider<IsEstimatingNotifier, bool>(() => IsEstimatingNotifier());

class PromoCodeNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? value) => state = value;
}
final promoCodeProvider = NotifierProvider<PromoCodeNotifier, String?>(() => PromoCodeNotifier());

class PromoDiscountNotifier extends Notifier<double> {
  @override
  double build() => 0.0;
  void update(double value) => state = value;
}
final promoDiscountProvider = NotifierProvider<PromoDiscountNotifier, double>(() => PromoDiscountNotifier());

class UseOlaMoneyNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void update(bool value) => state = value;
}
final useOlaMoneyProvider = NotifierProvider<UseOlaMoneyNotifier, bool>(() => UseOlaMoneyNotifier());

class CurrentRideNotifier extends Notifier<Ride?> {
  @override
  Ride? build() => null;

  void setCurrentRide(Ride ride) => state = ride;
  void clearCurrentRide() => state = null;
  
  void updateRideStatus(String status) {
    if (state != null) {
      state = state!.copyWith(status: status);
    }
  }
  
  void updateDriverLocation(double lat, double lng, double heading, int eta) {
    if (state?.driver != null) {
      state = state!.copyWith(
        eta: eta,
        driver: state!.driver!.copyWith(
          latitude: lat,
          longitude: lng,
          heading: heading,
        ),
      );
    }
  }
}

final currentRideProvider = NotifierProvider<CurrentRideNotifier, Ride?>(() {
  return CurrentRideNotifier();
});

class RideHistoryNotifier extends Notifier<List<Ride>> {
  @override
  List<Ride> build() => [];
  
  void addRide(Ride ride) {
    state = [ride, ...state];
  }
}

final rideHistoryProvider = NotifierProvider<RideHistoryNotifier, List<Ride>>(() {
  return RideHistoryNotifier();
});
