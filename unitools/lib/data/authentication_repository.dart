import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:unitools/features/authentication/screens/login/login.dart';
import 'package:unitools/features/home/HomeScreen.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onReady() {
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  void screenRedirect() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        Get.offAll(() => const HomeScreen());
      } else {
        Get.offAll(() => const LoginScreen());
      }
    });
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getMessageFromErrorCode(e.code));
    } catch (e) {
      throw Exception('Something went wrong. Please try again.');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      final box = Get.find<GetStorage>();
      box.remove('REMEMBER_ME_EMAIL');
      box.remove('REMEMBER_ME_PASSWORD');
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      throw Exception('Unable to logout. Please try again.');
    }
  }

  String _getMessageFromErrorCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
