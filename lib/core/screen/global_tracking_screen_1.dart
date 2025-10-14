// global_tracking_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../features/buyer/screens/order/screen/buyer_order_page.dart';
import '../../features/vendor/widgets/custom_back_button.dart';
import 'buyer_massage/screen/global_chat_screen.dart';

class GlobalTrackingScreen1 extends StatefulWidget {
  const GlobalTrackingScreen1({
    super.key,
    required this.screenName,
    this.startAdvanced = false, // show "screen 2" state initially
    this.autoAdvance = true,    // auto move from false -> true in 3s
  });

  static const String routeName = "/transportTracking";
  final String screenName;
  final bool startAdvanced;
  final bool autoAdvance;

  @override
  State<GlobalTrackingScreen1> createState() => _GlobalTrackingScreen1State();
}

class _GlobalTrackingScreen1State extends State<GlobalTrackingScreen1> {
  late bool _advanced; // false = Screen-1 view, true = Screen-2 view
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _advanced = widget.startAdvanced;

    // ⏱️ Demo logic: after 3s move to the advanced (screen-2) state
    if (widget.autoAdvance && !_advanced) {
      _timer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _advanced = true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            const CustomBackButton(),
            SizedBox(height: 10.h),

            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: const NetworkImage(
                    "https://randomuser.me/api/portraits/women/65.jpg",
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("To Receive",
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    Text("Track Your Order",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                // small toggle to test quickly
                Switch(
                  value: _advanced,
                  onChanged: (v) => setState(() => _advanced = v),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Progress (reacts to _advanced)
            Row(
              children: [
                _glossyCircle(active: true),
                _glossyLine(active: true),
                _glossyCircle(active: true),
                _glossyLine(active: _advanced),
                _glossyCircle(active: _advanced),
              ],
            ),
            SizedBox(height: 20.h),

            // Title for phase 1
            if (!_advanced)
              Text("Packed",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),

            SizedBox(height: 16.h),

            // Tracking number (common)
            _trackingNumber(),

            SizedBox(height: 20.h),

            // Body switches by state
            if (_advanced) _screen2Body(context) else _screen1Body(context),
          ],
        ),
      ),
    );
  }

