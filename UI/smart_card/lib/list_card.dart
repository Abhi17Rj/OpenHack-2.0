// lib/list_card.dart (Updated version of the code you provided)

import 'package:flutter/material.dart';
// import 'camera.dart'; // Unused in this context, but kept
import 'contact.dart'; // Import your ContactCard and ContactDetails classes

class ListCard extends StatefulWidget {
  const ListCard({super.key});

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  // List variable to hold the fetched records
  List<ContactDetails> _contactRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch the data as soon as the widget initializes
    _fetchRecords();
  }

  // Method to manually "fetch" 5 records
  Future<void> _fetchRecords() async {
    // Simulate a network delay
    await Future.delayed(Duration(seconds: 1));

    // Manually create 5 sample records
    final List<ContactDetails> fetchedData = [
      ContactDetails(
          name: "John Doe",
          phone: "1234567890",
          email: "john.doe@example.com",
          city: "New York"),
      ContactDetails(
          name: "Jane Smith",
          phone: "0987654321",
          email: "jane.smith@example.com",
          city: "Los Angeles"),
      ContactDetails(
          name: "Alice Johnson",
          phone: "5551234567",
          email: "alice@example.com",
          city: "Chicago"),
      ContactDetails(
          name: "Bob Williams",
          phone: "5559876543",
          email: "bob@example.com",
          city: "Houston"),
      ContactDetails(
          name: "Charlie Brown",
          phone: "1112223333",
          email: "charlie@example.com",
          city: "Miami"),
    ];

    // Update the state with the new data and stop loading indicator
    setState(() {
      _contactRecords = fetchedData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan Card",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show a spinner while loading
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _contactRecords.length,
              itemBuilder: (context, index) {
                // Pass each record to your custom ContactCard widget
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ContactCard(contact: _contactRecords[index]),
                );
              },
            ),
    );
  }
}
