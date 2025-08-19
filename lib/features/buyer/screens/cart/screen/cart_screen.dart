import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/%20business_logic/models/cart_model.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/buyer/screens/cart/data/cart_data.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  static const String routeName = '/cartScreen';

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<CartItemModel> items;

  @override
  void initState() {
    super.initState();
    items = List<CartItemModel>.from(dummyCartItems);
  }

  double get totalPrice {
    double t = 0;
    for (final i in items) {
      t += i.price * i.quantity;
    }
    return t;
  }

  // ---- money formatter: "17,00"
  String _formatMoney(double v) {
    final s = v.toStringAsFixed(2);
    return '\$${s.replaceAll('.', ',')}';
  }

  void _inc(int index) => setState(() {
    items[index].quantity++;
  });

  void _dec(int index) => setState(() {
    if (items[index].quantity > 1) items[index].quantity--;
  });

  void _remove(int index) => setState(() => items.removeAt(index));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCartAppBar(context, items.length),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 16.h),
            _buildShippingAddressCard(context),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => _buildCartItemCard(items[i], i),
              ),
            ),
            _buildBottomCheckoutBar(),
          ],
        ),
      ),
    );
  }

//####################################################################################################################
// Custom Codebase
//####################################################################################################################

  AppBar _buildCartAppBar(BuildContext context, int itemCount) {
    final theme = Theme.of(context).textTheme;
    return AppBar(
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Text('Cart', style: theme.titleLarge!.copyWith(fontSize: 22.sp)),
          SizedBox(width: 10.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AllColor.blue200,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Text(
              itemCount.toString(),
              style: theme.titleMedium!.copyWith(fontSize: 14.sp, color: AllColor.black),
            ),
          ),
        ],
      ),
    );
  }

  // ===== top shipping card =====
  Widget _buildShippingAddressCard(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AllColor.grey100,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(color: AllColor.grey.withOpacity(0.15), blurRadius: 8, offset: Offset(0, 2.h)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Shipping Address', style: theme.titleMedium!.copyWith(fontSize: 14.sp, color: AllColor.black)),
              SizedBox(height: 4.h),
              Text(
                '26, Duong So 2, Thao Dien Ward, An Phu, District 2, Ho Chi Minh city',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.sp, color: AllColor.black),
              ),
            ]),
          ),
          SizedBox(width: 10.w),
          Container(
            height: 28.w,
            width: 28.w,
            decoration: BoxDecoration(color: AllColor.orange, shape: BoxShape.circle),
            child: Icon(Icons.edit_outlined, size: 16.sp, color: AllColor.white),
          ),
        ],
      ),
    );
  }

  // ===== cart card (Image-2 layout) =====
  Widget _buildCartItemCard(CartItemModel item, int index) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        padding: EdgeInsets.all(2.r),
        decoration: BoxDecoration(
          color: AllColor.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [BoxShadow(color: AllColor.black.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 2.h))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // image + red delete badge (bottom-left)
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    item.imageUrl,
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80.w,
                      height: 80.w,
                      color: AllColor.grey,
                      alignment: Alignment.center,
                      child: Icon(Icons.image_outlined, color: AllColor.white, size: 28.sp),
                    ),
                  ),
                ),
                Positioned(
                  left: -6.w,
                  bottom: -6.w,
                  child: InkWell(
                    onTap: () => _remove(index),
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.35), blurRadius: 6)],
                      ),
                      child: Icon(Icons.delete, size: 16.sp, color: AllColor.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),

            // texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title (2 lines max)
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AllColor.black),
                  ),
                  SizedBox(height: 4.h),
                  // details (bold like Image-2)
                  Text('Pink, Size M',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AllColor.black)),
                  SizedBox(height: 6.h),
                  // price bold
                  Text(
                    _formatMoney(item.price),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AllColor.black),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // qty controls — HORIZONTAL like Image-2
            _buildQuantityControlsRow(
              onDec: () => _dec(index),
              onInc: () => _inc(index),
              qty: item.quantity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControlsRow({required VoidCallback onDec, required VoidCallback onInc, required int qty}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildOutlineCircleButton(icon: Icons.remove, onTap: onDec),
        SizedBox(width: 10.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(color: AllColor.grey100, borderRadius: BorderRadius.circular(8.r)),
          child: Text('$qty', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AllColor.black)),
        ),
        SizedBox(width: 10.w),
        _buildOutlineCircleButton(icon: Icons.add, onTap: onInc),
      ],
    );
  }

  Widget _buildOutlineCircleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32.w,
        height: 32.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AllColor.white,
          border: Border.all(color: AllColor.grey, width: 1.2),
        ),
        child: Icon(icon, size: 18.sp, color: AllColor.black),
      ),
    );
  }

  // ===== bottom total + checkout pill =====
  Widget _buildBottomCheckoutBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AllColor.white,
        boxShadow: [BoxShadow(color: AllColor.black.withOpacity(0.15), blurRadius: 12, offset: Offset(0, -4.h))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Total
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total', style: TextStyle(fontSize: 13.sp, color: AllColor.grey)),
              SizedBox(height: 2.h),
              Text(
                _formatMoney(totalPrice),
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: AllColor.black),
              ),
            ],
          ),
          // Checkout (blue pill)
          SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AllColor.blue200,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                elevation: 0,
              ),
              child: Text('Checkout',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AllColor.white)),
            ),
          ),
        ],
      ),
    );
  }
}