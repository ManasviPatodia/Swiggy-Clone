import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'restaurant_home_page.dart';
import 'welcome_page.dart';
import 'restaurant_signup_page.dart';
import 'restaurant_login_page.dart';
import 'setup_page.dart';
import 'cart_page.dart';
import 'splash_page.dart';
import 'restaurant_page.dart';
import 'user_profile_page.dart';

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
      home: const SplashPage(),
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/restaurantSignup': (context) => const RestaurantSignupPage(),
        '/restaurantLogin': (context) => const RestaurantLoginPage(),
        '/cart': (context) => const CartPage(),
        '/userProfile': (context) => const UserProfilePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/restaurantSetup') {
          final restaurantId = settings.arguments as String;
          return MaterialPageRoute(
            builder:
                (context) => RestaurantSetupPage(restaurantId: restaurantId),
          );
        }

        if (settings.name == '/restaurantHome') {
          final restaurantId = settings.arguments as String;
          return MaterialPageRoute(
            builder:
                (context) => FutureBuilder<DocumentSnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection('restaurants')
                          .doc(restaurantId)
                          .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;

                    final hasSetup =
                        data != null &&
                        data['restaurantImage'] != null &&
                        data['menuImage'] != null;

                    if (hasSetup) {
                      return RestaurantHomePage(restaurantId: restaurantId);
                    } else {
                      return RestaurantSetupPage(restaurantId: restaurantId);
                    }
                  },
                ),
          );
        }

        if (settings.name == '/restaurantPage') {
          final restaurantId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => RestaurantPage(restaurantId: restaurantId),
          );
        }

        return null;
      },
    );
  }
}
