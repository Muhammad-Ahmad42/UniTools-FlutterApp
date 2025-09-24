import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unitools/common/buttons/primary_button.dart';
import 'package:unitools/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:unitools/utils/constants/image_strings.dart';
import 'package:unitools/utils/constants/text_strings.dart';
import 'package:unitools/utils/helpers/helper_functions.dart';
import 'package:unitools/utils/constants/sizes.dart';

class ResetPassword extends StatelessWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;

    return Scaffold(
      body: Stack(
        children: [
          /// Background logo
          SizedBox(
            height: screenHeight,
            width: screenWidth,
            child: Image.asset(
              TImages.appLogo,
              fit: BoxFit.fill,
            ),
          ),

          /// Back button
          Positioned(
            top: screenHeight * 0.05, // dynamic
            left: screenWidth * 0.05,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    TTexts.backToForgotPassword,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Content
          Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.18), // dynamic top margin
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
                    child: Column(
                      children: [
                        /// Image with 60% of screen width
                        Image.asset(
                          TImages.forgotPasswordHeader,
                          width: screenWidth * 0.6,
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        /// Title & Subtitle
                        Text(
                          TTexts.changeYourPasswordTitle,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Text(
                          TTexts.changeYourPasswordSubTitle,
                          style: Theme.of(context).textTheme.labelLarge,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.04),

                        /// Buttons
                        PrimaryButton(
                          text: TTexts.doneButton,
                          onPressed: () {
                            Get.to(() => ForgetPassword());
                          },
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(TTexts.resendEmail),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Bottom image/footer
              Container(
                color: Colors.white,
                width: double.infinity,
                height: screenHeight * 0.15, // dynamic height
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
