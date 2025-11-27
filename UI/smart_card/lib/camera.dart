import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


class ImagePick extends StatefulWidget {
  const ImagePick({super.key});
  @override
  _ImagePickState createState() => _ImagePickState();
}

class _ImagePickState extends State<ImagePick> {
  //List? _outputs;
  XFile? _imageFile;
  //File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "",
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                        height: 300.0,
                        width: 300.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: _imageFile != null ?
                              Image.file(File(_imageFile!.path), fit: BoxFit.cover) : Image.asset('assets/image.png', fit: BoxFit.fill),
                        ),
                    ),
            const SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: _imageFile != null ? _uploadImageToServer : null, // Disable button if no image is picked
              child: Text("Upload Image"),
            ),
            const SizedBox(height: 15.0),
            GestureDetector(
              onTap: _pickImageFromCamera,
              child: Container(
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.indigo
                ),
                child: Center(
                        child: Padding(padding: EdgeInsetsGeometry.all(10), child: Text("Capture", style: TextStyle(color: Colors.white, fontSize: 22),)),
                        ),
                
              ),
            )
          ],
        ),
      ),
    );
  }



  Future<void> _pickImageFromCamera() async {
    try {
      // Use ImageSource.camera to launch the camera
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 400, // Optional: restricts the image size
        maxHeight: 400, // Optional: restricts the image size
        imageQuality: 80, // Optional: quality compression (0-100)
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          print("setState called. _imageFile is now not null.");
        });
      }
    } catch (e) {
      // Handle any errors that might occur
      debugPrint("Error picking image from camera: $e");
    }
  
  } 


  Future<void> _uploadImageToServer() async {
    if (_imageFile == null) return;

    final uri = Uri.parse("Url");
    // Use a MultipartRequest for file uploads
    var request = http.MultipartRequest('POST', uri);

    try {
      // Attach the file to the request with a field name (e.g., 'image')
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // <-- This field name must match what your Node.js/Backend expects
          _imageFile!.path,
        ),
      );

      // Send the request
      final response = await request.send();

      // Check the response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        debugPrint('Upload successful: $responseData');
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Image uploaded successfully!')),
        );
        // Clear the image after success if needed
        setState(() {
          _imageFile = null;
        });
      } else {
        final responseData = await response.stream.bytesToString();
        debugPrint('Upload failed with status: ${response.statusCode}. Response: $responseData');
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Image upload failed.')),
        );
      }
    } catch (e) {
      debugPrint('Error during network request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Network error: $e')),
      );
    }
  }



}