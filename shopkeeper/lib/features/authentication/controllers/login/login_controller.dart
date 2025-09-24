import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopkeeper/data/authentication_repository.dart';
import 'package:shopkeeper/utils/helpers/network_manager.dart';
import 'package:shopkeeper/utils/validators/validation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends GetxController {
  final isPasswordHidden = true.obs;
  final isFormFilled = false.obs;

  final email = TextEditingController();
  final password = TextEditingController();

  final loginFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    email.addListener(checkFormCompletion);
    password.addListener(checkFormCompletion);
    super.onInit();
  }

  void checkFormCompletion() {
    final isEmailValid = TValidator.validateEmail(email.text) == null;
    final isPasswordValid = TValidator.validatePassword(password.text) == null;
    isFormFilled.value = isEmailValid && isPasswordValid;
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> emailAndPasswordSignIn() async {
    // Show loader
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        if (Get.isDialogOpen ?? false) Get.back();
        Get.snackbar("No Internet", "Please check your internet connection.");
        return;
      }

      await AuthenticationRepository.instance.loginWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );

      if (Get.isDialogOpen ?? false) Get.back();
      // Navigation is auto-handled by AuthenticationRepository via authStateChanges
    } on FirebaseAuthException catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Login Error", e.message ?? "Invalid credentials.");
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", e.toString());
    }
  }
}