  // ---------- Common: Tracking number box ----------
  Widget _trackingNumber() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tracking Number",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("LGS-129827839300763731", style: TextStyle(fontSize: 13.sp)),
              Icon(Icons.copy, color: Colors.grey, size: 20.sp),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Screen-1 body ----------
  Widget _screen1Body(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _timelineItem(
          title: "Packed",
          desc:
          "Your parcel is packed and will be handed over to our delivery partner.",
          time: "April.19 12:31",
          active: true,
        ),
        InkWell(
          onTap: () {
            // Example: when the user taps, go to booking step.
            context.push("/transport_booking3");
          },
          child: _timelineItem(
            title: "On the Way to Logistic Facility",
            desc: "Lorem ipsum dolor sit amet consectetur adipiscing elit.",
            time: "April.19 16:20",
            active: true,
          ),
        ),
        _timelineItem(
          title: "Arrived at Logistic Facility",
          desc: "Lorem ipsum dolor sit amet consectetur adipiscing elit.",
          time: "April.19 19:07",
          active: true,
        ),
        _timelineItem(
          title: "Shipped",
          desc: "Lorem ipsum dolor sit amet consectetur adipiscing elit.",
          time: "Expected on April.20",
          active: false,
          shipped: true,
        ),
        SizedBox(height: 20.h),

        // Driver info (kept exactly like your original guard)
        if (widget.screenName != BuyerOrderPage.routeName)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Driver Information",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
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
                        "https://randomuser.me/api/portraits/men/43.jpg",
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Mr John Doe",
                              style:
                              TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                          Text("01780053624",
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
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
            ],
          ),
      ],
    );
  }

  // ---------- Screen-2 body ----------
  Widget _screen2Body(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _timelineItem(
          title: "Packed",
          desc:
          "Your parcel is packed and will be handed over to our delivery partner.",
          time: "April.19 12:31",
        ),
        _timelineItem(
          title: "On the Way to Logistic Facility",
          desc: "Lorem ipsum dolor sit amet consectetur adipiscing elit.",
          time: "April.19 16:20",
        ),
        _timelineItem(
          title: "Arrived at Logistic Facility",
          desc: "Lorem ipsum dolor sit amet consectetur adipiscing elit.",
          time: "April.19 19:07",
        ),
        _timelineItem(
          title: "Shipped",
          desc: "Lorem ipsum dolor sit amet consectetur adipiscing elit.",
          time: "April.20 06:15",
        ),
        _timelineItem(
          title: "Out for Delivery",
          desc: "Lorem ipsum dolor sit amet consectetur adipiscing elit.",
          time: "April.22 11:10",
        ),
        InkWell(
          onTap: () => DeliveryFailedPopup.show(context),
          child: _timelineItem(
            title: "Attempt to deliver your parcel was not successful →",
            desc: "Lorem ipsum dolor sit amet consectetur adipiscing elit.",
            time: "April.19 12:50",
            highlight: true,
          ),
        ),
      ],
    );
  }

  // ---------- Pretty stepper pieces ----------
  Widget _glossyCircle({required bool active}) {
    final Gradient gActive = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF58A6FF), Color(0xFF0B3E7C)],
    );
    final Gradient gInactive = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF9FB1C2), Color(0xFF6F8091)],
    );
    final Color glow = active
        ? const Color(0xFF58A6FF).withOpacity(0.35)
        : const Color(0xFF9FB1C2).withOpacity(0.30);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: glow, blurRadius: 16.r, spreadRadius: 2.r)],
          ),
        ),
        Container(
          width: 24.r,
          height: 24.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
        ),
        Container(
          width: 16.r,
          height: 16.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: active ? gActive : gInactive,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 4.r,
                offset: Offset(0, 2.h),
              ),
            ],
            border: Border.all(color: Colors.white, width: 2.r),
          ),
        ),
      ],
    );
  }

  Widget _glossyLine({required bool active}) {
    final Gradient gActive = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF6DB2FF), Color(0xFF0D4183)],
    );
    final Gradient gInactive = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFE5EBF1), Color(0xFFDDE3EA)],
    );

    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 12.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: (active ? const Color(0xFF6DB2FF) : const Color(0xFFCAD4DE))
                      .withOpacity(0.35),
                  blurRadius: 12.r,
                  spreadRadius: 1.r,
                ),
              ],
            ),
          ),
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: active ? gActive : gInactive,
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: const Alignment(0, -0.6),
              child: Container(
                height: 1.2.h,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(1.r),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: const Alignment(0, 0.7),
              child: Container(
                height: 1.2.h,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(1.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Timeline row ----------
  Widget _timelineItem({
    required String title,
    required String desc,
    required String time,
    bool active = false,
    bool shipped = false,
    bool highlight = false,
  }) {
    final Color titleColor =
    highlight ? Colors.orange : (shipped ? Colors.blue : Colors.black);
    final Color timeBg =
    highlight ? Colors.orange.withOpacity(0.1) : Colors.grey.shade200;
    final Color timeColor = highlight ? Colors.orange : Colors.black;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title,
                    style:
                    TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: titleColor)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: timeBg,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(time,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: timeColor)),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            desc,
            style: TextStyle(
              fontSize: 12.sp,
              color: highlight ? const Color(0xFF0059A0) : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

// ========== Bottom sheet from old Screen-2 ==========
class DeliveryFailedPopup {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: const Border(bottom: BorderSide(color: Colors.blue, width: 2)),
                ),
                child: Center(
                  child: Text(
                    "Delivery was not successful",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text("What should I do?",
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              Text(
                "Don’t worry, we will shortly contact you to arrange a more suitable time. "
                    "You can also call +00 000 000 000 or chat with our customer care service.",
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  onPressed: () => context.push(ChatScreen.routeName),
                  child:
                  Text("Chat Now", style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                ),
              ),
              SizedBox(height: 50.h),
            ],
          ),
        );
      },
    );
  }
}