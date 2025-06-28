import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Logout error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed. Try again.')),
      );
    }
  }

  Widget _buildProfileRow(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(text),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.deepOrange,
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
                  Navigator.pushNamed(context, '/refer');
                }),
                _buildProfileRow(Icons.help_outline, 'Help & Support', () {
                  Navigator.pushNamed(context, '/help');
                }),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}
