// lib/main.dart

import 'package:flutter/material.dart';
// Import the new contact.dart file
import 'contact.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // Set HomeScreen as the initial page
    );
  }
}

// The home screen with the navigation button
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data to pass to the Contact Page
    final sampleContact = ContactDetails(
      name: "Abhishek Ranjan",
      phone: "+91 9876543210",
      email: "abhishek@example.com",
      city: "Chennai, TN",
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: ElevatedButton( // Use an ElevatedButton for the button
          onPressed: () {
            // Navigate to the ContactPage when the button is pressed
            Navigator.push(
              context,
              MaterialPageRoute(
                // The builder function creates the destination widget
                builder: (context) => ContactPage(contact: sampleContact),
              ),
            );
          },
          child: const Text("View Contact Card"),
        ),
      ),
    );
  }
}
