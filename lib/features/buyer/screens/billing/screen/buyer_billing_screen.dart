import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/buyer/screens/billing/screen/buyer_invoice_details_screen.dart';
import 'package:market_jango/features/buyer/screens/order/data/buyer_orders_data.dart';
import 'package:market_jango/features/buyer/screens/order/model/order_summary.dart';

class BuyerBillingScreen extends ConsumerWidget {
  const BuyerBillingScreen({super.key});
  static const routeName = '/buyer_billing';

  /// Group orders by invoice_id; return list of (invoiceId, first Order for that invoice)
  static List<({int invoiceId, Order order})> _groupByInvoice(
    List<Order> orders,
  ) {
    final byInvoice = <int, Order>{};
    for (final o in orders) {
      byInvoice.putIfAbsent(o.invoiceId, () => o);
    }
    final list = byInvoice.entries
        .map((e) => (invoiceId: e.key, order: e.value))
        .toList();
    list.sort((a, b) {
      final da = a.order.createdAt ?? DateTime(0);
      final db = b.order.createdAt ?? DateTime(0);
      return db.compareTo(da);
    });
    return list;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(buyerOrdersProvider);

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                Tuppertextandbackbutton(
                  screenName: ref.t(BKeys.billing),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: ordersAsync.when(
                    data: (page) {
                      final orders = page?.orders ?? const <Order>[];
                      final invoiceList = _groupByInvoice(orders)
                          .where((e) => _isPaid(e.order))
                          .toList();
                      if (invoiceList.isEmpty) {
                        return Center(
                          child: Text(
                            ref.t(BKeys.noInvoicesYet),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AllColor.grey,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: invoiceList.length,
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (_, i) {
                          final entry = invoiceList[i];
                          final inv = entry.order.invoice;
                          final dateStr = _formatDate(entry.order.createdAt);
                          return _InvoiceCard(
                            invoiceTitle:
                                '${ref.t(BKeys.invoiceLabel)}${entry.invoiceId}',
                            date: dateStr,
                            total: inv.payable,
                            currency: inv.currency,
                            status: inv.status ?? entry.order.status,
                            paymentMethod: inv.paymentMethod,
                            onTap: () => context.push(
                              BuyerInvoiceDetailsScreen.routeName,
                              extra: entry.invoiceId,
                            ),
                          );
                        },
                      );
                    },
                    loading: () => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          SizedBox(height: 12.h),
                          Text(
                            ref.t(BKeys.loading),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AllColor.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          ref.t(BKeys.errorOccurred),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AllColor.red,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime? d) {
    if (d == null) return '';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Only show invoices that are paid (FW = payment successful).
  static bool _isPaid(Order order) {
    final method = (order.invoice.paymentMethod ?? '').toUpperCase();
    if (method == 'FW') return true;
    final status = (order.invoice.status ?? '').toLowerCase();
    return status == 'paid' || status == 'successful';
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({
    required this.invoiceTitle,
    required this.date,
    required this.total,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    required this.onTap,
  });

  final String invoiceTitle;
  final String date;
  final double total;
  final String currency;
  final String? status;
  final String? paymentMethod;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AllColor.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AllColor.orange50,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: AllColor.orange,
                  size: 26.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoiceTitle,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AllColor.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AllColor.grey,
                      ),
                    ),
                    if (status != null && status!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        status!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AllColor.orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$currency ${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AllColor.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Icon(
                    Icons.chevron_right,
                    color: AllColor.grey,
                    size: 22.sp,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
