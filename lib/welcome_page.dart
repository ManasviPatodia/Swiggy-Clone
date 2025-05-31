import 'package:flutter/material.dart';
import 'login_page.dart';
import 'restaurant_login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void navigateToRolePage(BuildContext context, String role) {
    if (role == 'User') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else if (role == 'Restaurant Owner') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RestaurantLoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$role login not yet implemented')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 247, 239),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SnackGo',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Who are you?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed:
                    () => navigateToRolePage(context, 'Restaurant Owner'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 94, 19),
                  foregroundColor: const Color.fromARGB(255, 51, 30, 30),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Restaurant Owner'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => navigateToRolePage(context, 'Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 94, 19),
                  foregroundColor: const Color.fromARGB(255, 51, 30, 30),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Admin'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => navigateToRolePage(context, 'User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 94, 19),
                  foregroundColor: const Color.fromARGB(255, 51, 30, 30),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
