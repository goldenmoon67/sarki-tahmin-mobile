import 'dart:io';
import 'package:default_flutter_project/src/data/errors/error_model.dart';
import 'package:default_flutter_project/src/data/services/errors/api_error.dart';
import 'package:default_flutter_project/src/utils/di/getit_register.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class ErrorInterceptor extends Interceptor {
  final Logger _logger = getIt<Logger>();

  static const String defaultErrorCode = "500";

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    var response = err.response;

    ErrorModel errorModel = const ErrorModel(code: defaultErrorCode);

    switch (err.type) {
      case DioException.badResponse:
        if (response != null && response.data is Map<String, dynamic>) {
          errorModel =
              ErrorModel.fromJson(response.data as Map<String, dynamic>);
        } else {
          errorModel = errorModel.copyWith(error: err.message);
        }

        var error = ApiError(
            response?.statusCode ?? 500, errorModel, err.requestOptions);
        handler.reject(error);
        break;
      case DioException.connectionTimeout:
        var error = ApiError(
            ApiErrorStatus.connectTimeout, errorModel, err.requestOptions);
        handler.reject(error);
        break;
      case DioException.sendTimeout:
        var error = ApiError(
            ApiErrorStatus.sendTimeout, errorModel, err.requestOptions);
        handler.reject(error);
        break;
      case DioException.receiveTimeout:
        var error = ApiError(
            ApiErrorStatus.receiveTimeout, errorModel, err.requestOptions);
        handler.reject(error);
        break;
      case DioException.requestCancelled:
        var error =
            ApiError(ApiErrorStatus.cancel, errorModel, err.requestOptions);
        handler.reject(error);
        break;
      default:
        errorModel = errorModel.copyWith(error: err.message);
        ApiError apiError =
            ApiError(ApiErrorStatus.other, errorModel, err.requestOptions);

        try {
          final isConnected = await isConnectedToInternet();
          _logger.d("isConnectedToInternet: $isConnected");

          if (!isConnected) {
            apiError = ApiError(
                ApiErrorStatus.noInternet, errorModel, err.requestOptions);
          }
          handler.reject(apiError);
          debugPrint(err.toString());
        } catch (err) {
          handler.reject(apiError);
          debugPrint(err.toString());
        }

        break;
    }
  }

  Future<bool> isConnectedToInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }
}
