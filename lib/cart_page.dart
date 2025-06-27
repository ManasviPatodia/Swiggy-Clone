import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  String? restaurantId;
  int totalPrice = 0;

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
          (int sum, item) => sum + (item['price'] as int),
        );
      });
    }
  }

  Future<void> removeItem(int index) async {
    cartItems.removeAt(index);
    totalPrice = cartItems.fold<int>(
      0,
      (int sum, item) => sum + (item['price'] as int),
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
      appBar: AppBar(title: const Text("Your Cart")),
      body:
          cartItems.isEmpty
              ? const Center(child: Text("Your cart is empty."))
              : Column(
                children: [
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("₹${item['price']}"),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => removeItem(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total: ₹$totalPrice",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Checkout not implemented yet."),
                              ),
                            );
                          },
                          child: const Text("Checkout"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
