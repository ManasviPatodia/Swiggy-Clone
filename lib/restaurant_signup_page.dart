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
  bool _agreedToTerms = false;

  bool get _isFormValid =>
      _emailController.text.isNotEmpty &&
      _passwordController.text.length >= 6 &&
      _restaurantNameController.text.isNotEmpty &&
      _ownerNameController.text.isNotEmpty &&
      _agreedToTerms;

  Future<void> _completeSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      setState(() {
        _errorMessage = 'You must agree to the Privacy Policy & Terms.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        setState(() => _errorMessage = 'No user logged in.');
        return;
      }

      if (_emailController.text.trim() != currentUser.email) {
        setState(
          () => _errorMessage = 'Email does not match your login email.',
        );
        return;
      }

      final uid = currentUser.uid;
      final restaurantId = const Uuid().v4().substring(0, 8);

      await currentUser.updatePassword(_passwordController.text.trim());

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
      backgroundColor: const Color(0xFFFFF7F0),
      appBar: AppBar(
        title: const Text("Restaurant Owner Setup"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        leading: BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: Column(
            children: [
              const Icon(
                Icons.restaurant_menu,
                size: 80,
                color: Colors.deepOrange,
              ),
              const SizedBox(height: 16),
              const Text(
                "Complete Your Restaurant Profile",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              if (_restaurantId != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Setup successful!\nYour Restaurant ID: $_restaurantId",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              _buildTextField(
                controller: _emailController,
                label: "Email",
                icon: Icons.email,
                isPassword: false,
                validator:
                    (value) =>
                        value == null || !value.contains('@')
                            ? 'Enter valid email'
                            : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: "New Password",
                icon: Icons.lock,
                isPassword: true,
                validator:
                    (value) =>
                        value == null || value.length < 6
                            ? 'Min 6 characters'
                            : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _restaurantNameController,
                label: "Restaurant Name",
                icon: Icons.store,
                isPassword: false,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter restaurant name'
                            : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ownerNameController,
                label: "Owner Name",
                icon: Icons.person,
                isPassword: false,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter owner name'
                            : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (val) {
                      setState(() {
                        _agreedToTerms = val ?? false;
                      });
                    },
                    activeColor: Colors.deepOrange,
                  ),
                  const Expanded(
                    child: Text(
                      "I agree to the Privacy Policy and Terms & Conditions",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isFormValid ? _completeSignup : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.deepOrange.withOpacity(
                          0.4,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Finish Setup",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isPassword,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepOrange),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepOrange),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
        ),
      ),
    );
  }
}
