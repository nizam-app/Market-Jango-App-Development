// lib/features/transport/screens/driver/screen/set_drop_location_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:market_jango/core/screen/google_map/data/location_store.dart';
import 'package:market_jango/core/screen/google_map/screen/google_map.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/transport/screens/driver/screen/driver_details_screen.dart';

class SetDropLocationScreen extends ConsumerStatefulWidget {
  static const String routeName = '/set_drop_location';

  const SetDropLocationScreen({super.key});

  @override
  ConsumerState<SetDropLocationScreen> createState() =>
      _SetDropLocationScreenState();
}

class _SetDropLocationScreenState extends ConsumerState<SetDropLocationScreen> {
  final TextEditingController _addressController = TextEditingController();
  double? _lat;
  double? _lng;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('Set drop location')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Drop address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter drop address',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _lat == null
                        ? 'No location selected'
                        : 'Lat: ${_lat!.toStringAsFixed(5)}, '
                              'Lng: ${_lng!.toStringAsFixed(5)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ),

                // 🔹 LocationButton এর জায়গায় নিজস্ব ছোট বাটন
                InkWell(
                  onTap: () async {
                    final result = await context.push<LatLng>(
                      GoogleMapScreen.routeName,
                    );

                    if (result != null) {
                      ref.read(selectedLatitudeProvider.notifier).state =
                          result.latitude;
                      ref.read(selectedLongitudeProvider.notifier).state =
                          result.longitude;

                      setState(() {
                        _lat = result.latitude;
                        _lng = result.longitude;
                      });

                      GlobalSnackbar.show(
                        context,
                        title: "Success",
                        message: "Location selected successfully!",
                        type: CustomSnackType.success,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.location_on, size: 18, color: Colors.orange),
                        SizedBox(width: 4),
                        Text(
                          'Pick',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: size.width,
              child: ElevatedButton(
                onPressed: () {
                  final addr = _addressController.text.trim();
                  if (addr.isEmpty) {
                    GlobalSnackbar.show(
                      context,
                      title: "Error",
                      message: "Please enter drop address",
                      type: CustomSnackType.error,
                    );
                    return;
                  }
                  if (_lat == null || _lng == null) {
                    GlobalSnackbar.show(
                      context,
                      title: "Error",
                      message: "Please select drop location",
                      type: CustomSnackType.error,
                    );
                    return;
                  }

                  // এই screen থেকে result পাঠাচ্ছি
                  context.pop(
                    TransportDropLocation(
                      address: addr,
                      latitude: _lat!,
                      longitude: _lng!,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
                child: const Text(
                  'Continue to payment',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
