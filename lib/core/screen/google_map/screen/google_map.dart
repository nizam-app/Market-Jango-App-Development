import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class GoogleMapScreen extends StatefulWidget {
  static const String routeName = '/google_map';

  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;

  // Marker for selected location
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location permission
      final status = await Permission.location.request();

      if (status.isGranted) {
        // Get current position
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          _currentPosition = position;
          _pickedLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });

        // Add marker for current location
        _addMarker(_pickedLocation!);

        // Move camera to current location
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            14.0,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        // Handle permission denied
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error getting location: $e");
    }
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers.clear(); // Remove previous marker
      _markers.add(
        Marker(
          markerId: const MarkerId("selected_location"),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          // Marker এ click করলে কাজ করবে
          onTap: () {
            print(
              "Marker tapped at: ${position.latitude}, ${position.longitude}",
            );
            _openSheet(position);
          },
          // Marker টি dragable করুন (optional)
          draggable: true,
          onDragEnd: (newPosition) {
            print(
              "Marker dragged to: ${newPosition.latitude}, ${newPosition.longitude}",
            );
            _openSheet(newPosition);
          },
        ),
      );
      _pickedLocation = position;
    });
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Location Permission Required"),
        content: const Text(
          "Please enable location services to use this feature.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
            child: const Text("Settings"),
          ),
        ],
      ),
    );
  }

  void _openSheet(LatLng latLng) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "📍 Confirm Location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Coordinates - FIXED: Using proper icons
              Row(
                children: [
                  Icon(
                    Icons.explore,
                    size: 16,
                    color: Colors.grey,
                  ), // Changed from Icons.latitude
                  const SizedBox(width: 8),
                  Text("Latitude: ${latLng.latitude.toStringAsFixed(6)}"),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(
                    Icons.explore_outlined,
                    size: 16,
                    color: Colors.grey,
                  ), // Changed from Icons.longitude
                  const SizedBox(width: 8),
                  Text("Longitude: ${latLng.longitude.toStringAsFixed(6)}"),
                ],
              ),
              const SizedBox(height: 20),

              // CONFIRM BUTTON - FIXED: Remove const from ElevatedButton
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // bottomSheet close
                    Navigator.pop(context, latLng); // Return to previous screen
                  },
                  child: const Text(
                    "Confirm Location",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // CANCEL BUTTON - FIXED: Remove const from OutlinedButton
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet only
                  },
                  child: const Text("Select Different Location"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📌 Select Store Location"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: "Current Location",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          )
                        : const LatLng(23.7806367, 90.4000061),
                    zoom: 14.0,
                  ),
                  onTap: (LatLng position) {
                    _addMarker(position); // Add marker where user taps
                    _openSheet(position); // Show the bottom sheet
                  },
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),

                // Instruction Text
                const Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "Tap anywhere on map or click the marker to select location",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _getCurrentLocation,
            child: const Icon(Icons.my_location),
            tooltip: "Current Location",
          ),
          const SizedBox(height: 10),
          if (_pickedLocation != null)
            FloatingActionButton(
              onPressed: () {
                _openSheet(_pickedLocation!);
              },
              child: const Icon(Icons.check),
              backgroundColor: Colors.green,
              tooltip: "Confirm Location",
            ),
        ],
      ),
    );
  }
}
