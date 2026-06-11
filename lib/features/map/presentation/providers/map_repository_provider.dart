import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/map_repository.dart';
import '../../data/repositories/map_repository_impl.dart';
import '../../../../core/network/dio_provider.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MapRepositoryImpl(dio);
});
