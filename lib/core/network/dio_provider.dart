import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(storageServiceProvider);
  
  final dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.olacabs.com/v1'),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final storage = ref.read(storageServiceProvider);
        final tokens = await storage.getTokens();
        if (tokens != null && tokens['accessToken'] != null) {
          options.headers['Authorization'] = 'Bearer ${tokens['accessToken']}';
        }
        options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final startTime = response.requestOptions.extra['startTime'] as int?;
        if (startTime != null) {
          final duration = DateTime.now().millisecondsSinceEpoch - startTime;
          print('[API] ${response.statusCode} ${response.requestOptions.path} (${duration}ms)');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        // Token refresh logic and queued retries will be implemented here during Phase 2 (Auth).
        return handler.next(e);
      },
    ),
  );

  return dio;
});
