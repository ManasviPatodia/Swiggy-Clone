import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swiggyclone/main.dart';
import 'user_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SnackGoApp());
}

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
  final int _selectedIndex = 1;

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(user.uid);
    final snapshot = await cartRef.get();

    if (!snapshot.exists || snapshot.data() == null) {
      setState(() {
        cartItems = [];
        restaurantId = null;
        totalPrice = 0;
      });
      return;
    }

    final data = snapshot.data()!;
    final itemsRaw = data['items'];

    if (itemsRaw is! List) return;

    List<Map<String, dynamic>> parsedItems = [];
    int computedTotal = 0;

    for (var item in itemsRaw) {
      if (item is Map<String, dynamic>) {
        final int price = item['price'] is int ? item['price'] : 0;
        final int quantity = item['quantity'] is int ? item['quantity'] : 1;
        parsedItems.add(item);
        computedTotal += price * quantity;
      }
    }

    setState(() {
      restaurantId = data['restaurantId'];
      cartItems = parsedItems;
      totalPrice = computedTotal;
    });
  }

  Future<void> updateQuantity(int index, {required bool decrease}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final item = cartItems[index];
    int quantity = item['quantity'] ?? 1;

    quantity = decrease ? quantity - 1 : quantity + 1;

    if (quantity <= 0) {
      await removeItem(index);
      return;
    }

    cartItems[index]['quantity'] = quantity;

    totalPrice = cartItems.fold<int>(
      0,
      (sum, item) =>
          sum +
          (((item['price'] is int ? item['price'] : 0) as int) *
              ((item['quantity'] is int ? item['quantity'] : 1) as int)),
    );

    final cartRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(user.uid);

    await cartRef.set({'restaurantId': restaurantId, 'items': cartItems});

    setState(() {});
  }

  Future<void> removeItem(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    cartItems.removeAt(index);

    totalPrice = cartItems.fold<int>(
      0,
      (sum, item) =>
          sum +
          (((item['price'] is int ? item['price'] : 0) as int) *
              ((item['quantity'] is int ? item['quantity'] : 1) as int)),
    );

    final cartRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(user.uid);

    if (cartItems.isEmpty) {
      await cartRef.delete();
      restaurantId = null;
    } else {
      await cartRef.set({'restaurantId': restaurantId, 'items': cartItems});
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Review Order",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange,
      ),
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
                      children: [
                        Text(
                          "You are ordering for ${FirebaseAuth.instance.currentUser?.displayName ?? 'someone special'} 🎁",
                        ),
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
                        final name = item['name'] ?? 'Unnamed';
                        final price = item['price'] ?? 0;
                        final quantity = item['quantity'] ?? 1;
                        final imageUrl = item['imageUrl'] ?? '';

                        return ListTile(
                          leading: Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(name),
                          subtitle: Text("₹$price"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed:
                                    () => updateQuantity(index, decrease: true),
                              ),
                              Text('$quantity'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed:
                                    () =>
                                        updateQuantity(index, decrease: false),
                              ),
                            ],
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
