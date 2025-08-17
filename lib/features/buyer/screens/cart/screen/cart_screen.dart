import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/%20business_logic/models/cart_model.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/buyer/screens/cart/data/cart_data.dart';
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
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            _buildShippingAddress(context),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView.builder(
                itemCount: dummyCartItems.length,
                itemBuilder: (context, index) {
                  return _buildCartItemCard(dummyCartItems[index]);
                },
              ),
            ),
            _buildTotalCheckoutSection(totalPrice),
          ],
        ),
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

  Widget _buildCartItemCard(CartItemModel item) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AllColor.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AllColor.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.topLeft,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    item.imageUrl,
                    width: 80.w,
                    height: 80.w, // Typically square for product images
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80.w,
                        height: 80.w,
                        color: AllColor.grey,
                        child: Icon(
                            Icons.broken_image, color: AllColor.grey,
                            size: 40.sp),
                      );
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(4.r),
                  padding: EdgeInsets.all(4.r),
                  decoration:  BoxDecoration(
                    color: AllColor.white, // Using AllColor
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: AllColor.white, // Using AllColor
                    size: 16.sp,
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AllColor.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.details,
                    style: TextStyle(color: AllColor.grey, fontSize: 12.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: AllColor.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            _buildQuantityControl(item.quantity),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl(int quantity) {
    return Row(
      children: [
        _quantityButton(Icons.remove, () {
          // TODO: Implement decrement quantity logic
          print("Decrement");
        }),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            quantity.toString(),
            style: TextStyle(fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AllColor.black),
          ),
        ),
        _quantityButton(Icons.add, () {
          // TODO: Implement increment quantity logic
          print("Increment");
        }),
      ],
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

  Widget _buildTotalCheckoutSection(double totalPrice) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AllColor.white,
        boxShadow: [
          BoxShadow(
            color: AllColor.black.withOpacity(0.2),
            // Slightly more prominent shadow for bottom bar
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  color: AllColor.grey,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                  color: AllColor.black,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement checkout logic
              print("Checkout tapped");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AllColor.black, // Using AllColor
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              textStyle: TextStyle(
                  fontSize: 16.sp, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: Text('Checkout',
                style: TextStyle(color: AllColor.white, fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }
}