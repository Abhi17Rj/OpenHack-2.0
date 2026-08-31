// lib/home.dart (Corrected)

import 'package:flutter/material.dart';
import 'package:smart_card/scan.dart'; // Assuming this exists
import 'contact.dart'; // Import the contact card widget and model
import 'list_card.dart';
import 'config.dart'; // Assuming this refers to your utility/api constants // Using the utility file import from previous discussion
import 'package:http/http.dart' as http;
import 'dart:convert';

// Changed HomeScreen from StatelessWidget to StatefulWidget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variables moved inside the State class
  ContactDetails? sampleContact;
  bool _isLoading = true;
  String _error = "";

  @override
  void initState() {
    super.initState();
    _fetchRecentContact(); // Fetch data when the page loads
  }

  // lib/home.dart

// ... (inside the _HomeScreenState class) ...

  Future<void> _fetchRecentContact() async {
    setState(() {
      _isLoading = true;
      _error = "";
    });

    final uri = Uri.parse(ApiConstants.recentEndpoint);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // --- FIX IS HERE ---
        // Decode the response as a LIST
        final List<dynamic> jsonList = json.decode(response.body);
        
        if (jsonList.isNotEmpty) {
          // If the list has items, take the first one and convert it to ContactDetails
          final Map<String, dynamic> firstRecord = jsonList[0];
          setState(() {
            sampleContact = ContactDetails.fromJson(firstRecord);
            _isLoading = false;
          });
        } else {
          // Handle the case where the API returned an empty list
          setState(() {
            _error = "API returned no recent contacts.";
            _isLoading = false;
          });
        }
        // --- END FIX ---

      } else {
        // ... (error handling for non-200 status codes) ...
      }
    } catch (e) {
      // ... (network error handling) ...
    }
  }

// ... (rest of the code) ...




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
          children: [
            const Text(
              "Recently Added",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Added conditional logic to display loader, error, or card
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                  ? Center(child: Text(_error))
                  : sampleContact != null
                    ? ContactCard(contact: sampleContact!) // '!' used as we know it's not null here
                    : const Center(child: Text("No recent contacts found.")),
            ),

            SizedBox(
              width: double.infinity, // This forces the button to expand horizontally
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ListCard()));
                }, 
                child: Text("View All"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0), 
                  ),
                ),
              ),
            ),
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
          child: const Text("Scan Card/DOC", style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}

// ... (_DocumentTile class remains unchanged) ...

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
