import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unitools/common/buttons/primary_button.dart';
import 'package:unitools/common/widgets/decorations/input_decoration.dart';
import 'package:unitools/utils/constants/text_strings.dart';
import 'package:unitools/utils/validators/validation.dart';

class AddNewStoreKeepersScreen extends StatefulWidget {
  const AddNewStoreKeepersScreen({super.key});

  @override
  State<AddNewStoreKeepersScreen> createState() =>
      _AddNewStoreKeepersScreenState();
}

class _AddNewStoreKeepersScreenState extends State<AddNewStoreKeepersScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordHidden = true;
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      isPasswordHidden = !isPasswordHidden;
    });
  }

  Future<void> _createStorekeeper() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      _showSuccessModal();
    } on FirebaseAuthException catch (e) {
      String message = "An unknown error occurred.";
      if (e.code == 'email-already-in-use') {
        message = "This email is already in use by another account.";
      } else if (e.code == 'weak-password') {
        message = "The password provided is too weak.";
      } else if (e.code == 'invalid-email') {
        message = "The email address is not valid.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSuccessModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                const Text(
                  "Storekeeper Created Successfully!",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                const Text(
                  "The new storekeeper account has been created and is ready to use.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.018),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: const Color(0xFF6366F1),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Back to previous screen",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFFA855F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    const Expanded(
                      child: Text(
                        "Add Storekeeper",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.02),
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Email",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          TextFormField(
                            controller: emailController,
                            validator: TValidator.validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: TInputDecoration.inputDecoration(
                                context, TTexts.email, Iconsax.direct_right),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          const Text(
                            "Password",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          TextFormField(
                            controller: passwordController,
                            validator: TValidator.validatePassword,
                            obscureText: isPasswordHidden,
                            decoration: TInputDecoration.inputDecoration(
                                context, TTexts.password, Iconsax.password_check)
                                .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                    isPasswordHidden
                                        ? Iconsax.eye_slash
                                        : Iconsax.eye,
                                    color: Colors.grey),
                                onPressed: togglePasswordVisibility,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          isLoading
                              ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6366F1),
                            ),
                          )
                              : PrimaryButton(
                            text: "Create Storekeeper",
                            onPressed: _createStorekeeper,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
