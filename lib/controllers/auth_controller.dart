import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('Starting Google Sign-In...');
      final result = await _authService.signInWithGoogle();

      if (result == null) {
        print('User cancelled sign-in');
        errorMessage.value = 'Login dibatalkan';
      } else {
        print('Sign-in successful: ${result.user?.email}');
        // Force rebuild atau navigate tidak perlu - StreamBuilder akan handle
        // Tapi kita trigger update untuk memastikan
        await Future.delayed(Duration(milliseconds: 100));
      }
    } catch (e) {
      print('Sign-in error: $e');
      errorMessage.value = 'Login gagal: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint("Logout gagal: $e");
    }
  }
}
