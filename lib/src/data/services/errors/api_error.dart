import 'package:default_flutter_project/src/data/errors/error_model.dart';
import 'package:dio/dio.dart';

class ApiErrorStatus {
  static int get general => 0;
  static int get noInternet => 1;
  static int get connectTimeout => 2;
  static int get sendTimeout => 3;
  static int get receiveTimeout => 4;
  static int get cancel => 5;
  static int get other => 6;
}

class ApiError extends DioException {
  final int statusCode;
  final ErrorModel errorModel;

  ApiError(this.statusCode, this.errorModel, requestOptions)
      : super(requestOptions: requestOptions);

  bool isOk() {
    return statusCode >= 200 && statusCode < 300;
  }
}
