import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_try/mapscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Hide the system navigation bar (status bar)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// class MapScreen extends StatefulWidget {
//   const MapScreen({Key? key}) : super(key: key);

//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   late GoogleMapController mapController;
//   late location.Location userLocation; // Declare it here
//   final places.GoogleMapsPlaces _placesApi =
//       places.GoogleMapsPlaces(apiKey: 'YOUR_API_KEY'); // Rename it here

//   Set<Marker> markers = <Marker>{}; // Maintain a set of markers
//   final panelController = PanelController(); // Controller for the sliding panel

//   @override
//   void initState() {
//     super.initState();
//     userLocation = location.Location(); // Initialize it here
//     _getLocation();
//   }

//   void _getLocation() async {
//     try {
//       var currentLocation = await userLocation.getLocation();
//       mapController.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target:
//                 LatLng(currentLocation.latitude!, currentLocation.longitude!),
//             zoom: 15.0,
//           ),
//         ),
//       );
//       // _getNearbyPlaces(currentLocation);
//     } catch (e) {
//       // Handle errors that may occur during location fetching
//       print('Error fetching location: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SlidingUpPanel(
//         minHeight: 100,
//         maxHeight: 400,
//         parallaxEnabled: true,
//         parallaxOffset: .5,
//         panel: _buildPanel(),
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(355)),
//         controller: panelController,
//         body: Stack(
//           children: [
//             GoogleMap(
//               onMapCreated: (controller) {
//                 setState(() {
//                   mapController = controller;
//                   _setMapStyle();
//                 });
//               },
//               initialCameraPosition: const CameraPosition(
//                 target: LatLng(0.0, 0.0),
//                 zoom: 15.0,
//               ),
//               myLocationEnabled: true,
//               myLocationButtonEnabled: true,
//               mapType: MapType.normal, // Set the map type here
//               markers: markers,
//             ),
//             Positioned(
//               bottom: 120.0,
//               right: 16.0,
//               child: Column(
//                 children: [
//                   FloatingActionButton(
//                     onPressed: () {
//                       mapController.animateCamera(
//                         CameraUpdate.zoomIn(),
//                       );
//                     },
//                     child: const Icon(Icons.add),
//                   ),
//                   const SizedBox(height: 8.0),
//                   FloatingActionButton(
//                     onPressed: () {
//                       mapController.animateCamera(
//                         CameraUpdate.zoomOut(),
//                       );
//                     },
//                     child: const Icon(Icons.remove),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPanel() {
//     return ClipRRect(
//       borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
//       child: Container(
//         padding: const EdgeInsets.all(5.0),
//         color: const Color(0xFF1C1F24),
//         child: const Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.horizontal_rule,
//               color: Colors.white,
//               size: 40.0,
//             ),
//             SizedBox(height: 1.0),
//             Text(
//               'Confirm Location',
//               style: TextStyle(
//                 fontSize: 24.0, // Adjust the font size as needed
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             // Add your additional widgets as needed
//           ],
//         ),
//       ),
//     );
//   }

//   void _setMapStyle() async {
//     // Load the JSON string of your custom map style
//     String mapStyleJson = await rootBundle.loadString('assets/custommap.json');

//     // Set the custom map style
//     mapController.setMapStyle(mapStyleJson);
//   }
// }
