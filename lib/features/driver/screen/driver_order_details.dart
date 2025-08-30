import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/features/buyer/screens/buyer_massage/screen/chat_screen.dart';
import 'package:market_jango/features/driver/screen/driver_traking_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, });
  static final routeName = "/orderDetails"; 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColor.white,
      body: SafeArea(
        child: Column(
          children: [
           CustomBackButton(),
            SizedBox(height: 10,),
            _DetailsContent(
              orderId: "1234",
              pickupAddress:
                  "4517 Washington Ave. Manchester, Kentucky 39495",
              dropoffAddress:
                  "6391 Elgin St. Celina, Delaware 10299",
              customerName: "John appeaiel",
              customerPhone: "(239) 555-0108",
              instruction: "Don't ring the bell",
              imageUrl:
                  "https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=1200&auto=format&fit=crop",
            ),
            _BottomActions(
              onMessage: () {
                context.push(
                  ChatScreen.routeName, 
                  
                );
              },
              onStartDelivery: () {
                context.push(
                  DriverTrakingScreen.routeName
                ); 

              },
            ),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------ Custom Codebase ------------------------------ */


class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.orderId,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.customerName,
    required this.customerPhone,
    required this.instruction,
    required this.imageUrl,
  });

  final String orderId;
  final String pickupAddress;
  final String dropoffAddress;
  final String customerName;
  final String customerPhone;
  final String instruction;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order #$orderId",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AllColor.black,
                )),
             SizedBox(height: 16,),  
            _Label("Pickup address"),
            _BodyText(pickupAddress),
            _DividerLine(),
            _Label("Drop- off address"),
            _BodyText(dropoffAddress),
            _DividerLine(),
            _Label("Customer Details"),
            _BodyText(customerName),
            _BodyText(customerPhone),
             SizedBox(height: 10,),  
            _Label("Customer instruction:"),
            _InstructionBox(text: instruction),
             SizedBox(height: 10,),  
            _MapImage(imageUrl: imageUrl),
          SizedBox(height: 10,),  
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
  const _MapImage({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.network(imageUrl, fit: BoxFit.cover),
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
         SizedBox(height: 12,),
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

