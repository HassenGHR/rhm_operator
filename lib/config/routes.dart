import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/pin_auth_screen.dart';
import '../screens/auth/pin_reset_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
        LoginScreen.routeName: (context) => const LoginScreen(),
        PinAuthScreen.routeName: (context) => const PinAuthScreen(),
        PinResetScreen.routeName: (context) => const PinResetScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
      };
}
