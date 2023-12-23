import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as places;
import 'package:location/location.dart' as location;
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late location.Location userLocation;
  late String currentUserLocation;
  location.LocationData? currentLocation;
  final places.GoogleMapsPlaces _placesApi = places.GoogleMapsPlaces(
      apiKey: 'YOUR_API_KEY'); // Replace with your API key

  Set<Marker> markers = <Marker>{};
  final panelController = PanelController();
  LatLng? customPinLocation;
  Marker? customPinMarker;

  @override
  void initState() {
    super.initState();
    userLocation = location.Location();
    currentUserLocation = '';
    _getLocation();
  }

  Future<String?> _getLocation() async {
    try {
      currentLocation = await userLocation.getLocation();

      print(
          'Latitude: ${currentLocation?.latitude}, Longitude: ${currentLocation?.longitude}');

      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentLocation!.latitude!,
        currentLocation!.longitude!,
      );

      if (placemarks.isNotEmpty) {
        String currentAddress = placemarks.first.name ?? 'Unknown Address';

        setState(() {
          currentUserLocation = currentAddress;
        });

        return currentAddress;
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
    );
  }

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
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildLocationTextField(),
                    const SizedBox(height: 20.0),
                    _buildGreenButton('Start Smart Routing', () {}),
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
                          () => _getNearbyRestaurants(),
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
        } else if (snapshot.hasData && snapshot.data != null) {
          return Text('Current Location: ${snapshot.data}');
        } else {
          String currentUserLocation = snapshot.data ?? 'Unknown Address';

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
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: currentUserLocation,
                            hintStyle: const TextStyle(
                              fontSize: 16.0,
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
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(
                    12.0,
                    0.0,
                    12.0,
                    8.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Enter destination...',
                            hintStyle: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
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

        // Construct a detailed address
        String address =
            '${placemark.name ?? ''}, ${placemark.thoroughfare ?? ''}, ${placemark.subThoroughfare ?? ''}, ${placemark.locality ?? ''}, ${placemark.subLocality ?? ''}, ${placemark.administrativeArea ?? ''}, ${placemark.postalCode ?? ''}, ${placemark.country ?? ''}';

        // Create a custom marker with the detailed address as the title
        customPinMarker = Marker(
          markerId: const MarkerId('customPin'),
          position: point,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: address),
        );

        // Clear existing markers and add the custom marker
        markers.clear();
        markers.add(customPinMarker!);

        // Update the state to trigger a rebuild
        setState(() {});
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
  }

  void _getNearbyRestaurants() async {
    try {
      if (currentLocation == null) {
        print('Error: Current location is null');
        return;
      }

      markers.clear();

      // Fetch nearby restaurants using Google Places API
      places.PlacesSearchResponse response =
          await _placesApi.searchNearbyWithRadius(
        places.Location(
          lat: customPinLocation?.latitude ?? currentLocation!.latitude!,
          lng: customPinLocation?.longitude ?? currentLocation!.longitude!,
        ),
        2000,
        type: 'restaurant',
      );

      for (places.PlacesSearchResult result in response.results) {
        double lat = result.geometry!.location.lat;
        double lng = result.geometry!.location.lng;
        String name = result.name ?? '';

        Marker marker = Marker(
          markerId: MarkerId(name),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: name),
        );

        markers.add(marker);
      }

      if (markers.isNotEmpty) {
        mapController.animateCamera(
          CameraUpdate.newLatLng(markers.first.position),
        );
      }

      setState(() {});
    } catch (e) {
      print('Error fetching nearby restaurants: $e');
    }
  }
}
