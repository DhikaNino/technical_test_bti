import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'start_screen.dart';
import 'main_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print(
          'Auth state: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, data: ${snapshot.data?.email}',
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData) {
          print('Redirecting to MainScreen for: ${snapshot.data!.email}');
          return const MainScreen(key: ValueKey('main-screen'));
        }

        return StartScreen(key: const ValueKey('start-screen'));
      },
    );
  }
}
