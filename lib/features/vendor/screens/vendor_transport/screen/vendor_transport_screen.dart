import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/features/vendor/screens/vendor_driver_list/screen/vendor_driver_list.dart';

const String kGoogleApiKey = 'AIzaSyDkSsblaqxoIpj1azSs7nBE7Xssv6O2v6k';

class VendorTransportScreen extends StatefulWidget {
  const VendorTransportScreen({super.key});
  static const routeName = "/vendorTransporter";

  @override
  State<VendorTransportScreen> createState() => _VendorTransportScreenState();
}

class _VendorTransportScreenState extends State<VendorTransportScreen> {
  int _tab = 0;
  final _pickup = TextEditingController();
  final _destination = TextEditingController();

  GoogleMapController? _mapController;
  bool _mapReady = false;

  // Default Dhaka
  LatLng _pickupLatLng = const LatLng(23.8103, 90.4125);
  LatLng _destinationLatLng = const LatLng(23.8103, 90.4125);
  LatLng? _currentLatLng;

  bool _locationPermissionGranted = false;

  List<PlaceSuggestion> _pickupSuggestions = [];
  List<PlaceSuggestion> _destinationSuggestions = [];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _pickup.dispose();
    _destination.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      _showLocationDialog(
        title: 'Turn on Location',
        message: 'Please turn on your location services to use the map.',
        onPressed: () {
          Geolocator.openLocationSettings();
          Navigator.of(context).pop();
        },
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        _showLocationDialog(
          title: 'Location Permission',
          message: 'We need your location permission to show the map.',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      _showLocationDialog(
        title: 'Location Permission Blocked',
        message:
            'You have blocked location permission. Please enable it from settings.',
        onPressed: () {
          Geolocator.openAppSettings();
          Navigator.of(context).pop();
        },
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _locationPermissionGranted = true;
      _pickupLatLng = _currentLatLng!;
    });

    if (_mapReady && _currentLatLng != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLatLng!, 16),
      );
    }
  }

  void _showLocationDialog({
    required String title,
    required String message,
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: onPressed ?? () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<List<PlaceSuggestion>> _fetchSuggestions(String input) async {
    if (input.trim().isEmpty) return [];
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=$input&key=$kGoogleApiKey&types=geocode&language=en',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) return [];

    final data = jsonDecode(res.body);
    if (data['status'] != 'OK') return [];

    final List preds = data['predictions'] as List;

    return preds
        .map(
          (p) => PlaceSuggestion(
            description: p['description'],
            placeId: p['place_id'],
          ),
        )
        .toList();
  }

  Future<LatLng?> _getLatLngFromPlaceId(String placeId) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId&key=$kGoogleApiKey',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body);
    if (data['status'] != 'OK') return null;

    final loc = data['result']['geometry']['location'];
    return LatLng(loc['lat'], loc['lng']);
  }

  Future<void> _onPickupChanged(String value) async {
    setState(() {
      _pickupSuggestions = [];
    });
    if (value.length < 3) return;

    final suggestions = await _fetchSuggestions(value);
    setState(() {
      _pickupSuggestions = suggestions;
    });
  }

  Future<void> _onDestinationChanged(String value) async {
    setState(() {
      _destinationSuggestions = [];
    });
    if (value.length < 3) return;

    final suggestions = await _fetchSuggestions(value);
    setState(() {
      _destinationSuggestions = suggestions;
    });
  }

  Future<void> _selectPickupSuggestion(PlaceSuggestion s) async {
    _pickup.text = s.description;
    setState(() {
      _pickupSuggestions = [];
    });

    final latLng = await _getLatLngFromPlaceId(s.placeId);
    if (latLng == null) return;

    setState(() {
      _pickupLatLng = latLng;
    });

    if (_mapReady) {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
    }
  }

  Future<void> _selectDestinationSuggestion(PlaceSuggestion s) async {
    _destination.text = s.description;
    setState(() {
      _destinationSuggestions = [];
    });

    final latLng = await _getLatLngFromPlaceId(s.placeId);
    if (latLng == null) return;

    setState(() {
      _destinationLatLng = latLng;
    });

    if (_mapReady) {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ---------- Google Map ----------
            Positioned.fill(
              child: GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                  _mapReady = true;
                  if (_currentLatLng != null) {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(_currentLatLng!, 16),
                    );
                  }
                },
                initialCameraPosition: CameraPosition(
                  target: _pickupLatLng,
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('pickup'),
                    position: _pickupLatLng,
                    infoWindow: const InfoWindow(title: 'Pickup Location'),
                  ),
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: _destinationLatLng,
                    infoWindow: const InfoWindow(title: 'Destination'),
                  ),
                },
                zoomControlsEnabled: true,
                myLocationEnabled: _locationPermissionGranted,
                myLocationButtonEnabled: _locationPermissionGranted,
                onTap: (LatLng latLng) {
                  if (_mapController != null) {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLng(latLng),
                    );
                  }
                },
              ),
            ),

            // ---------- Foreground UI ----------
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),

                    _SegmentedToggle(
                      leftText: 'Track shipments',
                      value: _tab,
                      onChanged: (v) {
                        setState(() => _tab = v);
                        if (v == 0) {
                          context.push('/requestTransport');
                        } else {
                          context.push('/vendortrack_shipments');
                        }
                      },
                    ),

                    SizedBox(height: 12.h),

                    // Pickup field + suggestions
                    _LocationField(
                      controller: _pickup,
                      hint: 'Enter Pickup location',
                      icon: Icons.near_me_rounded,
                      onChanged: _onPickupChanged,
                    ),
                    if (_pickupSuggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: _pickupSuggestions
                              .map(
                                (s) => ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.location_on_outlined,
                                    size: 18,
                                  ),
                                  title: Text(
                                    s.description,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  onTap: () => _selectPickupSuggestion(s),
                                ),
                              )
                              .toList(),
                        ),
                      ),

                    SizedBox(height: 10.h),

                    // Destination field + suggestions
                    _LocationField(
                      controller: _destination,
                      hint: 'Destination',
                      icon: Icons.location_on_rounded,
                      onChanged: _onDestinationChanged,
                    ),
                    if (_destinationSuggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: _destinationSuggestions
                              .map(
                                (s) => ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.location_on_outlined,
                                    size: 18,
                                  ),
                                  title: Text(
                                    s.description,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  onTap: () => _selectDestinationSuggestion(s),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ---------- Save Button ----------
            Positioned(
              left: 16,
              right: 16,
              bottom: 18 + MediaQuery.of(context).padding.bottom,
              child: CustomAuthButton(
                buttonText: "Save",
                onTap: () => nextButonDone(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void nextButonDone(BuildContext context) {
    goToVendorDriverList(context);
  }

  void goToVendorDriverList(BuildContext context) {
    context.push(VendorDriverList.routeName);
  }
}

class PlaceSuggestion {
  final String description;
  final String placeId;

  PlaceSuggestion({required this.description, required this.placeId});
}

void nextButonDone(BuildContext context) {
  goToVendorDriverList(context);
}

void goToVendorDriverList(BuildContext context) {
  context.push(VendorDriverList.routeName);
}

/* -------------------- Custom pieces -------------------- */

class _SegmentedToggle extends StatelessWidget {
  final String leftText;
  final int value; // 0/1
  final ValueChanged<int> onChanged;

  const _SegmentedToggle({
    required this.leftText,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget seg(String text, bool active, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AllColor.loginButtomColor : AllColor.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active ? AllColor.loginButtomColor : AllColor.grey200,
              ),
              boxShadow: active
                  ? [
                      const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              text,
              style: TextStyle(
                color: active ? AllColor.white : AllColor.black,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }

    return Row(children: [seg(leftText, value == 0, () => onChanged(0))]);
  }
}

class _LocationField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String>? onChanged;

  const _LocationField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AllColor.grey200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: AllColor.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AllColor.black54),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AllColor.textHintColor),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper model
// class PlaceSuggestion {
//   final String description;
//   final String placeId;
//
//   PlaceSuggestion({required this.description, required this.placeId});
// }
