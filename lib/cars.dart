import 'dart:async';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class CarModel {
  final String company;
  final String model;
  final String bodyType;
  final String engineType;

  CarModel(this.company, this.model, this.bodyType, this.engineType);
}

class CarPage extends StatefulWidget {
  const CarPage({super.key});

  @override
  _CarPageState createState() => _CarPageState();
}

//Model Year Range

class _CarPageState extends State<CarPage> {
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
    loadCarModels();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Company',
                ),
                items: companies.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCompany = value!;
                  });
                },
                value: selectedCompany,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Model',
                ),
                items: models.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
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
                decoration: const InputDecoration(
                  labelText: 'Select Body Type',
                ),
                items: bodyTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
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
                decoration: const InputDecoration(
                  labelText: 'Select Engine Type',
                ),
                items: engineTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEngineType = value!;
                  });
                },
                value: selectedEngineType,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
