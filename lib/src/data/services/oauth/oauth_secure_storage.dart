/* import 'package:default_flutter_project/src/data/services/secure/secure_storage_service.dart';
import 'package:default_flutter_project/src/utils/di/getit_register.dart';

import 'oauth.dart';

class OAuthSecureStorage extends OAuthStorage {
  final SecureStorageService storageService = getIt<SecureStorageService>();
  OAuthToken? _token;

  OAuthSecureStorage();

  @override
  String? get accessToken => _token?.accessToken;

  @override
  Future<OAuthToken?> fetch() async {
    _token ??= await storageService.getOAuthToken();
    return _token;
  }

  @override
  Future<OAuthToken> save(OAuthToken token) async {
    await storageService.setOAuthToken(token);
    _token = token;
    return token; /*  */
  }

  @override
  Future<void> clear() async {
    await storageService.deleteOAuthToken();
    _token = null;
  }
}
 */