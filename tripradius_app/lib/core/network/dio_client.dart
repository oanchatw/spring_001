import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';

class DioClient {
  late final Dio _dio;
  late final CookieJar _cookieJar;
  final FlutterSecureStorage _secureStorage;

  DioClient({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _cookieJar = CookieJar();
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Follow redirects but keep cookies
        followRedirects: true,
        maxRedirects: 5,
      ),
    );

    _dio.interceptors.addAll([
      CookieManager(_cookieJar),
      _AuthInterceptor(_secureStorage, _cookieJar),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (o) => print('[DIO] $o'),
      ),
    ]);
  }

  Dio get dio => _dio;
  CookieJar get cookieJar => _cookieJar;

  /// Persist JSESSIONID to secure storage after OAuth login
  Future<void> persistSession() async {
    final uri = Uri.parse(ApiConstants.baseUrl);
    final cookies = await _cookieJar.loadForRequest(uri);
    final session = cookies.firstWhere(
      (c) => c.name == 'JSESSIONID',
      orElse: () => Cookie('', ''),
    );
    if (session.value.isNotEmpty) {
      await _secureStorage.write(key: 'JSESSIONID', value: session.value);
    }
  }

  /// Restore JSESSIONID from secure storage on app start
  Future<void> restoreSession() async {
    final sessionId = await _secureStorage.read(key: 'JSESSIONID');
    if (sessionId != null) {
      final uri = Uri.parse(ApiConstants.baseUrl);
      await _cookieJar.saveFromResponse(
        uri,
        [Cookie('JSESSIONID', sessionId)],
      );
    }
  }

  Future<void> clearSession() async {
    _cookieJar.deleteAll();
    await _secureStorage.delete(key: 'JSESSIONID');
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final CookieJar _cookieJar;

  _AuthInterceptor(this._storage, this._cookieJar);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Restore session if not already set
    final sessionId = await _storage.read(key: 'JSESSIONID');
    if (sessionId != null) {
      final uri = Uri.parse(options.baseUrl);
      final existing = await _cookieJar.loadForRequest(uri);
      final hasSession = existing.any((c) => c.name == 'JSESSIONID');
      if (!hasSession) {
        await _cookieJar.saveFromResponse(
          uri,
          [Cookie('JSESSIONID', sessionId)],
        );
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Session expired — handled by AuthCubit via BLoC error state
    }
    handler.next(err);
  }
}
