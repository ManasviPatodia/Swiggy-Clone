import 'package:flutter/material.dart';

class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          ListTile(
            leading: Icon(Icons.question_answer),
            title: Text("FAQs"),
            subtitle: Text("Frequently asked questions"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.support_agent),
            title: Text("Chat with Support"),
            subtitle: Text("Reach us instantly for queries"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.email),
            title: Text("Email Us"),
            subtitle: Text("support@snackgo.com"),
          ),
        ],
      ),
    );
  }
}
