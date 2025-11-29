// order_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/screen/buyer_massage/model/chat_history_route_model.dart';
import 'package:market_jango/core/screen/buyer_massage/screen/global_chat_screen.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/features/driver/screen/driver_order/data/driver_order_details_data.dart';
import 'package:market_jango/features/driver/screen/driver_order/model/driver_order_details_model.dart';
import 'package:market_jango/features/driver/screen/driver_traking_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({super.key, required this.trackingId});

  static const routeName = "/orderDetails";
  final String trackingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.parse(trackingId);
    final trackingAsync = ref.watch(driverTrackingProvider(id));

    return Scaffold(
      backgroundColor: AllColor.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomBackButton(),
            SizedBox(height: 10.h),
            trackingAsync.when(
              loading: () => const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, st) => Expanded(
                child: Center(
                  child: Text(
                    err.toString(),
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  ),
                ),
              ),
              data: (DriverTrackingData data) {
                final invoice = data.invoice;

                return _DetailsContent(
                  orderId: invoice?.taxRef ?? "",
                  pickupAddress: data.pickupAddress,
                  dropoffAddress: data.shipAddress,
                  customerName: invoice?.cusName ?? "___",
                  customerPhone: invoice?.cusPhone ?? "___",
                  lat: data.shipLatitude ?? 0,
                  lot: data.shipLongitude ?? 0,
                );
              },
            ),
            trackingAsync.when(
              data: (DriverTrackingData data) {
                return _BottomActions(
                  onMessage: () async {
                    SharedPreferences pefa =
                        await SharedPreferences.getInstance();
                    String id = pefa.getString('user_id') ?? '';
                    final intId = int.parse(id);

                    context.push(
                      GlobalChatScreen.routeName,
                      extra: ChatArgs(
                        partnerId: data.userId,
                        partnerName: data.cusName,
                        partnerImage:
                            data.user?.image ??
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUn6fL1_OXhaWOYa0QSrP5jHKIjFHezT18Yw&s",
                        myUserId: intId,
                      ),
                    );
                  },
                  onStartDelivery: () {
                    context.push(DriverTrakingScreen.routeName);
                  },
                );
              },
              loading: () => const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, st) => Expanded(
                child: Center(
                  child: Text(
                    err.toString(),
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------ UI Part (unchanged mostly) ------------------------------ */

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.orderId,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.customerName,
    required this.customerPhone,
    required this.lat,
    required this.lot,
  });

  final String orderId;
  final String pickupAddress;
  final String dropoffAddress;
  final String customerName;
  final String customerPhone;
  final double lat;
  final double lot;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order #$orderId",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AllColor.black,
              ),
            ),
            SizedBox(height: 16.h),
            _Label("Pickup address"),
            _BodyText(pickupAddress),
            _DividerLine(),
            _Label("Drop-off address"),
            _BodyText(dropoffAddress),
            _DividerLine(),
            _Label("Customer Details"),
            _BodyText(customerName),
            _BodyText(customerPhone),
            // SizedBox(height: 10.h),
            // _Label("Customer instruction"),
            // _InstructionBox(text: instruction),
            SizedBox(height: 10.h),
            _MapImage(latitude: lat, longitude: lot),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          color: AllColor.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          height: 1.35,
          color: AllColor.black87,
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.h,
      margin: EdgeInsets.only(bottom: 12.h),
      color: AllColor.grey200,
    );
  }
}

class _InstructionBox extends StatelessWidget {
  const _InstructionBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AllColor.grey300,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13.sp, color: AllColor.black87),
      ),
    );
  }
}

class _MapImage extends StatelessWidget {
  const _MapImage({super.key, required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    final position = LatLng(latitude, longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: position, zoom: 13),
          markers: {
            Marker(
              markerId: const MarkerId('orderLocation'),
              position: position,
            ),
          },
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onMessage,
    required this.onStartDelivery,
  });

  final VoidCallback onMessage;
  final VoidCallback onStartDelivery;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: Column(
        children: [
          _FilledButton(
            label: "Message Now",
            bg: AllColor.blue500,
            fg: AllColor.white,
            onTap: onMessage,
          ),
          SizedBox(height: 12.h),
          _FilledButton(
            label: "Start Delivery",
            bg: AllColor.loginButtomColor,
            fg: AllColor.white,
            onTap: onStartDelivery,
          ),
        ],
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  const _FilledButton({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 13.h),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}
