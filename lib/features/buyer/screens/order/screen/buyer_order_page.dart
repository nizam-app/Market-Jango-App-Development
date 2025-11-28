import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/screen/profile_screen/data/profile_data.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/features/buyer/screens/order/data/buyer_orders_data.dart';
import 'package:market_jango/features/buyer/screens/order/model/order_summary.dart';
import 'package:market_jango/features/buyer/screens/order/widget/custom_buyer_order_upper_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuyerOrderPage extends ConsumerStatefulWidget {
  const BuyerOrderPage({super.key});
  static const routeName = "/buyerOrderPage";

  @override
  ConsumerState<BuyerOrderPage> createState() => _BuyerOrderPageState();
}

class _BuyerOrderPageState extends ConsumerState<BuyerOrderPage> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final pref = await SharedPreferences.getInstance();
    final stored = pref.getString("user_id");
    if (!mounted) return;
    setState(() {
      _userId = stored;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(buyerOrdersProvider);
    final notifier = ref.read(buyerOrdersProvider.notifier);

    final userAsync = (_userId == null)
        ? const AsyncValue.loading()
        : ref.watch(userProvider(_userId!));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            children: [
              Tuppertextandbackbutton(screenName: "My Order"),
              SizedBox(height: 12.h),

              /// Top user image
              userAsync.when(
                data: (data) {
                  final image = data.image;
                  return CustomBuyerOrderUpperImage(
                    imageUrl: image,
                    onTap: () {},
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
              SizedBox(height: 16.h),

              /// Orders list
              Expanded(
                child: ordersAsync.when(
                  data: (page) =>
                      CusotomShowOrder(orders: page?.orders ?? const <Order>[]),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(e.toString())),
                ),
              ),

              /// Pagination
              // ordersAsync.when(
              //   data: (page) => GlobalPagination(
              //     currentPage: page?.currentPage ?? 1,
              //     totalPages: page?.lastPage ?? 1,
              //     onPageChanged: notifier.changePage,
              //   ),
              //   loading: () => GlobalPagination(
              //     currentPage: 1,
              //     totalPages: 1,
              //     onPageChanged: (_) {},
              //   ),
              //   error: (e, _) => GlobalPagination(
              //     currentPage: 1,
              //     totalPages: 1,
              //     onPageChanged: (_) {},
              //   ),
              // ),
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

  final List<Order> orders;
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
    itemBuilder: (_, i) => _OrderCard(order: orders[i]),
  );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final imageUrl = order.product.image;

    final address = order.shipAddress?.isNotEmpty == true
        ? order.shipAddress!
        : (order.pickupAddress ?? '');

    return Container(
      padding: EdgeInsets.only(top: 10.h, bottom: 10.h, right: 8.w, left: 8.w),
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
          _ProductImage(imageUrl),
          SizedBox(width: 14.w),
          Expanded(
            child: _Texts(
              orderCode: order.orderCode,
              address: address,
              description: order.statusDescription,
              status: order.effectiveStatus,
              paymentLabel: order.paymentLabel, // 👈 same row e jabe
            ),
          ),
        ],
      ),
    );
  }
}

/* ========= PARTS ========= */

class _Texts extends StatelessWidget {
  const _Texts({
    required this.orderCode,
    required this.address,
    required this.description,
    required this.status,
    required this.paymentLabel,
  });

  final String orderCode;
  final String address;
  final String description;
  final String status;
  final String paymentLabel; // 👈 new

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Order $orderCode",
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          color: AllColor.black,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: 4.h),

      // short description (status wise)
      if (description.isNotEmpty)
        Text(
          description,
          style: TextStyle(fontSize: 12.sp, color: AllColor.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

      SizedBox(height: 4.h),

      // address
      Text(
        address,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12.sp, color: AllColor.grey),
      ),

      SizedBox(height: 10.h),

      // ✅ status + payment same row
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            status,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: AllColor.black,
            ),
          ),
          if (paymentLabel.isNotEmpty) SizedBox(width: 8.w),
          if (paymentLabel.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AllColor.grey.withOpacity(0.16),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                paymentLabel, // "Payment successful" / "Cash on delivery"
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AllColor.black,
                ),
              ),
            ),
        ],
      ),
    ],
  );
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
    decoration: BoxDecoration(
      color: AllColor.grey.withOpacity(0.16),
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AllColor.black,
      ),
    ),
  );
}

class _ProductImage extends StatelessWidget {
  const _ProductImage(this.url);
  final String url;

  @override
  Widget build(BuildContext context) {
    final side = 90.w;
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AllColor.black.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isNotEmpty
          ? Image.network(url, fit: BoxFit.cover)
          : Container(color: AllColor.grey.withOpacity(0.10)),
    );
  }
}
