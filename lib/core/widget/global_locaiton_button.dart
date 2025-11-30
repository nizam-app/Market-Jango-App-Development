import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocationButton extends StatelessWidget {
  final VoidCallback? onTap;
  const LocationButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h, // Example height, adjust as needed
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF4081), // Pink color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r), // Rounded edges
          ),
          elevation: 0,
        ),
        child: Text(
          "Enter you location",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
