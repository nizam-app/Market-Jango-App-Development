import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key});
static final String routeName = '/productDetails';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      SafeArea(child:
      SingleChildScrollView(
        child: Column(
          children: [
            ProductImage(),
        ],
        ),
      ),
      ),
    );
  }
}
class ProductImage extends StatelessWidget {
  const ProductImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          // Product Image with Back Button
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                child: Image.network(
                  "https://images.unsplash.com/photo-1602810318383-eab2183f14c5?q=80&w=1470&auto=format&fit=crop",
                  height: 300.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12.h,
                left: 12.w,
                child: CircleAvatar(
                  backgroundColor: AllColor.white,
                  child: Icon(Icons.arrow_back, color: AllColor.black),
                ),
              ),
            ],
          ),

          // Product Details
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "\$15.00",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AllColor.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Everyday Elegance in Women’s Fashion",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AllColor.black,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Discover a curated collection of stylish and fashionable women's dresses designed for every mood and moment. From elegant evenings to everyday charm — dress to express.",
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.4,
                      color: AllColor.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
  }
}
