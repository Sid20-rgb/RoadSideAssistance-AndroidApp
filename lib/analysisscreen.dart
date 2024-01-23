import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class CarModel {
  final String company;
  final String model;
  final String bodyType;
  final String engineType;

  CarModel(this.company, this.model, this.bodyType, this.engineType);
}

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage>
    with SingleTickerProviderStateMixin {
  late Interpreter _interpreter;
  final ImagePicker _imagePicker = ImagePicker();
  File? _image;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showScanner = false;
  img.Image? _pickedImage;

  List<CarModel> carModels = [];
  List<String> companies = [];
  List<String> models = [];
  List<String> bodyTypes = [];
  List<String> engineTypes = [];

  String selectedCompany = '';
  String selectedModel = '';
  String selectedBodyType = '';
  String selectedEngineType = '';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Start a timer to show the scanner for 10 seconds
    Timer(const Duration(seconds: 20), () {
      setState(() {
        _showScanner = false;
        _controller.stop(); // Stop the animation controller
      });
    });
    // Load the TensorFlow Lite model
    _loadModel();
    loadCarModels();
  }

  void _loadModel() async {
    // Load the model from the assets or external storage
    final interpreterOptions = InterpreterOptions();
    _interpreter = await Interpreter.fromAsset('assets/my_model.tflite',
        options: interpreterOptions);

    // Debugging: Print the input tensor shape
    print('Input Tensor Shape: ${_interpreter.getInputTensor(0).shape}');
  }

  Future<void> loadCarModels() async {
    try {
      final String rawCarData =
          await rootBundle.loadString('assets/Car_Models.csv');
      final List<List<dynamic>> carList =
          const CsvToListConverter().convert(rawCarData);

      carModels = carList
          .skip(1) // Skip header row
          .map((List<dynamic> row) => CarModel(
                row[0].toString(), // Convert to String
                row[1].toString(), // Convert to String
                row[10].toString(),
                row[11].toString(), // Convert to String
              ))
          .toList();

      print('Loaded car models:');
      for (var model in carModels) {
        print(
            'Company: ${model.company}, Model: ${model.model}, Body Type: ${model.bodyType}, Engine Type: ${model.engineType}');
      }

      companies = [];
      models = [];
      bodyTypes = [];
      engineTypes = [];

      for (var carModel in carModels) {
        if (carModel.company.isNotEmpty) {
          if (!companies.contains(carModel.company)) {
            companies.add(carModel.company);
          }
        }
        if (carModel.model.isNotEmpty) {
          if (!models.contains(carModel.model)) {
            models.add(carModel.model);
          }
        }
        if (carModel.bodyType.isNotEmpty) {
          if (!bodyTypes.contains(carModel.bodyType)) {
            bodyTypes.add(carModel.bodyType);
          }
        }
        if (carModel.engineType.isNotEmpty) {
          if (!engineTypes.contains(carModel.engineType)) {
            engineTypes.add(carModel.engineType);
          }
        }
      }

      setState(() {
        selectedCompany = companies.isNotEmpty ? companies[0] : '';
        selectedModel = models.isNotEmpty ? models[0] : '';
        selectedBodyType = bodyTypes.isNotEmpty ? bodyTypes[0] : '';
        selectedEngineType = bodyTypes.isNotEmpty ? engineTypes[0] : '';
      });
    } catch (e) {
      print('Error loading CSV: $e');
    }
  }

  // Future<void> _getImage(ImageSource source) async {
  //   final picker = ImagePicker();
  //   final pickedImage = await picker.pickImage(source: source);

  //   setState(() {
  //     if (pickedImage != null) {
  //       _image = File(pickedImage.path);
  //       _showScanner = true; // Show the scanner when an image is uploaded
  //     }
  //   });
  // }

  Future<void> _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _showScanner = true; // Show the scanner when an image is uploaded
        _pickedImage =
            img.decodeImage(Uint8List.fromList(_image!.readAsBytesSync()));
      });
      _classifyImage(pickedFile);
    }
  }

  Future<String> runImageClassification() async {
    if (_image == null) {
      return 'No image selected';
    }

    // Preprocess the image
    const inputSize = 200; // Adjust this based on your model input size
    final rawImage = await _image!.readAsBytes();
    final inputImage = img.decodeImage(Uint8List.fromList(rawImage))!;

    // Resize the image to the desired input size
    final resizedImage =
        img.copyResize(inputImage, width: inputSize, height: inputSize);
    final normalizedImage = resizedImage.getBytes();

    // Ensure the input tensor shape matches the model expectations
    const batchSize = 1;
    const inputChannels = 3; // Assuming RGB images, adjust if necessary
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
      return 'Error running inference';
    }

    // Display the result
    final result = output.indexOf(output.reduce((a, b) => a > b ? a : b));
    if (result == 0) {
      return 'Road is full of holes';
    } else if (result == 1) {
      return 'Road is Muddy';
    } else if (result == 2) {
      return 'Road is Smooth';
    } else {
      return 'Road is covered with Snow';
    }
  }

  void _clearImage() {
    setState(() {
      _pickedImage = null;
      _showScanner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1F24),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                    ),
                    color:
                        Colors.green, // Set the background color of the app bar
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        onPressed: () {
                          // Handle back button press here
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 40.0),
                      const Text(
                        'Road Analysis',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontStyle: FontStyle.normal,
                            fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () => _pickImage(),
                  child: Container(
                    height: 350.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(
                        color: Colors.green, // Set the border color to green
                        width: 2.0,
                      ),
                    ),
                    child: Stack(
                      children: [
                        _pickedImage != null
                            ? ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  const Color(0xFF1C1F24).withOpacity(0.7),
                                  BlendMode.dstATop,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30.0),
                                  child: Image.memory(
                                    Uint8List.fromList(
                                        img.encodeJpg(_pickedImage!)),
                                    height: double.infinity,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.only(left: 70),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.photo,
                                      color: Colors.white,
                                      size: 50.0,
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Upload Road Image to Scan',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins'),
                                    ),
                                  ],
                                ),
                              ),
                        if (_showScanner)
                          AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return Positioned(
                                top: -3,
                                left: -3,
                                child: Container(
                                  height: 350.0 * _animation.value,
                                  width: 450.0,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        if (_pickedImage != null)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: _clearImage,
                              child: const CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.close,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Company',
                    labelStyle: const TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontFamily: 'Poppins'),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                  items: companies.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: selectedCompany == value
                              ? Colors.grey
                              : Colors.black,
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: selectedCompany == value
                              ? FontWeight.normal
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCompany = value!;
                      // Update the list of models based on the selected company
                      updateModelsList();
                    });
                  },
                  value: selectedCompany,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: UniqueKey(), // Use a UniqueKey to force a rebuild
                  decoration: InputDecoration(
                    labelText: 'Select Model',
                    labelStyle: const TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontFamily: 'Poppins'),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                  items: models.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: selectedModel == value
                              ? Colors.grey
                              : Colors.black,
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: selectedModel == value
                              ? FontWeight.normal
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedModel = value!;
                    });
                  },
                  value: selectedModel,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Body Type',
                    labelStyle: const TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontFamily: 'Poppins'),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    fillColor: Colors
                        .transparent, // Set the background color if needed
                    filled: true,
                  ),
                  items: bodyTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: selectedBodyType == value
                              ? Colors.grey
                              : Colors.black,
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: selectedBodyType == value
                              ? FontWeight.normal
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBodyType = value!;
                    });
                  },
                  value: selectedBodyType,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Engine Type (Optional)',
                    labelStyle: const TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontFamily: 'Poppins'),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    fillColor: Colors
                        .transparent, // Set the background color if needed
                    filled: true,
                  ),
                  items: engineTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: selectedEngineType == value
                              ? Colors.grey
                              : Colors.black,
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: selectedEngineType == value
                              ? FontWeight.normal
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedEngineType = value!;
                    });
                  },
                  value: selectedEngineType,
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      // Show the result dialog when the button is pressed
                      String resultText = await runImageClassification();
                      _showResultDialog(resultText);
                    },
                    child: const Text(
                      'Generate Result',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _interpreter.close();
    super.dispose();
  }

  Future<void> _classifyImage(XFile image) async {
    // Preprocess the image
    const inputSize = 200; // Adjust this based on your model input size
    final rawImage = await image.readAsBytes();
    final inputImage = img.decodeImage(Uint8List.fromList(rawImage))!;

    // Resize the image to the desired input size
    final resizedImage =
        img.copyResize(inputImage, width: inputSize, height: inputSize);
    final normalizedImage = resizedImage.getBytes();

    // Ensure the input tensor shape matches the model expectations
    const batchSize = 1;
    const inputChannels = 3; // Assuming RGB images, adjust if necessary
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
  }

  void updateModelsList() {
    // Filter models based on the selected company
    List<String> filteredModels = carModels
        .where((carModel) => carModel.company == selectedCompany)
        .map((carModel) => carModel.model)
        .toList();

    // Clear the existing models list before adding the new ones
    setState(() {
      models.clear();
      models.addAll(filteredModels);
      selectedModel = models.isNotEmpty ? models[0] : '';
    });
  }

  void _showResultDialog(String resultText) {
    // Show the processing animation for 5 seconds
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: Color(0xFF1C1F24),
          title: Center(
            child: Text(
              'Processing...',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  color: Colors.green, // Adjust color as needed
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Please wait...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        );
      },
    );

    // Simulate processing for 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      // After 5 seconds, close the processing dialog and show the result dialog
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1C1F24),
            title: const Center(
              child: Text(
                'Analysis Result',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Selected Company: $selectedCompany',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 193, 193, 193),
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Selected Model: $selectedModel',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 193, 193, 193),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Result: $resultText',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                  ),
                ),
                const Text(
                  'Negative',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                  ),
                ),
                const Text(
                  'The selected model is not compatible for this road.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 193, 193, 193),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.green,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
