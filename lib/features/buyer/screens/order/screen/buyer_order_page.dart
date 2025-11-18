import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/screen/global_tracking_screen/screen/global_tracking_screen_1.dart';
import 'package:market_jango/core/screen/profile_screen/data/profile_data.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/global_pagination.dart';
import 'package:market_jango/features/buyer/screens/cart/screen/cart_screen.dart';
import 'package:market_jango/features/buyer/screens/order/data/buyer_orders_data.dart';
import 'package:market_jango/features/buyer/screens/order/model/order_summary.dart';
import 'package:market_jango/features/buyer/screens/order/widget/custom_buyer_order_upper_image.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BuyerOrderPage extends  ConsumerStatefulWidget{
  const BuyerOrderPage({super.key});
  static const routeName = "/buyerOrderPage";

  @override
  ConsumerState<BuyerOrderPage> createState() => _BuyerOrderPageState();
}

class _BuyerOrderPageState extends ConsumerState<BuyerOrderPage> {
  late String userId ;
  Future<void> _loadUserId() async {
    final pref = await SharedPreferences.getInstance();
    final stored = pref.getString("user_id");



    setState(() {
      userId = stored ?? "";          
    });

   
  }
  @override
  void initState() {
    super.initState();
_loadUserId();
  }
  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(buyerOrdersProvider);
    final notifier = ref.read(buyerOrdersProvider.notifier);
    final userAsync = ref.watch(userProvider(userId));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            children: [
              Tuppertextandbackbutton(screenName: "My Order"),
              SizedBox(height: 12.h),
              userAsync.when(
                data: (data) {
                  final image = data.image;
                  return CustomBuyerOrderUpperImage(
                    imageUrl:
                    image,
                    onTap: () {},
                  );
                }  ,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
              SizedBox(height: 16.h),

              Expanded(
                child: ordersAsync.when(
                  data: (page) => CusotomShowOrder(
                    orders: page?.orders ?? const <Order>[],
                  ),
                  loading: () =>
                  const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(e.toString())),
                ),
              ),

              ordersAsync.when(
                data: (page) => GlobalPagination(
                  currentPage: page?.currentPage ?? 1,
                  totalPages: page?.lastPage ?? 1,
                  onPageChanged: notifier.changePage,
                ),
                loading: () =>
                    GlobalPagination(currentPage: 1, totalPages: 1, onPageChanged: (_) {}),
                error: (e, _) =>
                    GlobalPagination(currentPage: 1, totalPages: 1, onPageChanged: (_) {}),
              ),
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

  final List<Order> orders; // ✅ real model
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
    itemBuilder: (_, i) => _OrderCard(oderDetails: orders[i]),
  );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.oderDetails});
  final Order oderDetails;

  @override
  Widget build(BuildContext context) {
    final images = oderDetails.items
        .map((it) => it.product.image)
        .where((s) => s.isNotEmpty)
        .toList();
    final deliveryType = oderDetails.shipCity.isNotEmpty ? oderDetails.shipCity : 'Home Delivery';
    final status = oderDetails.effectiveStatus;

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
            _Collage(images),
            SizedBox(width: 14.w),
            Expanded(child: _Texts(orderId: oderDetails.taxRef, deliveryType: deliveryType, status: status)),
            _Track(onTap: () {
              context.pushNamed(
                GlobalTrackingScreen1.routeName,
                extra:  TrackingArgs(
                  screenName: 'Transport Tracking',
                  invoiceId:  oderDetails.id,
                  
                ),
              );
              oderDetails.itemsCount;
            }),
          ],
        ),
      ),
    ]);
  }
}

/* ========= PARTS ========= */
class _Texts extends StatelessWidget {
  const _Texts({
    required this.orderId,
    required this.deliveryType,
    required this.status,
  });
  final String orderId;
  final String deliveryType;
  final String status;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Order $orderId",
          style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: AllColor.black,
          overflow:TextOverflow.ellipsis)),
      SizedBox(height: 4.h),
      Text(deliveryType, style: TextStyle(fontSize: 12.sp, color: AllColor.grey)),
      SizedBox(height: 10.h),
      Text(status,
          style: TextStyle(
              fontSize: 20.sp, fontWeight: FontWeight.w900, color: AllColor.black)),
    ],
  );
}

class _Track extends StatelessWidget {
  const _Track({this.onTap, this.test});
  final VoidCallback? onTap;
  final String? test;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
       if (test != null)  _Badge(test ??""),
     
        SizedBox(height: 15.h),
        InkWell(
          borderRadius: BorderRadius.circular(22.r),
          onTap: onTap,
          child: Container(
            width: 70.w,
            height: 30.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AllColor.orange, AllColor.orange500],
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
  Widget build(BuildContext context) => InkWell(
    onTap: () {
      context.push(CartScreen.routeName);
    },
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AllColor.grey.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12.sp, fontWeight: FontWeight.w600, color: AllColor.black)),
    ),
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