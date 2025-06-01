import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'welcome_page.dart';
import 'restaurant_signup_page.dart';
import 'restaurant_login_page.dart';
import 'splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SnackGoApp());
}

class SnackGoApp extends StatelessWidget {
  const SnackGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnackGo',
      debugShowCheckedModeBanner: false,
      // Start at SplashPage
      home: const SplashPage(),
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/restaurantSignup': (context) => const RestaurantSignupPage(),
        '/restaurantLogin': (context) => const RestaurantLoginPage(),
      },
    );
  }
}
