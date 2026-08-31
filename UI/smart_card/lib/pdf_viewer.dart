// lib/pdf_viewer_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // Import the PDF viewer widget
import 'dart:io'; // Required for the File type

class PdfViewerPage extends StatelessWidget {
  // This widget accepts the local file path of the PDF
  final String path;
  final String fileName;

  const PdfViewerPage({Key? key, required this.path, required this.fileName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName), // Display the file name in the app bar
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: PDFView(
        filePath: path, // The path to the local PDF file
        enableSwipe: true, // Allows horizontal page swiping
        swipeHorizontal: true, // Enables horizontal swipe
        autoSpacing: false, // Removes extra spacing between pages
        pageFling: false, // Disable automatic flinging/snapping of pages
        // The onError callback can show a simple error message if the PDF is corrupt
        onError: (error) {
          print(error.toString());
        },
        // No extra UI controls (like page number indicators or action buttons) are included by default.
      ),
    );
  }
}
