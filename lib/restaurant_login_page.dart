import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'restaurant_signup_page.dart';

class RestaurantLoginPage extends StatefulWidget {
  const RestaurantLoginPage({super.key});

  @override
  State<RestaurantLoginPage> createState() => _RestaurantLoginPageState();
}

class _RestaurantLoginPageState extends State<RestaurantLoginPage> {
  final _restaurantIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final restaurantId = _restaurantIdController.text.trim();
      final doc =
          await FirebaseFirestore.instance
              .collection('restaurants')
              .doc(restaurantId)
              .get();

      if (!doc.exists) {
        setState(() => _errorMessage = "Invalid Restaurant ID");
        return;
      }

      final data = doc.data();
      final email = data?['email'];
      if (email == null) {
        setState(() => _errorMessage = "Email not found for this ID");
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      final bool isSetupComplete =
          data!.containsKey('cuisines') &&
          data.containsKey('restaurantImage') &&
          data.containsKey('menuImage') &&
          data.containsKey('priceForTwo') &&
          (data['cuisines'] as List).isNotEmpty &&
          (data['restaurantImage'] as String).isNotEmpty &&
          (data['menuImage'] as String).isNotEmpty &&
          data['priceForTwo'] != null;

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        isSetupComplete ? '/restaurantHome' : '/restaurantSetup',
        arguments: restaurantId,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = "An unexpected error occurred.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 247, 239),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.store,
                size: 80,
                color: Color.fromARGB(255, 255, 94, 19),
              ),
              const SizedBox(height: 20),
              const Text(
                "Restaurant Login",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 223, 84, 75),
                  ),
                ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _restaurantIdController,
                      decoration: const InputDecoration(
                        labelText: 'Restaurant ID',
                        prefixIcon: Icon(Icons.vpn_key),
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter Restaurant ID'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator:
                          (value) =>
                              value == null || value.length < 6
                                  ? 'Enter valid password'
                                  : null,
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                255,
                                94,
                                19,
                              ),
                              foregroundColor: const Color.fromARGB(
                                255,
                                51,
                                30,
                                30,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _login,
                            child: const Text(
                              "Login",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RestaurantSignupPage(),
                    ),
                  );
                },
                child: const Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
