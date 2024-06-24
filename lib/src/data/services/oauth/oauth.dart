/* import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

typedef OAuthTokenExtractor = OAuthToken Function(Response response);
typedef OAuthTokenValidator = Future<bool> Function(OAuthToken token);

class OAuthException extends Error {
  final String code;
  final String message;

  OAuthException(this.code, this.message) : super();

  @override
  String toString() => 'OAuthException: [$code] $message';
}

/// Interceptor to send the bearer access token and update the access token when needed
class BearerInterceptor extends Interceptor {
  OAuth oauth;
  Future<void> Function(Exception error)? onInvalid;

  BearerInterceptor(this.oauth, {this.onInvalid});

  /// Add Bearer token to Authorization Header
  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handle) async {
    final token = await oauth.fetchOrRefreshAccessToken().catchError((err) {
      if (onInvalid != null) {
        onInvalid!(err);
      }
      return null;
    });

    if (token != null) {
      options.headers.addAll({"Authorization": "Bearer ${token.accessToken}"});
    }

    return handle.next(options);
  }
}

/// Use to implement a custom grantType
abstract class OAuthGrantType {
  RequestOptions handle(RequestOptions request);
}

/// Obtain an access token using a username and password
class PasswordGrant extends OAuthGrantType {
  final String username;
  final String password;
  final List<String> scope;

  PasswordGrant(
      {this.username = '', this.password = '', this.scope = const []});

  /// Prepare Request
  @override
  RequestOptions handle(RequestOptions request) {
    request.data = {
      "grant_type": "password",
      "username": username,
      "password": password,
      "scope": scope.join(' ')
    };

    return request;
  }
}

/// Obtain an access token using an refresh token
class RefreshTokenGrant extends OAuthGrantType {
  String refreshToken;

  RefreshTokenGrant({required this.refreshToken});

  /// Prepare Request
  @override
  RequestOptions handle(RequestOptions request) {
    final data = <String, dynamic>{};
    data["refreshToken"] = refreshToken;

    request.data = data;
    return request;
  }
}

/// Obtain an access token using provider
class ProviderTokenGrant extends OAuthGrantType {
  ProviderTokenGrant();

  /// Prepare Request
  @override
  RequestOptions handle(RequestOptions request) {
    final data = <String, dynamic>{};
    request.data = data;
    return request;
  }
}

/// Use to implement custom token storage
abstract class OAuthStorage {
/*   String? get accessToken;

  /// Read token
  Future<OAuthToken?> fetch();

  /// Save Token
  Future<OAuthToken> save(OAuthToken token);

  /// Clear token
  Future<void> clear(); */
}

/// Save Token in Memory
class OAuthMemoryStorage extends OAuthStorage {
  /* OAuthToken? _token;

  /// Read
  @override
  Future<OAuthToken?> fetch() async {
    return _token;
  }

  /// Save
  @override
  Future<OAuthToken> save(OAuthToken token) async {
    return _token = token;
  }

  /// Clear
  @override
  Future<void> clear() async {
    _token = null;
  }

  @override
  String? get accessToken => _token?.accessToken; */
}

/// Encode String To Base64
Codec<String, String> stringToBase64 = utf8.fuse(base64);

/// OAuth Client
class OAuth {
  String tokenUrl;
  String clientId;
  String clientSecret;
  Dio dio;
  OAuthStorage storage;
  OAuthTokenExtractor extractor;
  OAuthTokenValidator validator;

  OAuth({
    required this.tokenUrl,
    required this.clientId,
    required this.clientSecret,
    Dio? dio,
    OAuthStorage? storage,
    OAuthTokenExtractor? extractor,
    OAuthTokenValidator? validator,
  })  : dio = dio ?? Dio(),
        storage = storage ?? OAuthMemoryStorage(),
        extractor = extractor ?? ((res) => OAuthToken.fromMap(res.data)),
        validator = validator ?? ((token) => Future.value(!token.isExpired));

  Future<OAuthToken> requestTokenAndSave(OAuthGrantType grantType) async {
    return requestToken(grantType).then((token) => storage.save(token));
  }

  /// Request a new Access Token using a strategy
  Future<OAuthToken> requestToken(OAuthGrantType grantType) {
    if (grantType is ProviderTokenGrant) {
      final currentUser = FirebaseAuth.instance.currentUser!;
      return currentUser.getIdTokenResult().then((idTokenResult) {
        return OAuthToken(
          refreshToken: "",
          accessToken: idTokenResult.token,
          userId: currentUser.uid,
          expiration: idTokenResult.expirationTime,
          isProviderSignIn: true,
        );
      });
    } else {
      final request = grantType.handle(
        RequestOptions(
          method: 'POST',
          path: '/',
        ),
      );

      return dio
          .request(tokenUrl,
              data: request.data,
              options: Options(
                contentType: request.contentType,
                headers: request.headers,
                method: request.method,
              ))
          .then((res) => extractor(res));
    }
  }

  /// return current access token or refresh
  Future<OAuthToken?> fetchOrRefreshAccessToken() async {
    OAuthToken? token = await storage.fetch();

    if (token?.accessToken == null) {
      throw OAuthException('missing_access_token', 'Missing access token!');
    }

    if (await validator(token!)) return token;

    return refreshAccessToken();
  }

  /// Refresh Access Token
  Future<OAuthToken> refreshAccessToken() async {
    OAuthToken? token = await storage.fetch();

    if (token == null) {
      throw OAuthException('missing_oauth_token', 'Missing oauth token!');
    }

    if (token.isProviderSignIn) {
      return requestTokenAndSave(ProviderTokenGrant());
    }

    if (token.refreshToken.isEmpty) {
      throw OAuthException('missing_refresh_token', 'Missing refresh token!');
    }

    return requestTokenAndSave(
        RefreshTokenGrant(refreshToken: token.refreshToken));
  }
}
 */