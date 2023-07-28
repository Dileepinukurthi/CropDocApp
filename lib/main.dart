import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    home: CameraAndFilePickerButton(),
  ));
}

class CameraAndFilePickerButton extends StatefulWidget {
  @override
  _CameraAndFilePickerButtonState createState() => _CameraAndFilePickerButtonState();
}

class _CameraAndFilePickerButtonState extends State<CameraAndFilePickerButton> {
  File? _capturedImage;
  String _fileName = "No file selected";
  final ImagePicker _imagePicker = ImagePicker();

  void _removeFile() {
    setState(() {
      _capturedImage = null;
      _fileName = "No file selected";
    });
  }

  Future<void> _captureImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _fileName = "Captured from camera";
        _capturedImage = File(image.path); // Store the captured image file
      });
    }
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CropDoc'),
        backgroundColor: Colors.green, // Change the AppBar's background color
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _captureImage,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.purple,
                    onPrimary: Colors.white,
                  ),
                  child: Text('Capture Image'),
                ),
                Text('   Or'),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _selectFile,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.purple,
                    onPrimary: Colors.white,
                  ),
                  child: Text('Select Image'),
                ),
              ],
            ),

            SizedBox(height: 10),
            _capturedImage != null
                ? Stack(
              alignment: Alignment.topRight,
              children: [
                Image.file(_capturedImage!), // Display the captured image
                Positioned(
                  top: 8,
                  right: 8,
                  child: Tooltip(
                    message: 'Remove',
                    child: ElevatedButton(
                      onPressed: _removeFile, // Trigger the remove action
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red, // Use red color for remove button
                        onPrimary: Colors.white,
                        minimumSize: Size(32, 32),
                        padding: EdgeInsets.zero,
                        shape: CircleBorder(),
                      ),
                      child: Icon(Icons.close),
                    ),
                  ),
                ),
              ],
            )
                : Text('No image/file selected'), // Show a message if no image/file is selected
            SizedBox(height: 10),
            Text(
              'Selected file: $_fileName',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            ElevatedButton(
              onPressed: _captureImage,
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
              ),
              child: Text('Detect'),
            ),
          ],
        ),
      ),
    );
  }
}
