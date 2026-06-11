import '../entities/user.dart';

abstract class AuthRepository {
  Future<void> sendOtp(String phone);
  Future<User> verifyOtp(String phone, String otp);
  Future<User> getMe();
  Future<void> logout();
}
