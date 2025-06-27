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
      backgroundColor: const Color(0xFFFFF3E0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SnackGo',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF5722),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Choose your role',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              _roleCard(
                context,
                role: 'User',
                icon: Icons.person_outline,
                color: Colors.deepOrange,
              ),
              const SizedBox(height: 20),
              _roleCard(
                context,
                role: 'Restaurant Owner',
                icon: Icons.store_mall_directory_outlined,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 20),
              _roleCard(
                context,
                role: 'Admin',
                icon: Icons.admin_panel_settings_outlined,
                color: Colors.brown,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard(
    BuildContext context, {
    required String role,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () => navigateToRolePage(context, role),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(width: 20),
            Text(
              role,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
