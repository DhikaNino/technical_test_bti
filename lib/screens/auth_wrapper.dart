import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'start_screen.dart';
import 'main_screen.dart';

class AuthWrapper extends StatelessWidget {
  AuthWrapper({super.key});

  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authController.authStateChanges,
      builder: (context, snapshot) {
        print(
          'Auth state: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, data: ${snapshot.data}',
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          print('User is logged in: ${snapshot.data!.email}');
          return const MainScreen();
        }
        print('User is not logged in');
        return StartScreen();
      },
    );
  }
}
