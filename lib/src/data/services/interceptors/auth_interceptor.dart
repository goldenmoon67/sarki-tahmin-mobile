import 'package:default_flutter_project/src/data/errors/error_model.dart';
import 'package:dio/dio.dart';

// Dio Interceptor for Bearer AccessToken
class AuthInterceptor extends Interceptor {
  // final OAuth _oauth;
  final Dio _dio;
  void Function(Exception error)? onInvalid;

  AuthInterceptor(/* this._oauth ,*/ this._dio, {this.onInvalid});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    const accessToken =
        ""; // _oauth.storage.accessToken;        //TODO:: set acces token

    options.headers["Authorization"] = "Bearer $accessToken";

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    bool isTokenExpired = err.response?.statusCode == 401;
    if (!isTokenExpired && err.response?.statusCode == 403) {
      final response = err.response;
      if (response != null && response.data is Map<String, dynamic>) {
        final errorModel =
            ErrorModel.fromJson(response.data as Map<String, dynamic>);
        final message = errorModel.message;
        if (message != null && message.contains("auth/id-token-expired")) {
          isTokenExpired = true;
        }
      }
    }

    if (isTokenExpired) {
      RequestOptions requestOptions = err.requestOptions;

      /*   FirebaseCrashlytics.instance
          .log("statusCode == 401 path: ${requestOptions.path}");
 */
      const accessToken =
          ""; //_oauth.storage.accessToken;         //TODO:: set acces token

      const bearerToken = "Bearer $accessToken";
      // If the token has been updated, repeat directly.
      if (bearerToken != requestOptions.headers['Authorization']) {
        requestOptions.headers['Authorization'] = bearerToken;
        //repeat current request call
        try {
          final response = await _dio.fetch(requestOptions);
          handler.resolve(response);
        } catch (err) {
          if (err is DioException) {
            handler.reject(err);
          } else {
            final dioError =
                DioException(requestOptions: requestOptions, error: err);
            handler.reject(dioError);
          }
        }
        return;
      }

      try {
        //refresh access token
        //const oauthToken = ""; //await _oauth.refreshAccessToken();
        /*    requestOptions.headers["Authorization"] =
            "Bearer ${oauthToken.accessToken}"; */
        //TODO:: set acces token
        //repeat current request call
        final response = await _dio.fetch(requestOptions);
        handler.resolve(response);
      } catch (err) {
        /*   FirebaseCrashlytics.instance
            .log("Refresh AccessToken: catchError ${err.toString()}"); */

        if (err is DioException) {
          handler.reject(err);
        } else {
          final dioError =
              DioException(requestOptions: requestOptions, error: err);
          handler.reject(dioError);
        }
      }
    } else {
      super.onError(err, handler);
    }
  }
}
