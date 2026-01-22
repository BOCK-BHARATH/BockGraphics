import 'package:flutter/material.dart';
import '../auth/token_store.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getTokenStore().read(),
      builder: (context, snapshot) {
        // ✅ Proper loading check
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ If error, go to login (and show error)
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Auth error: ${snapshot.error}"),
            ),
          );
        }

        final token = snapshot.data; // can be null

        // ✅ No token -> Login
        if (token == null || token.isEmpty) {
          return const LoginScreen();
        }

        // ✅ Token exists -> Home
        return const HomeScreen();
      },
    );
  }
}
