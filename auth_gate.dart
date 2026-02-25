import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stayease/providers/auth_provider.dart';
import 'package:stayease/features/auth/login_screen.dart';
import 'package:stayease/features/main_navigation/main_navigation_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return auth.isLoggedIn
        ? const MainNavigationScreen()
        : const LoginScreen();
  }
}