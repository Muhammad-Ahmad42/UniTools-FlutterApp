import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unitools/common/buttons/primary_button.dart';
import 'package:unitools/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:unitools/utils/constants/image_strings.dart';
import 'package:unitools/utils/constants/sizes.dart';
import 'package:unitools/utils/constants/text_strings.dart';
import 'package:unitools/utils/validators/validation.dart';

class ForgetPassword extends StatelessWidget {
  ForgetPassword({Key? key}) : super(key: key);

  final GlobalKey<FormState> _forgetFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());

      Get.snackbar(
        "Success",
        "Password reset email sent to ${_emailController.text.trim()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );

      Get.to(() => const ResetPassword());

    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No account exists with this email.";
          break;
        case 'invalid-email':
          message = "Invalid email address format.";
          break;
        default:
          message = "Error: ${e.message}";
      }

      Get.snackbar(
        "Error",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          TTexts.backToSignIn,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          /// Background
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(
              TImages.appLogo,
              fit: BoxFit.fill,
            ),
          ),

          /// Content
          Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 120),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(TSizes.defaultSpace),
                    child: Form(
                      key: _forgetFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: size.height * 0.15,
                            child: Image.asset(
                              TImages.forgotPasswordHeader,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: TSizes.spaceBtwSections),

                          Center(
                            child: Column(
                              children: [
                                Text(
                                  TTexts.forgetPasswordTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: TSizes.spaceBtwItems),
                                Text(
                                  TTexts.forgetPasswordSubTitle,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: TSizes.spaceBtwSections * 2),

                          /// Email Label
                          const Text(
                            TTexts.emailLabelForgotPassword,
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),

                          /// Email Field
                          TextFormField(
                            controller: _emailController,
                            validator: TValidator.validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: TTexts.email,
                              prefixIcon: Icon(Iconsax.direct_right),
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: TSizes.spaceBtwSections),

                          /// Submit Button
                          PrimaryButton(
                            text: TTexts.resetPasswordButton,
                            onPressed: () {
                              if (_forgetFormKey.currentState!.validate()) {
                                _sendPasswordResetEmail(context);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Container(
                color: Colors.white,
                width: double.infinity,
                height: size.height * 0.15,
                child: Image.asset(
                  TImages.forgotPasswordFooter,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
