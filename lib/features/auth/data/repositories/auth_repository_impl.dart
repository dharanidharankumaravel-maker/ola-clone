import 'package:dio/dio.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../../../core/storage/storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final StorageService _storageService;

  AuthRepositoryImpl(this._dio, this._storageService);

  static User? _mockUser;

  @override
  Future<void> sendOtp(String phone) async {
    // Simulated API call matching RN behavior
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Future<User> verifyOtp(String phone, String otp) async {
    // Simulated API response matching RN behavior
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Create a new mock user for this phone number
    _mockUser = User(
      id: 'usr_${phone.replaceAll(RegExp(r'\D'), '')}',
      phone: phone,
      name: phone == '+919876543210' ? 'Veronica' : 'New User',
      rating: 4.8,
      createdAt: DateTime.now(),
      walletBalance: 1500,
    );
    
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
    return _mockUser ?? User(
      id: 'usr_dummy123',
      phone: '+919876543210',
      name: 'Veronica',
      createdAt: DateTime.now(),
      walletBalance: 1500,
    );
  }

  // Add a method to update the mock user
  void updateMockUser(User user) {
    _mockUser = user;
  }

  @override
  Future<void> logout() async {
    await _storageService.clearTokens();
  }
}
