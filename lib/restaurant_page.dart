import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RestaurantPage extends StatefulWidget {
  final String restaurantId;
  const RestaurantPage({super.key, required this.restaurantId});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  String restaurantName = 'Loading...';
  final TextEditingController _searchController = TextEditingController();

  List<QueryDocumentSnapshot> allDishes = [];
  List<QueryDocumentSnapshot> filteredDishes = [];
  bool hasLoadedDishes = false;

  @override
  void initState() {
    super.initState();
    fetchRestaurantName();
    _searchController.addListener(() {
      filterDishes(_searchController.text);
    });
  }

  Future<void> fetchRestaurantName() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .get();

    if (doc.exists) {
      setState(() {
        restaurantName = doc.data()?['restaurantName'] ?? 'Unnamed Restaurant';
      });
    }
  }

  void filterDishes(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredDishes = [...allDishes];
      } else {
        filteredDishes =
            allDishes.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name']?.toString().toLowerCase() ?? '';
              return name.contains(query.toLowerCase());
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F0),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserHomePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('restaurants')
                        .doc(widget.restaurantId)
                        .collection('dishes')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading dishes"));
                  }

                  final docs = snapshot.data!.docs;

                  if (!hasLoadedDishes) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        allDishes = docs;
                        filteredDishes = [...allDishes];
                        hasLoadedDishes = true;
                      });
                    });
                  }

                  return buildDishUI();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDishUI() {
    if (allDishes.isEmpty) {
      return const Center(child: Text('No dishes available.'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      restaurantName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "4.4 ★",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  "45–50 mins • Lake Town",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  "20% off upto ₹125 • USE AMEXCORP | ABOVE ₹499",
                  style: TextStyle(color: Colors.deepOrange),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for dishes",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                filterChip("Veg", true),
                filterChip("Non-Veg", false),
                filterChip("Ratings 4.0+", false),
                filterChip("Bestseller", false),
              ],
            ),
          ),
          const SizedBox(height: 20),
          sectionTitle("Top Picks"),
          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredDishes.length,
              itemBuilder: (context, index) {
                final data =
                    filteredDishes[index].data() as Map<String, dynamic>;
                return dishCard(data);
              },
            ),
          ),
          sectionTitle("Dishes"),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredDishes.length,
            itemBuilder: (context, index) {
              final data = filteredDishes[index].data() as Map<String, dynamic>;
              return topPickCard(data);
            },
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget filterChip(String label, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.green.shade50 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? Colors.green : Colors.grey),
      ),
      child: Text(
        label,
        style: TextStyle(color: selected ? Colors.green : Colors.black),
      ),
    );
  }

  Widget dishCard(Map<String, dynamic> data) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(left: 16, bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              data['imageUrl'] ?? '',
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  data['name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text("₹${data['price']}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget topPickCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            data['imageUrl'] ?? '',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          ),
        ),
        title: Text(data['name'] ?? 'Unnamed Dish'),
        subtitle: Text("₹${data['price']}"),
        trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser!;
            final cartRef = FirebaseFirestore.instance
                .collection('carts')
                .doc(user.uid);
            final snapshot =
                await FirebaseFirestore.instance
                    .collection('carts')
                    .doc(user.uid)
                    .get();

            final itemToAdd = {
              'name': data['name'],
              'price': data['price'],
              'imageUrl': data['imageUrl'] ?? '',
            };

            if (snapshot.exists) {
              final cartData = snapshot.data()!;
              final existingRestaurantId = cartData['restaurantId'];
              final List<dynamic> items = cartData['items'];

              if (existingRestaurantId != widget.restaurantId) {
                await cartRef.set({
                  'restaurantId': widget.restaurantId,
                  'items': [itemToAdd],
                });
              } else {
                items.add(itemToAdd);
                await cartRef.update({'items': items});
              }
            } else {
              await cartRef.set({
                'restaurantId': widget.restaurantId,
                'items': [itemToAdd],
              });
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${data['name']} added to cart")),
            );
          },
        ),
      ),
    );
  }
}
