import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigationKey =
      GlobalKey<NavigatorState>();

  static Future<dynamic> navigateTo({required String routeName}) {
    return navigationKey.currentState!.pushNamed(routeName);
  }

  static void goBack({required String routeName}) {
    return navigationKey.currentState!.pop();
  }
}
