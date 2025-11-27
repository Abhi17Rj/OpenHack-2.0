import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

// You can now use functions like getTemporaryDirectory()
// and FlutterImageCompress.compressAndGetFile()



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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0), // Adjust the radius for roundness
                )
              ),
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

    // We will track the final file path we use for upload
    String filePathToUpload = _imageFile!.path; 
    File? tempCompressedFile; // Keep track of the temp file for later deletion

    try {
      // --- On-Device Image Processing (Resize/Compress to JPG) ---
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = '${tempDir.path}/compressed_image.jpg';

      XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        _imageFile!.path,
        targetPath,
        minHeight: 500, // Longest side targeted
        minWidth: 500,  // Longest side targeted
        quality: 80,    // JPG Quality
        format: CompressFormat.jpeg, // Ensure output is JPG
      );

      if (compressedFile != null) {
        tempCompressedFile = File(compressedFile.path);
        filePathToUpload = tempCompressedFile.path; // Update the path we use for upload
      } else {
        debugPrint("Compression failed, uploading original file.");
      }
      // --- End Processing ---

      final uri = Uri.parse("http://localhost:3000/insert"); // Use your URL
      var request = http.MultipartRequest('POST', uri);

      // Use the potentially compressed image file path
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // Field name for your Node server
          filePathToUpload,
        ),
      );

      final response = await request.send();

      // Check the response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        debugPrint('Upload successful: $responseData');
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Image uploaded successfully!')),
        );
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
    } finally {
      // Ensure the temporary compressed file is deleted after the request finishes
      if (tempCompressedFile != null && await tempCompressedFile.exists()) {
        await tempCompressedFile.delete();
        debugPrint("Temporary compressed file deleted.");
      }
    }
  }


}