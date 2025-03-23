import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/pin_auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';

class IndustrialMonitorApp extends StatelessWidget {
  const IndustrialMonitorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        return MaterialApp(
          title: 'Industrial Monitor',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system, // Use system theme by default
          initialRoute: _initialRoute(authService),
          routes: AppRoutes.routes,
        );
      },
    );
  }

  String _initialRoute(AuthService authService) {
    if (!authService.isLoggedIn) {
      return LoginScreen.routeName;
    } else if (!authService.isPinVerified) {
      return PinAuthScreen.routeName;
    } else {
      return HomeScreen.routeName;
    }
  }
}
