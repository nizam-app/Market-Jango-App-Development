import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/buyer/screens/billing/data/invoice_details_data.dart';
import 'package:market_jango/features/buyer/screens/billing/model/invoice_details_model.dart';

class BuyerInvoiceDetailsScreen extends ConsumerWidget {
  const BuyerInvoiceDetailsScreen({super.key, required this.invoiceId});
  static const routeName = '/buyer_invoice_details';

  final int invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(invoiceDetailsProvider(invoiceId));

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tuppertextandbackbutton(
                  screenName: '${ref.t(BKeys.invoiceDetails)} #$invoiceId',
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: detailsAsync.when(
                    data: (details) {
                      if (details == null) {
                        return Center(
                          child: Text(
                            ref.t(BKeys.invoiceNotFound),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AllColor.grey,
                            ),
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InvoiceHeader(ref: ref, details: details),
                            SizedBox(height: 20.h),
                            Text(
                              ref.t(BKeys.items),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AllColor.black,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            ...details.items.map(
                              (item) => Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: _InvoiceItemTile(ref: ref, item: item),
                              ),
                            ),
                          ],
                        ),
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
}

class _InvoiceHeader extends StatelessWidget {
  const _InvoiceHeader({
    required this.ref,
    required this.details,
  });
  final WidgetRef ref;
  final InvoiceDetails details;

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(details.createdAt);
    final paymentLabel = _paymentLabel(ref, details.paymentMethod);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(ref.t(BKeys.total), '${details.currency ?? 'USD'} ${details.total}'),
          SizedBox(height: 8.h),
          _row(ref.t(BKeys.payable), '${details.currency ?? 'USD'} ${details.payable}'),
          SizedBox(height: 8.h),
          _row(ref.t(BKeys.date), dateStr),
          if (details.cusName != null && details.cusName!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _row(ref.t(BKeys.customer), details.cusName!),
          ],
          if (paymentLabel != null && paymentLabel.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _row(ref.t(BKeys.payment), paymentLabel),
          ],
          if (details.status != null && details.status!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _row(ref.t(BKeys.status), details.status!),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: AllColor.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AllColor.black,
            ),
          ),
        ],
      );

  static String _formatDate(DateTime? d) {
    if (d == null) return '';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  static String? _paymentLabel(WidgetRef ref, String? method) {
    if (method == null || method.isEmpty) return null;
    final m = method.toUpperCase();
    if (m == 'FW') return ref.t(BKeys.paymentSuccessful);
    if (m == 'OPU') return ref.t(BKeys.cashOnDelivery);
    return method;
  }
}

class _InvoiceItemTile extends StatelessWidget {
  const _InvoiceItemTile({required this.ref, required this.item});
  final WidgetRef ref;
  final InvoiceItemDetail item;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final vendor = item.vendor;
    final imageUrl = product?.image ?? '';
    final name = product?.name ??
        '${ref.t(BKeys.productLabel)}${item.productId}';
    final vendorName = vendor?.businessName ??
        '${ref.t(BKeys.vendorLabel)}${item.vendorId}';

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: FirstTimeShimmerImage(
              imageUrl: imageUrl,
              width: 72.w,
              height: 72.w,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AllColor.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${ref.t(BKeys.qty)} ${item.quantity}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AllColor.grey,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  vendorName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AllColor.grey500,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '${item.totalPay}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AllColor.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
