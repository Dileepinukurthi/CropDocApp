import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: CameraAndFilePickerButton(),
  ));
}

class CameraAndFilePickerButton extends StatefulWidget {
  @override
  _CameraAndFilePickerButtonState createState() =>
      _CameraAndFilePickerButtonState();
}

class _CameraAndFilePickerButtonState
    extends State<CameraAndFilePickerButton> {
  File? _capturedImage;
  String _fileName = "No file selected";
  String _responseText = "";
  String _pesticideText = "";
  String _error = "";
  bool _isLoading = false;

  final ImagePicker _imagePicker = ImagePicker();

  void _removeFile() {
    setState(() {
      _capturedImage = null;
      _fileName = "No file selected";
      _responseText = "";
      _pesticideText = "";
      _error = "";
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
        _capturedImage = File(result.files.single.path!);
      });
    }
  }

  void _showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Prescription😁',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                _responseText,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Text(
                "Severity: 48 %",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Text(
                _pesticideText,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Close the modal when the button in the modal is pressed
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  final Map<String, String> diseasesToFertilizers = {
    // Apple diseases and corresponding fertilizers
    "Apple___Apple_scab": "ScabShield",
    "Apple___Black_rot": "RotGuard",
    "Apple___Cedar_apple_rust": "RustShield",
    "Apple___healthy": "AppleGrow+",

    // Blueberry diseases and corresponding fertilizers
    "Blueberry___healthy": "BlueberryBoost",

    // Cherry diseases and corresponding fertilizers
    "Cherry_(including_sour)___Powdery_mildew": "FungusFighter",
    "Cherry_(including_sour)___healthy": "CherryChampion+",

    // Corn diseases and corresponding fertilizers
    "Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot": "CornGuard+",
    "Corn_(maize)__Common_rust": "RustShield",
    "Corn_(maize)___Northern_Leaf_Blight": "NPK Blend+",
    "Corn_(maize)___healthy": "BlightBlocker+",

    // Grape diseases and corresponding fertilizers
    "Grape___Black_rot": "vineVigour+",
    "Grape__Esca(Black_Measles)": "VineShield",

    // Tomato diseases and corresponding fertilizers
    "Tomato___Bacterial_spot": "TomatoGuard+",
    "Tomato___Early_blight": "TomatoShield+",
    "Tomato___Late_blight": "TomatoDefender+",
    // Add more disease-fertilizer mappings as needed
  };

  Future<void> _callApiWithImage(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    final apiUrl = Uri.parse(
        'https://thunderpytho.azurewebsites.net/api/pythodoc?code=TC9SKZeFOn_SZxEKaGhkpJk_-gYjg21IKtYJRdXbtvTdAzFuJyu8-w==');

    try {
      final request = http.MultipartRequest('POST', apiUrl);
      print(imageFile.path);
      request.files
          .add(await http.MultipartFile.fromPath('crop_image', imageFile.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        print('API Response: $responseString');

        // Parse the response to get the disease and pesticide details
        final String pesticide =
            diseasesToFertilizers[responseString] ?? 'Unknown Pesticide';

        setState(() {
          _responseText = 'Infection : $responseString';
          _pesticideText = 'Pesticide: $pesticide';
          _isLoading = false;
        });

        // Show the response in a modal
        _showModal(context);
      } else {
        print('API Request failed with status code: ${response.statusCode}');
        setState(() {
          _error = 'API Request failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error making API request: $e');
      setState(() {
        _error = 'Error making API request';
        _isLoading = false;
      });
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('CropDoc - About'),
          content: Text('This app helps identify crop diseases and recommends appropriate pesticides.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CropDoc'),
        backgroundColor: Colors.green, // Change the AppBar's background color
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 200, // Set the desired width here
              height: 200, // Set the desired height here
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  if (_capturedImage != null)
                    Positioned.fill(
                      child: Image.file(_capturedImage!, fit: BoxFit.cover),
                    ),
                  if (_capturedImage != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Tooltip(
                        message: 'Remove',
                        child: ElevatedButton(
                          onPressed: _removeFile,
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
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
              ),

            ),

            SizedBox(height: 10),
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
            Text(
              'Selected file: $_fileName',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            ElevatedButton(
              onPressed: _capturedImage != null && !_isLoading
                  ? () => _callApiWithImage(_capturedImage!)
                  : null,
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
              ),
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Detect'),
            ),
            Text(
              '$_error',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _removeFile,
        label: Text('Reset'),
        icon: Icon(Icons.refresh),
        backgroundColor: Colors.red,
      ),
    );
  }
}
