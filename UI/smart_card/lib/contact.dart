// lib/contact.dart (Modified for half height)

import 'package:flutter/material.dart';

// Data model class (remains the same)
class ContactDetails {
  final String name;
  final String phone;
  final String email;
  final String city;

  ContactDetails({
    required this.name,
    required this.phone,
    required this.email,
    required this.city,
  });
}

// The ContactPage screen widget
class ContactPage extends StatelessWidget {
  final ContactDetails contact;

  const ContactPage({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Details"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        // The modified Card widget
        child: Card(
          elevation: 5.0,
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // We use a Column with custom Rows instead of ListTiles to save space
            child: Column(
              mainAxisSize: MainAxisSize.min, // Makes the card height minimal
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Name (Now simple Text, not a ListTile) ---
                Text(
                  contact.name,
                  style: const TextStyle(
                      fontSize: 18.0, 
                      fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20.0), // Smaller divider height

                // --- Phone (Compact Row) ---
                _buildCompactRow(Icons.phone, contact.phone),
                const SizedBox(height: 8.0), // Small space between details

                // --- Email (Compact Row) ---
                _buildCompactRow(Icons.email, contact.email),
                const SizedBox(height: 8.0),

                // --- Address (City) (Compact Row) ---
                _buildCompactRow(Icons.location_city, contact.city),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build compact rows
  Widget _buildCompactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal, size: 18.0),
        const SizedBox(width: 12.0), // Space between icon and text
        Flexible( // Ensures text wraps if it's too long
          child: Text(
            text,
            style: const TextStyle(fontSize: 14.0), // Smaller font size
          ),
        ),
      ],
    );
  }
}
