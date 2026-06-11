import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/ride/presentation/providers/ride_provider.dart';
import '../../features/ride/domain/entities/ride.dart';

class SocketService {
  io.Socket? _socket;
  final Ref _ref;

  SocketService(this._ref);

  void connect(String token) {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io('wss://socket.olacabs.com', <String, dynamic>{
      'transports': ['websocket'],
      'auth': {'token': token},
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print('[Socket] Connected');
    });

    _socket!.onDisconnect((_) {
      print('[Socket] Disconnected');
    });

    _registerRideEvents();
  }

  void _registerRideEvents() {
    if (_socket == null) return;

    _socket!.on('ride:accepted', (data) {
      if (data is Map<String, dynamic>) {
        final currentRide = _ref.read(currentRideProvider);
        if (currentRide != null) {
          final driver = Driver.fromJson(data['driver']);
          final updatedRide = currentRide.copyWith(status: 'driver_assigned', driver: driver);
          _ref.read(currentRideProvider.notifier).setCurrentRide(updatedRide);
        }
      }
    });

    _socket?.on('driver_location_update', (data) {
      if (data != null) {
        final currentRide = _ref.read(currentRideProvider);
        if (currentRide?.driver != null) {
          _ref.read(currentRideProvider.notifier).updateDriverLocation(
            data['latitude'],
            data['longitude'],
            data['heading'],
            data['eta'],
          );
        }
      }
    });

    _socket?.on('ride_status_update', (data) {
      if (data != null && data['status'] != null) {
        final currentRide = _ref.read(currentRideProvider);
        if (currentRide != null) {
          _ref.read(currentRideProvider.notifier).updateRideStatus(data['status']);
        }
      }
    });

    _socket?.on('ride_cancelled', (data) {
      if (data != null) {
        final currentRide = _ref.read(currentRideProvider);
        if (currentRide != null) {
          _ref.read(currentRideProvider.notifier).updateRideStatus('cancelled');
        }
      }
    });
  }

  void joinRideRoom(String rideId) {
    _socket?.emit('ride:join', {'rideId': rideId});
  }

  void leaveRideRoom(String rideId) {
    _socket?.emit('ride:leave', {'rideId': rideId});
  }

  void sendMessage(String rideId, String message) {
    _socket?.emit('chat:send', {'rideId': rideId, 'message': message});
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.off('ride:accepted');
      _socket!.off('driver:location');
      _socket!.off('ride:status-update');
      _socket!.off('ride:cancelled');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }
}

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService(ref);
});
