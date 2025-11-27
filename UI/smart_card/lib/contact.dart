// lib/contact.dart (Final Corrected Version)

import 'package:flutter/material.dart';

// Data model class
class ContactDetails {
  final String name;
  final String phone;
  final String email;
  final String city;

  const ContactDetails({
    required this.name,
    required this.phone,
    required this.email,
    required this.city,
  });
}

// The ContactCard widget
class ContactCard extends StatelessWidget {
  final ContactDetails contact;

  const ContactCard({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card( 
      elevation: 0.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), 
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          // *** The children list must contain all the widgets: ***
          children: [ 
            Text( 
              contact.name,
              style: const TextStyle(
                  fontSize: 18.0, 
                  fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20.0),

            // *** We must call the helper methods here to display the info: ***
            _buildCompactRow(Icons.phone, contact.phone),
            const SizedBox(height: 8.0),

            _buildCompactRow(Icons.email, contact.email),
            const SizedBox(height: 8.0),

            _buildCompactRow(Icons.location_city, contact.city),
          ],
        ),
      ),
    );
  }

  // Helper method to build compact rows
  Widget _buildCompactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal, size: 18.0),
        const SizedBox(width: 12.0),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14.0),
          ),
        ),
      ],
    );
  }
}
