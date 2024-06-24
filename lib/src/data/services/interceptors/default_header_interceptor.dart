import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
//import 'package:device_info_plus/device_info_plus.dart';

class DefaultHeaderInterceptor extends Interceptor {
  PackageInfo? _packageInfo;

/*   AndroidDeviceInfo? _androidDeviceInfo;
  IosDeviceInfo? _iosDeviceInfo;
  String? _deviceId; */

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    /* 
    var packageInfo = _packageInfo!;

    if (_deviceId == null || _deviceId!.isEmpty) {
      try {
        _deviceId = await FlutterUdid.udid;
      } catch (ex, stack) {
        ErrorLogger.logError(ex, stack);
      }
    }

    options.headers["X-Package-Name"] = packageInfo.packageName;
    options.headers["X-Version"] = packageInfo.version;
    options.headers["X-Build-Number"] = packageInfo.buildNumber;
    options.headers["x-correlation-id"] = const Uuid().v4();
    options.headers["x-device-id"] = _deviceId;
    options.headers["Accept-Language"] = "en-GB";
    options.headers["X-Api-Key"] = F.apiKey;
    options.headers["X-Api-Version"] = F.apiVersion;
    options.contentType = Headers.jsonContentType;

    if (Platform.isAndroid) {
      _androidDeviceInfo ??= await DeviceInfoPlugin().androidInfo;
      options.headers["X-Os-Type"] = "A";
      options.headers["X-Os-Version"] = _androidDeviceInfo!.version.release;
      options.headers["X-Device-Manufacturer"] =
          _androidDeviceInfo!.manufacturer;
      options.headers["X-Device-Model"] = _androidDeviceInfo!.model;
      options.headers["X-Build-Signature"] = packageInfo.buildSignature;
    } else if (Platform.isIOS) {
      _iosDeviceInfo ??= await DeviceInfoPlugin().iosInfo;
      options.headers["X-Os-Type"] = "I";
      options.headers["X-Os-Version"] = _iosDeviceInfo!.systemVersion;
      options.headers["X-Device-Model"] = _iosDeviceInfo!.utsname.machine;
    }
 */
    super.onRequest(options, handler);
  }
}
