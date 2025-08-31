import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';

class TransportCancelledDetails extends StatefulWidget {
  const TransportCancelledDetails({super.key});
  static const String routeName = "/cancelledDetails";

  @override
  State<TransportCancelledDetails> createState() => _TransportCancelledDetailsState();
}

class _TransportCancelledDetailsState extends State<TransportCancelledDetails> {
  // GoogleMapController? mapController;
  //
  // final LatLng pickupLocation = const LatLng(37.7749, -122.4194);
  //
  // final LatLng dropoffLocation = const LatLng(37.8044, -122.2711);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h,), 
            CustomBackButton(), 
            SizedBox(height: 10.h,), 
            /// Order ID
            Text("Order #1234",
                style: TextStyle(
                    fontSize: 16.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 16.h),

            /// Pickup Address
            _infoSection("Pickup address",
                "4517 Washington Ave. Manchester, Kentucky 39495"),
            Divider(height: 24.h),

            /// Drop-off Address
            _infoSection("Drop- off address",
                "6391 Elgin St. Celina, Delaware 10299"),
            Divider(height: 24.h),

            /// Customer Note
            _infoSection("Customer note", "John appaeell\n(239) 555-0108"),
            Divider(height: 24.h),

            /// Special Instruction
            Text("Special instruction:",
                style: TextStyle(
                    fontSize: 14.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 6.h),
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text("Don’t ring the bell",
                  style: TextStyle(fontSize: 13.sp, color: Colors.black)),
            ),
            SizedBox(height: 20.h),

            ///Google map Integarion 
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(12.r),
            //   child: SizedBox(
            //     height: 200.h,
            //     child: GoogleMap(
            //       initialCameraPosition: CameraPosition(
            //         target: pickupLocation,
            //         zoom: 12,
            //       ),
            //       onMapCreated: (controller) {
            //         mapController = controller;
            //       },
            //       markers: {
            //         Marker(
            //           markerId: const MarkerId("pickup"),
            //           position: pickupLocation,
            //           infoWindow: const InfoWindow(title: "Pickup"),
            //           icon: BitmapDescriptor.defaultMarkerWithHue(
            //             BitmapDescriptor.hueGreen,
            //           ),
            //         ),
            //         Marker(
            //           markerId: const MarkerId("dropoff"),
            //           position: dropoffLocation,
            //           infoWindow: const InfoWindow(title: "Drop-off"),
            //           icon: BitmapDescriptor.defaultMarkerWithHue(
            //             BitmapDescriptor.hueRed,
            //           ),
            //         ),
            //       },
            //       // 👇 Add these to fix scroll conflict
            //       gestureRecognizers: {
            //         Factory<OneSequenceGestureRecognizer>(
            //           () => EagerGestureRecognizer(),
            //         ),
            //       },
            //       zoomControlsEnabled: false,
            //       myLocationButtonEnabled: false,
            //     ),
            //   ),
            // ),

            SizedBox(height: 20.h),

            /// Driver Info
            Text("Driver Information",
                style: TextStyle(
                    fontSize: 14.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage: const NetworkImage(
                        "https://randomuser.me/api/portraits/men/43.jpg"),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Mr John Doe",
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600)),
                        Text("01780053624",
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.message, color: Colors.blue),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),

            /// Cancelled Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                onPressed: () {},
                child: Text("Cancelled",
                    style:
                        TextStyle(fontSize: 15.sp, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Info Section (Reusable)
  Widget _infoSection(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 6.h),
        Text(value,
            style: TextStyle(fontSize: 13.sp, color: Colors.black)),
      ],
    );
  }
}