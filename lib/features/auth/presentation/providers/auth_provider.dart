import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/storage/storage_provider.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(storageServiceProvider);
  return AuthRepositoryImpl(dio, storage);
}

@riverpod
class Auth extends _$Auth {
  @override
  FutureOr<User?> build() async {
    final storage = ref.read(storageServiceProvider);
    final tokens = await storage.getTokens();
    if (tokens != null && tokens['accessToken'] != null) {
      try {
        final repo = ref.read(authRepositoryProvider);
        return await repo.getMe();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> sendOtp(String phone) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.sendOtp(phone);
  }

  Future<void> verifyOtp(String phone, String otp) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.verifyOtp(phone, otp);
    });
  }

  Future<void> updateUser(User user) async {
    final repo = ref.read(authRepositoryProvider);
    if (repo is AuthRepositoryImpl) {
      repo.updateMockUser(user);
    }
    state = AsyncValue.data(user);
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    if (repo is AuthRepositoryImpl) {
      repo.updateMockUser(User(id: '', phone: '', name: '', createdAt: DateTime.now())); // Reset
    }
    state = const AsyncValue.data(null);
  }
}

class WalletTransaction {
  final String id;
  final double amount;
  final String type; // 'debit' or 'topup'
  final String description;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });
}

class WalletTransactionNotifier extends Notifier<List<WalletTransaction>> {
  @override
  List<WalletTransaction> build() => [
    WalletTransaction(id: 'tx_1', amount: 250, type: 'debit', description: 'Ride to Airport', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
    WalletTransaction(id: 'tx_2', amount: 1000, type: 'topup', description: 'Added to wallet', createdAt: DateTime.now().subtract(const Duration(days: 1))),
  ];
  
  void addTransaction(WalletTransaction tx) {
    state = [tx, ...state];
  }
}

final walletTransactionProvider = NotifierProvider<WalletTransactionNotifier, List<WalletTransaction>>(() {
  return WalletTransactionNotifier();
});
