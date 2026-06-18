import 'package:dio/dio.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../../../core/storage/storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final StorageService _storageService;

  AuthRepositoryImpl(this._dio, this._storageService);

  static User? _mockUser;
  static final Map<String, User> _registeredUsers = {
    '+919876543210': User(
      id: 'usr_9876543210',
      phone: '+919876543210',
      name: 'Veronica',
      rating: 4.8,
      createdAt: DateTime.now(),
      walletBalance: 250,
    ),
  };

  @override
  Future<void> sendOtp(String phone) async {
    // Simulated API call matching RN behavior
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Future<User> verifyOtp(String phone, String otp) async {
    // Simulated API response matching RN behavior
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Check if user already exists for this phone number
    if (_registeredUsers.containsKey(phone)) {
      _mockUser = _registeredUsers[phone];
    } else {
      _mockUser = User(
        id: 'usr_${phone.replaceAll(RegExp(r'\D'), '')}',
        phone: phone,
        name: phone == '+919876543210' ? 'Veronica' : 'New User',
        rating: 4.8,
        createdAt: DateTime.now(),
        walletBalance: 0,
      );
      _registeredUsers[phone] = _mockUser!;
    }
    
    final tokens = {
      'accessToken': 'dummy_access_token',
      'refreshToken': 'dummy_refresh_token',
    };

    await _storageService.setTokens(tokens);
    return _mockUser!;
  }

  @override
  Future<User> getMe() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_mockUser != null) {
      return _mockUser!;
    }
    // Fallback to Veronica
    const defaultPhone = '+919876543210';
    if (!_registeredUsers.containsKey(defaultPhone)) {
      _registeredUsers[defaultPhone] = User(
        id: 'usr_9876543210',
        phone: defaultPhone,
        name: 'Veronica',
        createdAt: DateTime.now(),
        walletBalance: 250,
      );
    }
    _mockUser = _registeredUsers[defaultPhone];
    return _mockUser!;
  }

  // Add a method to update the mock user
  void updateMockUser(User user) {
    _mockUser = user;
    if (user.phone.isNotEmpty) {
      _registeredUsers[user.phone] = user;
    }
  }

  @override
  Future<void> logout() async {
    await _storageService.clearTokens();
  }
}
