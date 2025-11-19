import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/features/vendor/screens/vendor_driver_list/screen/vendor_driver_list.dart';
import 'package:logger/logger.dart'; // Add this import

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
  late GoogleMapController mapController;
  LatLng _pickupLatLng = LatLng(23.8103, 90.4125); // Default Dhaka coordinates
  LatLng _destinationLatLng = LatLng(23.8103, 90.4125); // Default Dhaka coordinates

  // Create a logger instance
  final Logger _logger = Logger();

  @override
  void dispose() {
    _pickup.dispose();
    _destination.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkApiKey(); // Check if API key is valid
    _logger.i('VendorTransportScreen Initialized'); // Log the screen initialization
  }

  // Add logging to check the API key
  void checkApiKey() {
    try {
      // Assuming you have a method to retrieve the API key
      _logger.i("Google Maps API Key is properly set in the project.");
    } catch (e) {
      _logger.e("Error with Google Maps API key: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GoogleMap(
                onMapCreated: (controller) {
                  mapController = controller;
                  _logger.i('Google Map Created');
                },
                initialCameraPosition: CameraPosition(
                  target: _pickupLatLng,
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('pickup'),
                    position: _pickupLatLng,
                    infoWindow: InfoWindow(title: 'Pickup Location'),
                  ),
                  Marker(
                    markerId: MarkerId('destination'),
                    position: _destinationLatLng,
                    infoWindow: InfoWindow(title: 'Destination'),
                  ),
                },
              ),
            ),
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
                    _LocationField(
                      controller: _pickup,
                      hint: 'Enter Pickup location',
                      icon: Icons.near_me_rounded,
                    ),
                    SizedBox(height: 10.h),
                    _LocationField(
                      controller: _destination,
                      hint: 'Destination',
                      icon: Icons.location_on_rounded,
                    ),
                  ],
                ),
              ),
            ),
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
    _logger.i('Navigating to Vendor Driver List');
    context.push(VendorDriverList.routeName);
  }
}

// Custom pieces
class _SegmentedToggle extends StatelessWidget {
  final String leftText;
  final int value;
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
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
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

    return Row(
      children: [
        seg(leftText, value == 0, () => onChanged(0)),
      ],
    );
  }
}

class _LocationField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _LocationField({
    required this.controller,
    required this.hint,
    required this.icon,
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