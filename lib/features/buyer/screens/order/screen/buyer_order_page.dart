import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/screen/profile_screen/data/profile_data.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/features/buyer/screens/billing/screen/buyer_invoice_details_screen.dart';
import 'package:market_jango/features/buyer/screens/order/data/buyer_orders_data.dart';
import 'package:market_jango/features/buyer/screens/order/model/order_summary.dart';
import 'package:market_jango/features/buyer/screens/order/widget/custom_buyer_order_upper_image.dart';

import '../../../../../core/localization/tr.dart';

class BuyerOrderPage extends ConsumerStatefulWidget {
  const BuyerOrderPage({super.key});
  static const routeName = "/buyerOrderPage";

  @override
  ConsumerState<BuyerOrderPage> createState() => _BuyerOrderPageState();
}

class _BuyerOrderPageState extends ConsumerState<BuyerOrderPage> {
  String? _userId;
  /// 0 = To receive (not completed), 1 = All orders
  int _orderFilterTab = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final authStorage = AuthLocalStorage();
    final stored = await authStorage.getUserId();
    if (!mounted) return;
    setState(() {
      _userId = stored;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(buyerOrdersProvider);

    final userAsync = (_userId == null)
        ? const AsyncValue.loading()
        : ref.watch(userProvider(_userId!));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            children: [
              Tuppertextandbackbutton(screenName: ref.t(BKeys.myOrders)),
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
                loading: () => const Center(child: Text('Loading...')),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _OrderFilterChip(
                      label: 'To receive',
                      selected: _orderFilterTab == 0,
                      onTap: () => setState(() => _orderFilterTab = 0),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _OrderFilterChip(
                      label: 'All orders',
                      selected: _orderFilterTab == 1,
                      onTap: () => setState(() => _orderFilterTab = 1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              /// Orders list (grouped by day; tap → invoice / order details)
              Expanded(
                child: ordersAsync.when(
                  data: (page) {
                    final all = page?.orders ?? const <Order>[];
                    final filtered = _orderFilterTab == 0
                        ? all.where((o) => !o.isCompleted).toList()
                        : all;
                    return CusotomShowOrder(
                      orders: filtered,
                      groupByDate: true,
                      onOrderTap: (ctx, order) {
                        ctx.push(
                          BuyerInvoiceDetailsScreen.routeName,
                          extra: BuyerInvoiceDetailsArgs(
                            order.invoiceId,
                            fromMyOrders: true,
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: Text('Loading...')),
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
    this.groupByDate = false,
    this.onOrderTap,
  });

  final List<Order> orders;
  final bool scrollable;
  final bool groupByDate;
  final void Function(BuildContext context, Order order)? onOrderTap;

  static DateTime _dayOnly(DateTime? d) {
    if (d == null) return DateTime(1970);
    final l = d.toLocal();
    return DateTime(l.year, l.month, l.day);
  }

  static String _dayHeader(DateTime day) {
    if (day.year == 1970) return 'Date unknown';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return 'Today';
    final y = today.subtract(const Duration(days: 1));
    if (day == DateTime(y.year, y.month, y.day)) return 'Yesterday';
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${day.day} / ${months[day.month - 1]} / ${day.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'No orders yet.',
          style: TextStyle(fontSize: 14.sp, color: AllColor.grey),
        ),
      );
    }

    if (!groupByDate) {
      return ListView.separated(
        itemCount: orders.length,
        padding: EdgeInsets.zero,
        physics: scrollable
            ? const BouncingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        shrinkWrap: !scrollable,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, i) => _OrderCard(
          order: orders[i],
          onTap: onOrderTap == null
              ? null
              : () => onOrderTap!(context, orders[i]),
        ),
      );
    }

    final sorted = List<Order>.from(orders)
      ..sort(
        (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
          a.createdAt ?? DateTime(0),
        ),
      );

    final children = <Widget>[];
    DateTime? lastDay;
    for (final o in sorted) {
      final day = _dayOnly(o.createdAt);
      if (lastDay == null || day != lastDay) {
        lastDay = day;
        if (children.isNotEmpty) {
          children.add(SizedBox(height: 6.h));
        }
        children.add(_DateSectionHeader(title: _dayHeader(day)));
        children.add(SizedBox(height: 8.h));
      }
      children.add(
        _OrderCard(
          order: o,
          onTap: onOrderTap == null ? null : () => onOrderTap!(context, o),
        ),
      );
      children.add(SizedBox(height: 10.h));
    }

    return ListView(
      padding: EdgeInsets.zero,
      physics: scrollable
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: !scrollable,
      children: children,
    );
  }
}

class _DateSectionHeader extends StatelessWidget {
  const _DateSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: AllColor.grey500,
      ),
    );
  }
}

class _OrderFilterChip extends StatelessWidget {
  const _OrderFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final orange = AllColor.loginButtomColor;
    return Material(
      color: selected ? orange.withValues(alpha: 0.12) : AllColor.grey100,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: selected ? orange : AllColor.grey200,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: selected ? orange : AllColor.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, this.onTap});
  final Order order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = order.product.image;

    final address = order.shipAddress?.isNotEmpty == true
        ? order.shipAddress!
        : (order.pickupAddress ?? '');

    final card = Container(
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
              paymentLabel: order.paymentLabel,
            ),
          ),
          if (onTap != null) ...[
            SizedBox(width: 4.w),
            Icon(Icons.chevron_right, color: AllColor.grey500, size: 22.sp),
          ],
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(5.r),
        onTap: onTap,
        child: card,
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
          Flexible(
            child: Text(
              status,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AllColor.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (paymentLabel.isNotEmpty) SizedBox(width: 8.w),
          if (paymentLabel.isNotEmpty)
            Flexible(
              child: Container(
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          ? FirstTimeShimmerImage(
              imageUrl: url,
              fit: BoxFit.cover,
            )
          : Container(color: AllColor.grey.withOpacity(0.10)),
    );
  }
}
