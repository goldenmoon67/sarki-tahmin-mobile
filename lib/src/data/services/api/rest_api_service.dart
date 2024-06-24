import 'dart:io';

import 'package:default_flutter_project/src/configs/flavors.dart';
import 'package:default_flutter_project/src/data/services/interceptors/error_interceptor.dart';
import 'package:default_flutter_project/src/data/services/transformers/flutter_transformer.dart';
import 'package:default_flutter_project/src/utils/di/getit_register.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class RestApiService {
  static final RestApiService _singleton = RestApiService._internal();

  factory RestApiService() {
    return _singleton;
  }

  late Dio _dio;

  static Dio get dio => _singleton._dio;

  RestApiService._internal() {
    _dio = _createDio();
  }

  Dio _createDio() {
    var dio = Dio(BaseOptions(
      baseUrl: F.baseUrl, receiveDataWhenStatusError: true,

      connectTimeout: const Duration(minutes: 2), //60s
      receiveTimeout: const Duration(minutes: 2), //60s,
    ));
    dio.transformer = FlutterTransformer();
/*     final storage = getIt<OAuthSecureStorage>();
    final oauthDio = _createOAuthDio();
    final oauth = OAuth(
        tokenUrl: '/users/refresh-token',
        clientId: 'zero2HeroClientId',
        clientSecret: 'zero2HeroClientSecret',
        storage: storage,
        dio: oauthDio);
    dio.interceptors.add(DefaultHeaderInterceptor());
    dio.interceptors.add(AuthInterceptor(oauth, dio, onInvalid: (error) {
      //logout from app
      return;
    })); */
    if (F.logging) {
      final logger = getIt<Logger>();
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        logPrint: (obj) => logger.i(obj),
      ));
    }

    dio.interceptors.add(ErrorInterceptor());

    if (F.appFlavor == Flavor.dev && kDebugMode) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
          _onHttpClientCreate;
      /*  (oauthDio.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
          _onHttpClientCreate; */
    }

    return dio;
  }

/* 
  Dio _createOAuthDio() {
    var oauthDio = Dio(BaseOptions(
      baseUrl: F.baseUrl,
      connectTimeout: const Duration(milliseconds: 60 * 1000), //60s
      receiveTimeout: const Duration(milliseconds: 60 * 1000), //60s,
    ));

    oauthDio.transformer = FlutterTransformer();

    oauthDio.interceptors.add(DefaultHeaderInterceptor());

    if (F.appFlavor == Flavor.dev) {
      final logger = getIt<Logger>();
      oauthDio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        maxWidth: 180,
        logPrint: (obj) => logger.i(obj),
      ));
    }
    oauthDio.interceptors.add(ErrorInterceptor());

    return oauthDio;
  }
 */
  HttpClient _onHttpClientCreate() {
    final client = HttpClient(
      context: SecurityContext(withTrustedRoots: false),
    );
    // You can test the intermediate / root cert here. We just ignore it.
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  }
}
