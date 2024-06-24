enum Flavor {
  dev,
  prod,
}

class F {
  static Flavor appFlavor = Flavor.dev;

  static String get baseUrl {
    switch (appFlavor) {
      case Flavor.dev:
        //return 'http://localhost:5200/'; //ios simulator
        //return 'http://10.0.2.2:5200/';//android emulator
        return "http://10.0.2.2:8080/api/";
      case Flavor.prod:
      default:
        return "http://10.0.2.2:8080/api/";
    }
  }

  static String get appGroupName {
    switch (appFlavor) {
      case Flavor.dev:
        return "ApiConsts.devAppGroupName";
      case Flavor.prod:
      default:
        return "ApiConsts.prodAppGroupName";
    }
  }

  static String get scheme {
    switch (appFlavor) {
      case Flavor.dev:
        return "ApiConsts.devScheme";
      case Flavor.prod:
      default:
        return "ApiConsts.prodScheme";
    }
  }

  static bool get logging {
    switch (appFlavor) {
      case Flavor.dev:
        return true;
      case Flavor.prod:
      default:
        return false;
    }
  }

  static String get apiKey {
    switch (appFlavor) {
      case Flavor.dev:
        return "ApiConsts.devApiKey";
      case Flavor.prod:
      default:
        return "ApiConsts.prodApiKey";
    }
  }

  static String get apiVersion {
    switch (appFlavor) {
      case Flavor.dev:
        return "ApiConsts.devApiVersion";
      case Flavor.prod:
      default:
        return "s";
    }
  }
}
