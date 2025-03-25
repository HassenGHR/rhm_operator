import 'package:flutter/material.dart';
import 'package:industrial_monitor/screens/auth/register_screen.dart';
import 'package:industrial_monitor/screens/auth/set_pin_screen.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/pin_auth_screen.dart';
import '../screens/auth/pin_reset_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
        RegisterScreen.routeName: (context) => const RegisterScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        PinAuthScreen.routeName: (context) => const PinAuthScreen(),
        PinSetupScreen.routeName: (context) => const PinSetupScreen(),
        PinResetScreen.routeName: (context) => const PinResetScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
      };
}
