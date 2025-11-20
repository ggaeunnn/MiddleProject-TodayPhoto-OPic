import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DioManager {
  static final DioManager shared = DioManager._internal();

  factory DioManager() => shared;

  DioManager._internal();

  static final String _baseUrl = dotenv.env['DioManager_Base_url']!;
  static final String _apiKey = dotenv.env['DioManager_Apikey']!;

  late final _dio = _createDio();

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {'apikey': _apiKey, 'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(_createAuthInterceptor());

    return dio;
  }

  InterceptorsWrapper _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }

        handler.next(options);
      },
    );
  }

  Dio get dio => _dio;
}
