import 'package:default_flutter_project/src/configs/flavors.dart';
import 'package:default_flutter_project/src/logs/log_console.dart';
import 'package:default_flutter_project/src/utils/navigation/app_router.dart';
import 'package:default_flutter_project/src/utils/navigation/guards/auth_guard.dart';
// ignore: depend_on_referenced_packages
import "package:get_it/get_it.dart";

import 'package:logger/logger.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show
        AndroidOptions,
        FlutterSecureStorage,
        IOSOptions,
        KeychainAccessibility;

GetIt getIt = GetIt.I;

Future setupGetIt({bool testing = false}) async {
  Logger logger = Logger(
    filter: ProductionFilter(),
    printer: SimplePrinter(colors: false),
    output: LogConsole.wrap(),
  );
  getIt.registerSingleton<Logger>(logger);
  getIt.registerSingleton(AppRouter(authGuard: AuthGuard()));
  getIt.registerSingleton(FlutterSecureStorage(
    iOptions: IOSOptions(
      groupId: F.appGroupName,
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  ));
}
