import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';

class VendorTransportDetails extends StatelessWidget {
  const VendorTransportDetails({
    super.key,
    this.imageUrl =
        'https://images.unsplash.com/photo-1570158268183-d296b2892211?w=1200',
    this.address = 'australia, road 19 house 1',
    this.price = 17.00,
    this.description =
        'Discover a curated collection of stylish and fashionable women’s dresses designed for every mood and moment. From elegant evenings to everyday charm — dress to express.',
  });

  static const routeName = "/vendorTransportDetails";

  final String imageUrl;
  final String address;
  final double price;
  final String description;

  @override
  Widget build(BuildContext context) {
    final priceText = '\$${price.toStringAsFixed(2).replaceAll('.', ',')}';

    return Scaffold(
      backgroundColor: AllColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- Header image with circular back button overlay ---
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 3 / 2,
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: Material(
                    color: Colors.white.withOpacity(.9),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.chevron_left_rounded, size: 24),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- Details block (address, price, description) ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AllColor.white,
                  border: Border(top: BorderSide(color: AllColor.grey200)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(address,
                          style: TextStyle(
                            color: AllColor.black54,
                            fontWeight: FontWeight.w600,
                          )),
                       SizedBox(height: 10.h),
                      Text(
                        priceText,
                        style: TextStyle(
                          color: AllColor.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 24.sp,
                        ),
                      ),
                       SizedBox(height: 12.sp),
                      Text(
                        description,
                        style: TextStyle(
                          color: AllColor.black87,
                          height: 1.45.h,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Bottom actions (chat + Pay Now) + grabber ---
            Container(
              color: AllColor.white,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 10,
                bottom: 12 + MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
                  // Chat square
                  SizedBox(
                    height: 44.h,
                    width: 44.w,
                    child: Material(
                      color: AllColor.blue500,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Chat tapped'))),
                        child: Icon(Icons.chat,
                            color: AllColor.white, size: 20.sp),
                      ),
                    ),
                  ),
                   SizedBox(width: 12.w),
                  // Pay Now button
                  Expanded(
                    child: SizedBox(
                      height: 44.h,
                      child: ElevatedButton(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Pay Now tapped'))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AllColor.loginButtomColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Pay Now',
                            style: TextStyle(
                                color: AllColor.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
