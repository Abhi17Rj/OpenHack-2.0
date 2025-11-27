// lib/home.dart (Corrected)

import 'package:flutter/material.dart';
import 'package:smart_card/scan.dart';
import 'contact.dart'; // Import the contact card widget and model
import 'list_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Sample Data (Matching the image content)
  // Now uses the const keyword for the ContactDetails instance
  final sampleContact = const ContactDetails(
    name: "Abhishek Ranjan",
    phone: "+91 9876543210",
    email: "abhishek@example.com",
    city: "Chennai, TN",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Card Wise", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Removed the problematic trailing comma here
          children: [
            const Text(
              "Recently Added",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ListCard()));
              }, // Disable button if no image is picked
              child: Text("Upload Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0), // Adjust the radius for roundness
                )
              ),
            ),
            ContactCard(contact: sampleContact),
            
            const SizedBox(height: 32),
            const Text(
              "Documents",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _DocumentTile(
                name: "Document 1.docx", date: "29/10/25", type: "DOCX"),
            _DocumentTile(
                name: "Document 1_imp.pdf", date: "22/10/25", type: "PDF"),
            _DocumentTile(
                name: "Demo_Document 1.docx", date: "22/10/25", type: "PDF"),
            _DocumentTile(
                name: "Presentation1.docx", date: "20/10/25", type: "PPT"),
          ],
        ),
      ),
      
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScanPage()),
            );
          },
          child: const Text("Scan Card", style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final String name;
  final String date;
  final String type;

  const _DocumentTile({required this.name, required this.date, required this.type});

  IconData _getIcon() {
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'DOCX':
      case 'PPT':
        return Icons.insert_drive_file;
      default:
        return Icons.file_copy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_getIcon(), color: Colors.grey, size: 40),
      title: Text(name),
      subtitle: Text(date),
      trailing: Text(type),
      onTap: () { /* Handle document tap */ },
    );
  }
}
