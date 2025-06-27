import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantPage extends StatelessWidget {
  final String restaurantId;
  const RestaurantPage({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Menu')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('restaurants')
                .doc(restaurantId)
                .collection('dishes')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final dishes = snapshot.data!.docs;

          if (dishes.isEmpty) {
            return const Center(child: Text('No dishes available.'));
          }

          return ListView.builder(
            itemCount: dishes.length,
            itemBuilder: (context, index) {
              final data = dishes[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Image.network(
                    data['imageUrl'] ?? '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                  title: Text(data['name'] ?? 'Unnamed Dish'),
                  subtitle: Text("₹${data['price'] ?? 'N/A'}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
