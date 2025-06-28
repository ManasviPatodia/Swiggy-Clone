import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_home_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  String? restaurantId;
  int totalPrice = 0;
  int selectedDelivery = 0;

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserHomePage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('cart')
            .doc('currentCart')
            .get();
    if (snapshot.exists) {
      final data = snapshot.data()!;
      setState(() {
        restaurantId = data['restaurantId'];
        cartItems = List<Map<String, dynamic>>.from(data['items']);
        totalPrice = cartItems.fold<int>(
          0,
          (sum, item) => sum + (item['price'] as int),
        );
      });
    }
  }

  Future<void> removeItem(int index) async {
    cartItems.removeAt(index);
    totalPrice = cartItems.fold<int>(
      0,
      (sum, item) => sum + (item['price'] as int),
    );
    if (cartItems.isEmpty) {
      await FirebaseFirestore.instance
          .collection('cart')
          .doc('currentCart')
          .delete();
      restaurantId = null;
    } else {
      await FirebaseFirestore.instance
          .collection('cart')
          .doc('currentCart')
          .set({'restaurantId': restaurantId, 'items': cartItems});
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Review Order")),
      body:
          cartItems.isEmpty
              ? const Center(child: Text("Your cart is empty."))
              : Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      "✅ ₹24 saved! On this order",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  Container(
                    color: Colors.grey.shade100,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("You are ordering for Mamta 🎁"),
                        Text(
                          "EDIT",
                          style: TextStyle(color: Colors.deepOrange),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return ListTile(
                          leading: Image.network(
                            item['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(item['name']),
                          subtitle: Text("₹${item['price']}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => removeItem(index),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.local_offer, color: Colors.deepOrange),
                            SizedBox(width: 8),
                            Text(
                              "₹24 saved with 'Items at ₹29'",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Delivery Type",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text("Standard (35–40 mins)"),
                                leading: Radio<int>(
                                  value: 0,
                                  groupValue: selectedDelivery,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDelivery = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  "Eco Saver (40–45 mins)",
                                  style: TextStyle(color: Colors.deepOrange),
                                ),
                                leading: Radio<int>(
                                  value: 1,
                                  groupValue: selectedDelivery,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDelivery = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total to Pay",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "₹$totalPrice",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Free delivery with One Lite up to 7 km",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.deepOrange,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Checkout not implemented yet."),
                        ),
                      );
                    },
                    child: Text(
                      "Pay ₹$totalPrice",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.deepOrange,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
