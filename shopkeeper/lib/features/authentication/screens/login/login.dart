import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shopkeeper/common/buttons/primary_button.dart';
import 'package:shopkeeper/common/customShapes/containers/custom_cliper.dart';
import 'package:shopkeeper/common/widgets/decorations/input_decoration.dart';
import 'package:shopkeeper/features/authentication/controllers/login/login_controller.dart';
import 'package:shopkeeper/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:shopkeeper/utils/constants/colors.dart';
import 'package:shopkeeper/utils/constants/image_strings.dart';
import 'package:shopkeeper/utils/constants/sizes.dart';
import 'package:shopkeeper/utils/constants/text_strings.dart';
import 'package:shopkeeper/utils/validators/validation.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController(), permanent: true);

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomClipperWidget(
              child: Stack(
                children: [
                  Image.asset(
                    TImages.logo,
                    width: screenWidth,
                    height: screenHeight * 0.37,
                    fit: BoxFit.fitWidth,
                  ),
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: const Center(
                      child: Text(
                        "Uni Tools App",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 4,
                              offset: Offset(1, 5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -3,
                    left: 20,
                    child: const Text(
                      "Shopkeeper Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                TSizes.defaultSpace,
                0,
                TSizes.defaultSpace,
                TSizes.defaultSpace,
              ),
              child: Form(
                key: controller.loginFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Email",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: TSizes.sm),
                    TextFormField(
                      controller: controller.email,
                      validator: TValidator.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: TColors.black,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: TInputDecoration.inputDecoration(
                        context,
                        TTexts.email,
                        Iconsax.direct_right,
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    const Text(
                      "Password",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: TSizes.sm),
                    Obx(
                          () => TextFormField(
                        controller: controller.password,
                        validator: TValidator.validatePassword,
                        obscureText: controller.isPasswordHidden.value,
                        cursorColor: TColors.black,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: TInputDecoration.inputDecoration(
                          context,
                          TTexts.password,
                          Iconsax.password_check,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordHidden.value
                                  ? Iconsax.eye_slash
                                  : Iconsax.eye,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    Obx(
                          () => PrimaryButton(
                        text: TTexts.signIn,
                        onPressed: controller.isFormFilled.value
                            ? () {
                          if (controller.loginFormKey.currentState!
                              .validate()) {
                            controller.emailAndPasswordSignIn();
                          }
                        }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            GestureDetector(
              onTap: () => Get.to(() => ForgetPassword()),
              child: Image.asset(
                TImages.loginFooterImage,
                height: screenHeight * 0.1,
              ),
            ),
            const SizedBox(height: 3),

            GestureDetector(
              onTap: () => Get.to(() => ForgetPassword()),
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
