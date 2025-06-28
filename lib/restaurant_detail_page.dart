import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class RestaurantDetailsPage extends StatefulWidget {
  final String restaurantId;
  const RestaurantDetailsPage({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  final TextEditingController _dishNameController = TextEditingController();
  final TextEditingController _dishPriceController = TextEditingController();
  File? _pickedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    const uploadPreset = 'snackgo_upload';

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/dqqqng5r9/image/upload',
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
      print('Failed to upload image: ${response.statusCode}');
      return null;
    }
  }

  Future<void> _addDish() async {
    if (_dishNameController.text.isEmpty ||
        _dishPriceController.text.isEmpty ||
        _pickedImage == null) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final imageUrl = await _uploadImageToCloudinary(_pickedImage!);
    if (imageUrl != null) {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('dishes')
          .add({
            'name': _dishNameController.text.trim(),
            'price': int.tryParse(_dishPriceController.text.trim()) ?? 0,
            'imageUrl': imageUrl,
          });

      setState(() {
        _dishNameController.clear();
        _dishPriceController.clear();
        _pickedImage = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Dish added")));
    }

    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurantDoc = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId);
    final dishesStream = restaurantDoc.collection('dishes').snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text("Restaurant Menu")),
      body: FutureBuilder<DocumentSnapshot>(
        future: restaurantDoc.get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  data['restaurantImage'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: Text(
                    data['restaurantName'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(data['cuisines'].join(', ')),
                  trailing: Text("₹${data['priceForTwo']} for 2"),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Menu",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Image.network(
                  data['menuImage'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
                const Divider(),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Add New Dish",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      TextField(
                        controller: _dishNameController,
                        decoration: const InputDecoration(
                          labelText: 'Dish Name',
                        ),
                      ),
                      TextField(
                        controller: _dishPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Price'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text("Pick Image"),
                          ),
                          const SizedBox(width: 10),
                          if (_pickedImage != null)
                            const Text("Image selected"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isUploading ? null : _addDish,
                        child:
                            _isUploading
                                ? const CircularProgressIndicator()
                                : const Text("Upload Dish"),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                StreamBuilder<QuerySnapshot>(
                  stream: dishesStream,
                  builder: (context, dishSnapshot) {
                    if (!dishSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final dishes = dishSnapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dishes.length,
                      itemBuilder: (context, index) {
                        final dish = dishes[index];
                        return ListTile(
                          leading: Image.network(
                            dish['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(dish['name']),
                          subtitle: Text("₹${dish['price']}"),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              final cartRef = FirebaseFirestore.instance
                                  .collection('cart')
                                  .doc('currentCart');
                              final cartSnap = await cartRef.get();

                              final newItem = {
                                'name': dish['name'],
                                'price': dish['price'],
                                'imageUrl': dish['imageUrl'],
                              };

                              if (cartSnap.exists) {
                                final cartData = cartSnap.data()!;
                                if (cartData['restaurantId'] !=
                                    widget.restaurantId) {
                                  await cartRef.set({
                                    'restaurantId': widget.restaurantId,
                                    'items': [newItem],
                                  });
                                } else {
                                  final items = List<Map<String, dynamic>>.from(
                                    cartData['items'],
                                  );
                                  items.add(newItem);
                                  await cartRef.set({
                                    'restaurantId': widget.restaurantId,
                                    'items': items,
                                  });
                                }
                              } else {
                                await cartRef.set({
                                  'restaurantId': widget.restaurantId,
                                  'items': [newItem],
                                });
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Added to cart")),
                              );
                            },
                            child: const Text("Add"),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
