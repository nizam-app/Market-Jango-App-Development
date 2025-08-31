import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/features/buyer/screens/order/widget/custom_buyer_order_upper_image.dart';

// ✅ use the ONE true model
import 'package:market_jango/features/buyer/screens/order/model/order_summary.dart' as m;
import 'data/orders_data.dart'; // contains List<OrderSummary> from the same model

class BuyerOrderPage extends StatelessWidget {
  const BuyerOrderPage({super.key});
  static const routeName = "/buyerOrderPage";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            children: [
              Tuppertextandbackbutton(screenName: "My Order"),
              SizedBox(height: 12.h),
              CustomBuyerOrderUpperImage(
                imageUrl:
                "https://images.unsplash.com/photo-1517841905240-472988babdf9",
                onTap: () {},
              ),
              SizedBox(height: 16.h),
              // 🔽 ListView must be inside Expanded to scroll
              Expanded(child: CusotomShowOrder(orders: ordersData)),
            ],
          ),
        ),
      ),
    );
  }
}

/* ========= LIST ========= */
class CusotomShowOrder extends StatelessWidget {
  const CusotomShowOrder({
    super.key,
    required this.orders,
    this.scrollable = true,
  });

  final List<m.OrderSummary> orders; // ✅ model alias
  final bool scrollable;

  @override
  Widget build(BuildContext context) => ListView.separated(
    itemCount: orders.length,
    padding: EdgeInsets.zero,
    physics: scrollable
        ? const BouncingScrollPhysics()
        : const NeverScrollableScrollPhysics(),
    shrinkWrap: !scrollable,
    separatorBuilder: (_, __) => SizedBox(height: 10.h),
    itemBuilder: (_, i) => _OrderCard(o: orders[i]),
  );
}
class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.o});
  final m.OrderSummary o; // ✅ model alias

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          color: AllColor.white,
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: [
            BoxShadow(
              color: AllColor.black.withOpacity(0.06),
              blurRadius: 14,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Collage(o.imageUrls),
            SizedBox(width: 14.w),
            Expanded(child: _Texts(o)),
            _Track(onTap: o.onTrack),
          ],
        ),
      ),
      
    ]);
  }
}

/* ========= PARTS ========= */
class _Texts extends StatelessWidget {
  const _Texts(this.o);
  final m.OrderSummary o;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Order ${o.orderId}",
          style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: AllColor.black)),
      SizedBox(height: 4.h),
      Text(o.deliveryType,
          style: TextStyle(fontSize: 12.sp, color: AllColor.grey)),
      SizedBox(height: 10.h),
      Text(o.status,
          style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: AllColor.black)),
    ],
  );
}

class _Track extends StatelessWidget {
  const _Track({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Badge("items"),
      SizedBox(height: 15.h,),
        InkWell(
          borderRadius: BorderRadius.circular(22.r),
          onTap: onTap,
          child: Container(
            width: 88.w,
            height: 36.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AllColor.orange, AllColor.orange500], // AllColor only
              ),
              borderRadius: BorderRadius.circular(22.r),
              boxShadow: [
                BoxShadow(
                  color: AllColor.orange.withOpacity(0.35),
                  blurRadius: 12,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Text(
              "Track",
              style: TextStyle(
                color: AllColor.white,
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: AllColor.grey.withOpacity(0.16),
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: Text(text,
        style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AllColor.black)),
  );
}

class _Collage extends StatelessWidget {
  const _Collage(this.urls);
  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final imgs = urls.take(4).toList();
    final side = 100.w;
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(0.5.r),
        boxShadow: [
          BoxShadow(
            color: AllColor.black.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(6.r),
        mainAxisSpacing: 2.w,
        crossAxisSpacing: 2.w,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(4, (i) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: (i < imgs.length)
                ? Image.network(imgs[i], fit: BoxFit.cover)
                : Container(color: AllColor.grey.withOpacity(0.10)),
          );
        }),
      ),
    );
  }
}