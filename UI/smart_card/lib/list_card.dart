// lib/list_card.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'contact.dart'; 
import 'config.dart';

class ListCard extends StatefulWidget {
  const ListCard({super.key});

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  List<ContactDetails> _contactRecords = [];
  bool _isLoading = true;
  String _error = "";
  // State variable to control visibility of the search bar
  bool _isSearching = false; 
  // Controller for the search input field
  final TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecords() async {
    // ... (Your existing _fetchRecords logic goes here, omitted for brevity) ...
    // Placeholder code:
    setState(() {
      _isLoading = true;
      _error = "";
    });
    final uri = Uri.parse(ApiConstants.allCardsEndpoint);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        _contactRecords = jsonList.map((jsonItem) => ContactDetails.fromJson(jsonItem)).toList();
        _isLoading = false;
      } else {
        _error = "Failed to load cards.";
        _isLoading = false;
      }
    } catch (e) {
      _error = "Network Error.";
      _isLoading = false;
    }
    setState(() {}); // Update UI
  }

  // Blank method to be filled later
  void _performSearch(String query) {
    print("Search functionality needs to be implemented for query: $query");
    // Implementation of search goes here later
    // Example: filter _contactRecords based on query
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(_isSearching ? Icons.arrow_back : Icons.list, color: Colors.white),
          onPressed: () {
            if (_isSearching) {
              // Close search mode
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
              // Optional: Refetch original data if needed
              // _fetchRecords(); 
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSearching
              ? TextField(
                  key: const ValueKey<bool>(true), // Key helps AnimatedSwitcher work
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search cards...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  onSubmitted: _performSearch, // Activates on keyboard 'Done' or 'Search' press
                )
              : const Text(
                  "Scan Card",
                  key: ValueKey<bool>(false), // Key helps AnimatedSwitcher work
                  style: TextStyle(color: Colors.white),
                ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.search : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                // Toggle search mode
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
              if (_isSearching && _searchController.text.isNotEmpty) {
                // Manually trigger search if icon pressed while text is entered
                _performSearch(_searchController.text);
              }
            },
          ),
          if (!_isSearching) // Only show refresh button when not searching
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: _fetchRecords,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _contactRecords.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ContactCard(contact: _contactRecords[index]),
                    );
                  },
                ),
    );
  }
}
