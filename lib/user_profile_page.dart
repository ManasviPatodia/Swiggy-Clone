import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'refer_and_earn_page.dart';
import 'help_And_support_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: user?.displayName ?? "User");
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      debugPrint("Logout error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed. Try again.')),
      );
    }
  }

  Widget _buildProfileRow(IconData icon, String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 252, 247),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Colors.black87),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final photo = user.photoURL;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage:
                photo != null
                    ? NetworkImage(photo)
                    : const AssetImage('assets/default_user.png')
                        as ImageProvider,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(border: InputBorder.none),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              onSubmitted: (newName) async {
                await user.updateDisplayName(newName);
                setState(() {});
              },
            ),
          ),
          Text(user.email ?? '', style: const TextStyle(color: Colors.grey)),
          const Divider(thickness: 1, height: 30),
          Expanded(
            child: ListView(
              children: [
                _buildProfileRow(Icons.history, 'Previous Orders', () {
                  Navigator.pushNamed(context, '/orders');
                }),
                _buildProfileRow(Icons.favorite_border, 'Favourites', () {
                  Navigator.pushNamed(context, '/favourites');
                }),
                _buildProfileRow(Icons.card_giftcard, 'My Vouchers', () {
                  Navigator.pushNamed(context, '/vouchers');
                }),
                _buildProfileRow(Icons.emoji_people, 'Refer & Earn', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReferAndEarnPage(),
                    ),
                  );
                }),
                _buildProfileRow(Icons.help_outline, 'Help & Support', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpAndSupportPage(),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/restaurantLogin');
                  },
                  icon: const Icon(Icons.storefront, color: Colors.deepOrange),
                  label: const Text(
                    "Switch to Restaurant Owner",
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
