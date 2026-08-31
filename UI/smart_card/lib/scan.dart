import 'package:flutter/material.dart';
import 'package:smart_card/camera.dart'; // Ensure this path is correct
import 'package:file_picker/file_picker.dart';
import 'pdf_viewer.dart'; // Ensure this path is correct

// Changed from StatelessWidget to StatefulWidget
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // The logic is moved inside the State class
  Future<void> _pickPdfFromFile() async {
    // 1. Add the missing file picker logic
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final fileName = result.files.single.name; // Get the file name

      // 2. 'context' is now available inside the State class
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerPage( // Use the new page
            path: filePath, 
            fileName: fileName,
          )
        ),
      );
    } else {
      // Handle cancellation or error
      print('File picking cancelled or error occurred.');
    }
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ScanOptionButton(
              iconWidget: _QrScannerIcon(),
              label: "Scan QR",
              onTap: () {
                
              },
            ),
            const SizedBox(height: 15.0),
            _ScanOptionButton(
              iconWidget: const Icon(Icons.camera, color: Colors.black, size: 120,),
              label: "Open Camera",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ImagePick()),
                );
              },
            ),
            const SizedBox(height: 15.0),
            _ScanOptionButton(
              iconWidget: const Icon(Icons.file_open, color: Colors.black, size: 120,),
              label: "Select from files",
              onTap: _pickPdfFromFile, // Assigned the function here
            ),
          ],
        ),
      ),
    );
  }
}

// A reusable widget for the two card buttons (StatelessWidget remains correct)
class _ScanOptionButton extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final VoidCallback onTap;

  const _ScanOptionButton({
    required this.iconWidget,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0F0F0), // Light grey background
      borderRadius: BorderRadius.circular(10.0),
      elevation: 2.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          width: double.infinity,
          height: 200,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              iconWidget,
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

// ... (_QrScannerIcon StatelessWidget remains unchanged below) ...

class _QrScannerIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double size = 30.0;
    const double lineLength = 30.0;
    const Color color = Colors.black;

    return SizedBox(
      width: 120,
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top Left Corner
              Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: color, width: 3),
                    left: BorderSide(color: color, width: 3),
                  ),
                ),
              ),
              const SizedBox(width: lineLength),
              // Top Right Corner
              Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: color, width: 3),
                    right: BorderSide(color: color, width: 3),
                  ),
                ),
              ),
            ],
          ),
          // Red scan line
          Container(
            width: 110,
            height: 3,
            color: Colors.red,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bottom Left Corner
              Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: color, width: 3),
                    left: BorderSide(color: color, width: 3),
                  ),
                ),
              ),
              const SizedBox(width: lineLength),
              // Bottom Right Corner
              Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: color, width: 3),
                    right: BorderSide(color: color, width: 3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
