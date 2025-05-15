import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import '../services/payment_service.dart';

final GetIt locator = GetIt.instance;

void setUpLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => PaymentService());
}

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic>? navigateTo(String routeName) {
    return navigatorKey.currentState
        ?.pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  Future<dynamic>? navigatePush(Route route) {
    return navigatorKey.currentState?.push(route);
  }

  void goBack() {
    return navigatorKey.currentState?.pop();
  }
}
