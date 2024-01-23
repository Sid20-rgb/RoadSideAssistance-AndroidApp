import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:test_try/mapscreen.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _imagePicker = ImagePicker();
  late Interpreter _interpreter;
  img.Image? _pickedImage; // New variable to store the picked image

  @override
  void initState() {
    super.initState();
    // Load the TensorFlow Lite model
    _loadModel();
  }

  void _loadModel() async {
    // Load the model from the assets or external storage
    final interpreterOptions = InterpreterOptions();
    _interpreter = await Interpreter.fromAsset('assets/my_model.tflite',
        options: interpreterOptions);

    // Debugging: Print the input tensor shape
    print('Input Tensor Shape: ${_interpreter.getInputTensor(0).shape}');
  }

  @override
  void dispose() {
    // Clean up resources
    _interpreter.close();
    super.dispose();
  }

  Future<void> _classifyImage(XFile image) async {
    // Preprocess the image
    const inputSize = 200;
    final rawImage = await image.readAsBytes();
    _pickedImage = img.decodeImage(Uint8List.fromList(rawImage));

    // Resize the image to the desired input size
    final resizedImage =
        img.copyResize(_pickedImage!, width: inputSize, height: inputSize);
    final normalizedImage = resizedImage.getBytes();

    // Ensure the input tensor shape matches the model expectations
    const batchSize = 1;
    const inputChannels = 3;
    final inputImageData =
        Float32List(batchSize * inputSize * inputSize * inputChannels);

    for (var i = 0; i < inputSize * inputSize; i++) {
      inputImageData[i * 3 + 0] = normalizedImage[i * 3] / 255.0;
      inputImageData[i * 3 + 1] = normalizedImage[i * 3 + 1] / 255.0;
      inputImageData[i * 3 + 2] = normalizedImage[i * 3 + 2] / 255.0;
    }

    // Debugging: Print the input tensor shape
    print('Input Tensor Shape: ${_interpreter.getInputTensor(0).shape}');

    // Run inference
    final output =
        Float32List(4); // Assuming 4 classes, change it based on your model

    try {
      _interpreter.run(
          inputImageData.buffer.asUint8List(), output.buffer.asUint8List());
    } catch (e) {
      print("Error running inference: $e");
    }

    // Display the result
    final result = output.indexOf(output.reduce((a, b) => a > b ? a : b));
    if (result == 0) {
      print('Road is full of holes');
    } else if (result == 1) {
      print('Road is Muddy');
    } else if (result == 2) {
      print('Road is Smooth');
    } else {
      print('Road is covered with Snow');
    }

    // Update the UI to show the picked image
    setState(() {});
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _classifyImage(pickedFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Classification'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick an Image'),
            ),
            _pickedImage != null
                ? Image.memory(Uint8List.fromList(img.encodeJpg(_pickedImage!)))
                : Container(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (e) => const MapScreen(),
                  ),
                );
              },
              child: const Text('Map'),
            ),
          ],
        ),
      ),
    );
  }
}
