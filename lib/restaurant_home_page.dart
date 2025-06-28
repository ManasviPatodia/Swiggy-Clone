import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class RestaurantHomePage extends StatefulWidget {
  final String restaurantId;
  const RestaurantHomePage({super.key, required this.restaurantId});

  @override
  State<RestaurantHomePage> createState() => _RestaurantHomePageState();
}

class _RestaurantHomePageState extends State<RestaurantHomePage> {
  List<Map<String, dynamic>> dishes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDishes();
  }

  Future<void> fetchDishes() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .collection('dishes')
            .get();

    final data = snapshot.docs.map((doc) => doc.data()).toList();
    setState(() {
      dishes = data;
      isLoading = false;
    });
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'dqqqng5r9';
    const uploadPreset = 'snackgo_upload';

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

    final response = await request.send();
    if (response.statusCode == 200) {
      final resData = await response.stream.bytesToString();
      final jsonData = json.decode(resData);
      return jsonData['secure_url'];
    } else {
      print('Cloudinary upload failed: ${response.statusCode}');
      return null;
    }
  }

  void _showAddDishDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    File? selectedImage;

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: const Text("Add Dish"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: "Dish Name",
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Price"),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final picked = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                selectedImage = File(picked.path);
                              });
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: const Text("Pick Dish Photo"),
                        ),
                        if (selectedImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Image.file(selectedImage!, height: 100),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty ||
                            priceController.text.isEmpty ||
                            selectedImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Fill all fields")),
                          );
                          return;
                        }

                        Navigator.pop(ctx);

                        final imgUrl = await uploadImageToCloudinary(
                          selectedImage!,
                        );
                        if (imgUrl == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Image upload failed"),
                            ),
                          );
                          return;
                        }

                        final docRef =
                            FirebaseFirestore.instance
                                .collection('restaurants')
                                .doc(widget.restaurantId)
                                .collection('dishes')
                                .doc();

                        await docRef.set({
                          'name': nameController.text.trim(),
                          'price': int.parse(priceController.text.trim()),
                          'imageUrl': imgUrl,
                        });

                        fetchDishes();
                      },
                      child: const Text("Add Dish"),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Restaurant Menu"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Dish",
            onPressed: _showAddDishDialog,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : dishes.isEmpty
              ? const Center(child: Text("No dishes added yet."))
              : ListView.builder(
                itemCount: dishes.length,
                itemBuilder: (context, index) {
                  final dish = dishes[index];
                  return ListTile(
                    leading: Image.network(
                      dish['imageUrl'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(dish['name']),
                    trailing: Text("₹${dish['price']}"),
                  );
                },
              ),
    );
  }
}
