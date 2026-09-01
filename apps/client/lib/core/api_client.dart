import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const apiBaseUrl = String.fromEnvironment(
  'DAYZERO_API_URL',
  defaultValue: 'http://localhost:3000',
);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      headers: {'x-user-id': 'demo-user'},
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: false,
    ),
  );

  return dio;
});
