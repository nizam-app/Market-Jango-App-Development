// global_tracking_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/screen/global_tracking_screen/data/global_tracking_data.dart';
import 'package:market_jango/core/screen/global_tracking_screen/model/global_tracking_model.dart';
import 'package:market_jango/core/screen/profile_screen/data/profile_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../features/buyer/screens/order/screen/buyer_order_page.dart';
import '../../../../features/vendor/widgets/custom_back_button.dart';
import '../../buyer_massage/screen/global_chat_screen.dart';

class GlobalTrackingScreen1 extends ConsumerStatefulWidget {
  const GlobalTrackingScreen1({
    super.key,
    required this.screenName,
    required this.invoiceId,
  });

  static const String routeName = "/transportTracking";

  final String screenName;
  final int invoiceId;

  @override
  ConsumerState<GlobalTrackingScreen1> createState() =>
      _GlobalTrackingScreen1State();
}

class _GlobalTrackingScreen1State
    extends ConsumerState<GlobalTrackingScreen1> {
  bool _advanced = false; // false = basic info, true = logs

  String? userId;

  Future<void> _loadUserId() async {
    final pref = await SharedPreferences.getInstance();
    final stored = pref.getString("user_id");
    setState(() {
      userId = stored;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // -------- delivery_status -> step index (0,1,2) ----------
  int _mapDeliveryStatusToStep(String status) {
    final s = status.toLowerCase();

    if (s == 'assignedorder' ||
        s == 'assigned_order' ||
        s == 'assigned' ||
        s == 'pending') {
      return 0; // only first point active
    }
    if (s == 'ongoing') {
      return 1; // first + second active
    }
    if (s == 'completed' || s == 'complete' || s == 'cancelled') {
      return 2; // all three active
    }
    return 0;
  }

  // avatar widget (userProvider only when userId available)
  Widget _buildUserAvatar() {
    final uid = userId;
    if (uid == null || uid.isEmpty) {
      return CircleAvatar(
        radius: 20.r,
        child: const Icon(Icons.person),
      );
    }

    final userAsync = ref.watch(userProvider(uid));
    return userAsync.when(
      data: (data) {
        final image = data.image;
        return CircleAvatar(
          radius: 20.r,
          backgroundImage: NetworkImage(image),
        );
      },
      loading: () => SizedBox(
        width: 24.r,
        height: 24.r,
        child: const CircularProgressIndicator(),
      ),
      error: (_, __) => CircleAvatar(
        radius: 20.r,
        child: const Icon(Icons.error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trackingAsync =
    ref.watch(trackingDetailsProvider(widget.invoiceId));

    return Scaffold(
      body: trackingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (invoice) {
          final stepIndex =
          _mapDeliveryStatusToStep(invoice.deliveryStatus);
          final logs = invoice.statusLogs;
          final hasLogs = logs.isNotEmpty;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                const CustomBackButton(),
                SizedBox(height: 10.h),

                // -------- Header ----------
                Row(
                  children: [
                    _buildUserAvatar(),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.deliveryStatus, // e.g. Pending
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Track your order",
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // শুধু manually toggle করার জন্য
                    // Switch(
                    //   value: _advanced,
                    //   onChanged: (v) => setState(() => _advanced = v),
                    // ),
                  ],
                ),
                SizedBox(height: 20.h),

                // -------- Progress stepper ----------
                Row(
                  children: [
                    _glossyCircle(active: stepIndex >= 0),
                    _glossyLine(active: stepIndex >= 1),
                    _glossyCircle(active: stepIndex >= 1),
                    _glossyLine(active: stepIndex >= 2),
                    _glossyCircle(active: stepIndex >= 2),
                  ],
                ),
                SizedBox(height: 20.h),

                Text(
                  invoice.deliveryStatus,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),

                // Tracking number
                _trackingNumber(invoice.taxRef.isNotEmpty
                    ? invoice.taxRef
                    : 'INV-${invoice.id}'),
                SizedBox(height: 20.h),

         
                if (_advanced && hasLogs)
                  _screen2Body(context, logs)
                else
                  SizedBox()
                  // _screen1Body(context, invoice),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- Tracking number box ----------
  Widget _trackingNumber(String trackingNumber) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tracking Number",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  trackingNumber,
                  style: TextStyle(fontSize: 13.sp),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy, color: Colors.grey, size: 20.sp),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: trackingNumber),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tracking ID copied"),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }


  // ---------- Screen-1 body (basic info) ----------
  Widget _screen1Body(BuildContext context, TrackingInvoice invoice) {
    final created =
        invoice.createdAt?.toLocal().toString().substring(0, 16) ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _timelineItem(
          title: "Order placed",
          desc: "Customer: ${invoice.cusName}",
          time: created,
          active: true,
        ),
        _timelineItem(
          title: "Payment status: ${invoice.status}",
          desc: "Payable: ${invoice.payable} ${invoice.currency}",
          time: "",
          active: true,
        ),
        _timelineItem(
          title: "Shipping address",
          desc:
          "${invoice.shipAddress}, ${invoice.shipCity}, ${invoice.shipCountry}",
          time: "",
        ),
        SizedBox(height: 20.h),

        // Driver info (আগের guard 그대로)
        if (widget.screenName != BuyerOrderPage.routeName)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Driver Information",
                style: TextStyle(
                    fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
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
                          Text(
                            "Mr John Doe",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "01780053624",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
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

  // ---------- Screen-2 body = status_logs ----------
  Widget _screen2Body(
      BuildContext context, List<TrackingStatusLog> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: logs.map((log) {
        final created =
            log.createdAt?.toLocal().toString().substring(0, 16) ?? '';
        final highlight = log.isActive == 1;

        return _timelineItem(
          title: log.status,
          desc: log.note,
          time: created,
          highlight: highlight,
        );
      }).toList(),
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
            boxShadow: [
              BoxShadow(color: glow, blurRadius: 16.r, spreadRadius: 2.r),
            ],
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
                  color:
                  (active
                      ? const Color(0xFF6DB2FF)
                      : const Color(0xFFCAD4DE))
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
    final Color titleColor = highlight
        ? Colors.orange
        : (shipped ? Colors.blue : Colors.black);
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
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
              ),
              if (time.isNotEmpty)
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: timeBg,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: timeColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            desc,
            style: TextStyle(
              fontSize: 12.sp,
              color:
              highlight ? const Color(0xFF0059A0) : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

// ========== Bottom sheet ==========
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
          padding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: const Border(
                    bottom: BorderSide(color: Colors.blue, width: 2),
                  ),
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
              Text(
                "What should I do?",
                style: TextStyle(
                    fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Text(
                "Don’t worry, we will shortly contact you to arrange a more suitable time. "
                    "You can also call +00 000 000 000 or chat with our customer care service.",
                style: TextStyle(
                    fontSize: 13.sp, color: Colors.grey[700]),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  onPressed: () =>
                      context.push(GlobalChatScreen.routeName),
                  child: Text(
                    "Chat Now",
                    style: TextStyle(
                        fontSize: 14.sp, color: Colors.white),
                  ),
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

class TrackingArgs {
  final String screenName;
  final int invoiceId;

  const TrackingArgs({
    required this.screenName,
    required this.invoiceId,
  });
}