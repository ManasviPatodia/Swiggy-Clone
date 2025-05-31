import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class RestaurantSignupPage extends StatefulWidget {
  const RestaurantSignupPage({super.key});

  @override
  State<RestaurantSignupPage> createState() => _RestaurantSignupPageState();
}

class _RestaurantSignupPageState extends State<RestaurantSignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _restaurantId;
  String? _errorMessage;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final uid = userCred.user!.uid;
      final restaurantId = const Uuid().v4().substring(0, 8); // short ID

      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .set({
            'email': _emailController.text.trim(),
            'restaurantName': _restaurantNameController.text.trim(),
            'ownerName': _ownerNameController.text.trim(),
            'uid': uid,
            'createdAt': FieldValue.serverTimestamp(),
          });

      setState(() => _restaurantId = restaurantId);
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Restaurant Owner Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              if (_restaurantId != null)
                Text(
                  "Signup successful! Your Restaurant ID: $_restaurantId",
                  style: const TextStyle(color: Colors.green),
                ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator:
                    (value) =>
                        value == null || !value.contains('@')
                            ? 'Enter valid email'
                            : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator:
                    (value) =>
                        value == null || value.length < 6
                            ? 'Min 6 characters'
                            : null,
              ),
              TextFormField(
                controller: _restaurantNameController,
                decoration: const InputDecoration(labelText: 'Restaurant Name'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter restaurant name'
                            : null,
              ),
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(labelText: 'Owner Name'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter owner name'
                            : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _signUp,
                    child: const Text("Sign Up"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
