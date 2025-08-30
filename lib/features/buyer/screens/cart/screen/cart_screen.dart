import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/%20business_logic/models/cart_model.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/buyer/screens/cart/data/cart_data.dart';
import 'package:market_jango/core/widget/custom_total_checkout_section.dart';
import 'package:market_jango/features/buyer/screens/prement/screen/buyer_payment_screen.dart';
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const String routeName = '/cartScreen';

  double _calculateTotalPrice(List<CartItemModel> items) {
    double total = 0;
    for (var item in items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final double totalPrice = _calculateTotalPrice(dummyCartItems);
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Text(
              'Cart',
              style:theme.titleLarge!.copyWith(fontSize: 22.sp),
            ),
            SizedBox(width: 20.w), // Using ScreenUtil for width
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              // Using ScreenUtil
              decoration: BoxDecoration(
                color: AllColor.blue200, // Example color from AllColor
                borderRadius: BorderRadius.circular(
                    20.r), // Using ScreenUtil for radius
              ),
              child: Text(
                dummyCartItems.length.toString(),
                style: theme.titleLarge!.copyWith(fontSize: 14.sp),
                ),
              ),

          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20.h),
          Padding(
            padding:  EdgeInsets.all(8.0.r),
            child: _buildShippingAddress(context),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: ListView.builder(
              itemCount: dummyCartItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 15.w),
                  child: _buildCartItemCard(dummyCartItems[index],context),
                );
              },
            ),
          ),
          CustomTotalCheckoutSection(totalPrice: totalPrice, context: context),
        ],
      ),
    );
  }

  Widget _buildShippingAddress(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AllColor.grey100,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: AllColor.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipping Address',
                  style:theme.titleLarge!.copyWith(fontSize: 14.sp) ,
                ),
                SizedBox(height: 4.h),
                Text(
                  '26, Duong So 2, Thao Dien Ward, An Phu, District 2, Ho Chi Minh city',
                  style: TextStyle(color: AllColor.black, fontSize: 11.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Container(
            padding: EdgeInsets.all(8.r),
            decoration:  BoxDecoration(
              color: AllColor.orange, // Using AllColor
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.edit_outlined,
              color: AllColor.white, // Using AllColor
              size: 18.sp,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCartItemCard(CartItemModel item ,BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        decoration: BoxDecoration(
          color: AllColor.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AllColor.black.withOpacity(0.005),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image with Delete Button
            Stack(
              alignment: Alignment.topLeft,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    item.imageUrl,
                    width: 90.w,
                    height: 90.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 90.w,
                        height: 90.h,
                        color: AllColor.grey,
                        child: Icon(Icons.broken_image,
                            color: AllColor.blue, size: 40.sp),
                      );
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(2.r),
                  padding: EdgeInsets.all(5.r),
                  decoration: BoxDecoration(
                    color: AllColor.white, // Red background
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete,
                    color: AllColor.orange,
                    size: 18.sp,
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  Text(
                    item.name,
                    style: theme.titleMedium!.copyWith(color: AllColor.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.details,
                    style: TextStyle(
                        color: AllColor.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold), // Bold details
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${item.price.toStringAsFixed(2).replaceAll('.', ',')}', // 17,00
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: AllColor.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // Quantity Control
            _buildQuantityControl(item.quantity),
            SizedBox(width: 12.w),
          ],
        ),
      ),
    );
  }

// Quantity Control updated to match design
  Widget _buildQuantityControl(int quantity) {
    return Row(
      children: [
        _circleButton(Icons.remove, () {}),
        SizedBox(width: 8.w),
        Text(
          '$quantity',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(width: 8.w),
        _circleButton(Icons.add, () {}),
      ],
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AllColor.black.withOpacity(0.8)),
        ),
        child: Icon(icon, size: 16.sp, color: AllColor.black),
      ),
    );
  }




  Widget _quantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: AllColor.grey,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18.sp, color: AllColor.black),
      ),
    );
  }

}