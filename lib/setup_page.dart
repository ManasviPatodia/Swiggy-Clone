import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class RestaurantSetupPage extends StatefulWidget {
  final String restaurantId;
  const RestaurantSetupPage({super.key, required this.restaurantId});

  @override
  State<RestaurantSetupPage> createState() => _RestaurantSetupPageState();
}

class _RestaurantSetupPageState extends State<RestaurantSetupPage> {
  final List<String> cuisines = [
    'Cafe',
    'Italian',
    'Chinese',
    'Indian',
    'Asian',
    'South Indian',
    'Continental',
    'Thai',
    'Street Food',
    'Mexican',
    'Breakfast',
    'Dessert',
  ];

  List<String> selectedCuisines = [];
  File? restaurantImage;
  File? menuImage;
  final picker = ImagePicker();
  final priceController = TextEditingController();
  bool isLoading = false;

  final String cloudinaryUploadUrl =
      "https://api.cloudinary.com/v1_1/dqqqng5r9/image/upload";
  final String uploadPreset = "snackgo_upload";

  Future<String?> uploadToCloudinary(File file) async {
    final request =
        http.MultipartRequest('POST', Uri.parse(cloudinaryUploadUrl))
          ..fields['upload_preset'] = uploadPreset
          ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      return jsonResponse['secure_url'];
    } else {
      print("Cloudinary upload failed: ${response.statusCode}");
      return null;
    }
  }

  Future<void> _pickImage(bool isRestaurant) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isRestaurant) {
          restaurantImage = File(picked.path);
        } else {
          menuImage = File(picked.path);
        }
      });
    }
  }

  Future<void> _submitSetup() async {
    if (restaurantImage == null ||
        menuImage == null ||
        selectedCuisines.isEmpty ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final restaurantUrl = await uploadToCloudinary(restaurantImage!);
      final menuUrl = await uploadToCloudinary(menuImage!);

      if (restaurantUrl == null || menuUrl == null) {
        throw Exception("Image upload failed");
      }

      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .set({
            'cuisines': selectedCuisines,
            'restaurantImage': restaurantUrl,
            'menuImage': menuUrl,
            'priceForTwo': int.parse(priceController.text),
            'setupComplete': true,
          }, SetOptions(merge: true));

      Navigator.pushReplacementNamed(
        context,
        '/restaurantHome',
        arguments: widget.restaurantId,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Set up your Restaurant"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Choose your cuisines:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              children:
                  cuisines.map((cuisine) {
                    final isSelected = selectedCuisines.contains(cuisine);
                    return FilterChip(
                      label: Text(cuisine),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            selectedCuisines.add(cuisine);
                          } else {
                            selectedCuisines.remove(cuisine);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _pickImage(true),
              icon: const Icon(Icons.image),
              label: const Text("Upload Restaurant Image"),
            ),
            if (restaurantImage != null)
              Image.file(restaurantImage!, height: 150),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _pickImage(false),
              icon: const Icon(Icons.menu_book),
              label: const Text("Upload Menu Image"),
            ),
            if (menuImage != null) Image.file(menuImage!, height: 150),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price for Two",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _submitSetup,
                  child: const Text("Submit & Continue"),
                ),
          ],
        ),
      ),
    );
  }
}
