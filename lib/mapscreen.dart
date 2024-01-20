import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show ByteData, Clipboard, ClipboardData, Uint8List, rootBundle;
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:test_try/drawer.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late location.Location userLocation;
  late String currentUserLocation;
  location.LocationData? currentLocation;
  Set<Polyline> polylines = {};
  Set<Marker> markers = <Marker>{};
  final panelController = PanelController();
  LatLng? customPinLocation;
  Marker? customPinMarker;
  bool locationFetched = false;
  Marker? carMarker;

  @override
  void initState() {
    super.initState();
    userLocation = location.Location();
    currentUserLocation = '';
    _loadCarImage();
    _getLocation();
    // _init();
  }

  // Future<void> _init() async {
  //   await _getLocation();
  //   setState(() {
  //     // Set state variables or perform any other necessary actions
  //   });
  // }

  // Method to load the car image from assets
  Future<void> _loadCarImage({double width = 50, double height = 50}) async {
    final ByteData data = await rootBundle.load(
      'assets/images/car.png',
    );
    final Uint8List bytes = data.buffer.asUint8List();

    // Create a BitmapDescriptor from the loaded image
    final BitmapDescriptor carIcon = BitmapDescriptor.fromBytes(bytes);

    // Check if the current location is available
    if (currentLocation != null) {
      // Use the user's current location as the initial position
      carMarker = Marker(
        markerId: const MarkerId('carMarker'),
        position: currentLocation!.toLatLng(),
        icon: carIcon,
        anchor: const Offset(0.5, 0.5), // Center the image on the marker
      );

      // Set the initial car marker on the map
      markers.add(carMarker!);
    }
  }

  Future<String?> _getLocation() async {
    try {
      if (!locationFetched) {
        currentLocation = await userLocation.getLocation();
        List<Placemark> placemarks = await placemarkFromCoordinates(
          currentLocation!.latitude!,
          currentLocation!.longitude!,
        );

        if (placemarks.isNotEmpty) {
          String currentAddress = placemarks.first.name ?? 'Unknown Address';

          setState(() {
            currentUserLocation = currentAddress;
            _updateCarMarker(); // Call the method to update the car marker position
            _loadCarImage(); // Add this line to load the car image at the correct location
            locationFetched =
                true; // Set the flag to true once location is fetched
          });

          locationFetched =
              true; // Set the flag to true once location is fetched
        }
      }

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            zoom: 15.0,
          ),
        ),
      );

      return null;
    } catch (e) {
      print('Error fetching location: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer:
          CustomDrawer(onItem1Tap: () {}, onItem2Tap: () {}, onItem3Tap: () {}),
      body: SlidingUpPanel(
        minHeight: 100,
        maxHeight: 400,
        parallaxEnabled: true,
        parallaxOffset: .5,
        panel: _buildPanel(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(355)),
        controller: panelController,
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                  _setMapStyle();
                });
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(0.0, 0.0),
                zoom: 15.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              markers: markers,
              polylines: polylines,
              // Handle long press to set the custom pin location
              onLongPress: (LatLng point) {
                _handleLongPress(point);
              },
            ),
            Positioned(
              bottom: 120.0,
              right: 16.0,
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      mapController.animateCamera(
                        CameraUpdate.zoomIn(),
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8.0),
                  FloatingActionButton(
                    onPressed: () {
                      mapController.animateCamera(
                        CameraUpdate.zoomOut(),
                      );
                    },
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          child: FloatingActionButton(
            onPressed: () {
              // Open the drawer when the button is pressed
              scaffoldKey.currentState?.openDrawer();
            },
            backgroundColor:
                Colors.transparent, // Set background color to transparent
            elevation: 0, // Remove shadow
            child: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 30,
            ), // Set the icon color to white
          ),
        ),
      ),
    );
  }

  // Widget _buildDrawer() {

  // }

  Widget _buildPanel() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      child: Container(
        color: const Color(0xFF1C1F24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.horizontal_rule,
              color: Colors.white,
              size: 40.0,
            ),
            const SizedBox(height: 5.0),
            const Text(
              'Current Location',
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildLocationTextField(),
                    const SizedBox(height: 20.0),
                    _buildGreenButton('Start Smart Routing', () {
                      if (currentLocation != null &&
                          customPinLocation != null) {
                        _startSmartRouting();
                      } else {
                        print(
                            'Error: Custom pin location or current location is null');
                      }
                    }),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSquareButton(
                          '  Find\nGarage',
                          Icons.garage,
                          () {},
                        ),
                        _buildSquareButton(
                          '      Find\nRestaurant',
                          Icons.restaurant,
                          () {},
                        ),
                        _buildSquareButton(
                          '   Find\nMedical',
                          Icons.local_hospital,
                          () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareButton(
    String text,
    IconData iconData,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        SizedBox(
          width: 100.0,
          height: 100.0,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconData,
                  size: 30.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationTextField() {
    return FutureBuilder<String?>(
      future: _getLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error fetching location: ${snapshot.error}');
        } else {
          String currentUserLocation = snapshot.data ?? 'Unknown Address';

          String destinationText = customPinMarker != null
              ? ' ${customPinMarker!.infoWindow.title}'
              : 'Enter destination...';

          return Column(
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    12.0,
                    0.0,
                    12.0,
                    8.0,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: currentUserLocation,
                            hintStyle: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    12.0,
                    0.0,
                    12.0,
                    8.0,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontFamily: 'Poppins'),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: destinationText,
                            hintStyle: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildGreenButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 8.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setMapStyle() async {
    String mapStyleJson = await rootBundle.loadString('assets/custommap.json');
    mapController.setMapStyle(mapStyleJson);
  }

  void _handleLongPress(LatLng point) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;

        String address =
            '${placemark.name ?? ''}, ${placemark.thoroughfare ?? ''}, ${placemark.subThoroughfare ?? ''}, ${placemark.locality ?? ''}, ${placemark.subLocality ?? ''}, ${placemark.administrativeArea ?? ''}, ${placemark.postalCode ?? ''}, ${placemark.country ?? ''}';

        // Show a bottom sheet with user's current location details
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latitude: ${point.latitude}',
                    style:
                        const TextStyle(fontSize: 16.0, fontFamily: 'Poppins'),
                  ),
                  Text(
                    'Longitude: ${point.longitude}',
                    style:
                        const TextStyle(fontSize: 16.0, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          // Implement copy functionality here
                          Clipboard.setData(
                            ClipboardData(
                                text: '${point.latitude}, ${point.longitude}'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard'),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          // Implement share functionality here
                          // You can use a share plugin or any other method
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );

        customPinLocation = point;

        customPinMarker = Marker(
          markerId: const MarkerId('customPin'),
          position: point,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: address, snippet: 'No additional info'),
        );

        markers.clear();
        markers.add(carMarker!);
        markers.add(customPinMarker!);

        setState(() {});
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
  }

  // Method to update the car marker position
  void _updateCarMarker() {
    if (carMarker != null && currentLocation != null) {
      // Update the car marker position with the current location
      carMarker =
          carMarker!.copyWith(positionParam: currentLocation!.toLatLng());

      // Update the state to trigger a rebuild
      setState(() {
        markers.removeWhere((marker) => marker.markerId.value == 'carMarker');
        markers.add(carMarker!);
      });
    }
  }

  // ...

  // Inside _getLocation() method, after setting currentUserLocation

  void _startSmartRouting() {
    if (customPinLocation == null || currentLocation == null) {
      print('Error: Custom pin location or current location is null');
      return;
    }

    // Create a Polyline from current location to the custom pin location
    Polyline newPolyline = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.blue,
      points: [currentLocation!.toLatLng(), customPinLocation!],
      width: 5,
    );

    // Update the state to trigger a rebuild
    setState(() {
      polylines = {newPolyline};
    });
  }
}

extension LocationDataExtension on location.LocationData {
  LatLng toLatLng() {
    return LatLng(latitude!, longitude!);
  }
}
