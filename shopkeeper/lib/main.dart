import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:shopkeeper/data/authentication_repository.dart';
import 'package:shopkeeper/features/authentication/screens/login/login.dart';
import 'package:shopkeeper/features/home/HomeScreen.dart';
import 'package:shopkeeper/firebase_options.dart';
import 'package:shopkeeper/utils/helpers/network_manager.dart';
import 'package:shopkeeper/utils/theme/theme.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NetworkManager(), permanent: true);
    Get.put(AuthenticationRepository(), permanent: true);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "UniToolsStorekeeper",
      theme: TAppTheme.lightTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}

