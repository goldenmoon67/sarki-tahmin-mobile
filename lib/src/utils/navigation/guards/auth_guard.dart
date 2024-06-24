import 'package:auto_route/auto_route.dart';


bool isAuthenticated = true;

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (!isAuthenticated) {
      //TODO:: handle auth
      /*  router.push(
        const LoginRoute(),
      ); */
    } else {
      resolver.next(true);
    }
  }
}
