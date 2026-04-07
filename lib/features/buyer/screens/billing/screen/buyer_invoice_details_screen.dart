import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/buyer/screens/billing/data/invoice_details_data.dart';
import 'package:market_jango/features/buyer/screens/billing/model/invoice_details_model.dart';
import 'package:market_jango/features/buyer/screens/billing/util/invoice_receipt_pdf.dart';
import 'package:printing/printing.dart';

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
                        padding: EdgeInsets.only(bottom: 28.h),
                        child: _InvoiceWireframeCard(
                          ref: ref,
                          details: details,
                          invoiceId: invoiceId,
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

/// Polished invoice: tinted meta block, vendor cards, table, fee panel, footer.
class _InvoiceWireframeCard extends StatelessWidget {
  const _InvoiceWireframeCard({
    required this.ref,
    required this.details,
    required this.invoiceId,
  });

  final WidgetRef ref;
  final InvoiceDetails details;
  final int invoiceId;

  static List<MapEntry<int, List<InvoiceItemDetail>>> _groupByVendor(
    List<InvoiceItemDetail> items,
  ) {
    final map = <int, List<InvoiceItemDetail>>{};
    for (final i in items) {
      map.putIfAbsent(i.vendorId, () => []).add(i);
    }
    final keys = map.keys.toList()..sort();
    return keys.map((k) => MapEntry(k, map[k]!)).toList();
  }

  String get _currency => details.currency ?? 'USD';

  Color get _accent => AllColor.loginButtomColor;

  String _orderNumberDisplay() {
    final ord = details.orderNumber?.trim();
    if (ord != null && ord.isNotEmpty) return ord;
    final t = details.taxRef?.trim();
    if (t != null && t.isNotEmpty) return t;
    return '#$invoiceId';
  }

  /// Invoice-level delivery, else sum of line `delivery_charge` (matches API shape you shared).
  String? _effectiveDeliveryChargeRaw() {
    final root = details.deliveryCharge?.trim();
    if (root != null && root.isNotEmpty) return root;
    double sum = 0;
    var any = false;
    for (final item in details.items) {
      final s = item.lineDeliveryCharge?.trim();
      if (s == null || s.isEmpty) continue;
      final v = double.tryParse(s);
      if (v != null) {
        sum += v;
        any = true;
      }
    }
    if (!any) return null;
    return sum.toStringAsFixed(2);
  }

  String _vendorBlockTitle(
    WidgetRef ref,
    int vendorIndex,
    int totalVendors,
    String businessLabel,
  ) {
    if (totalVendors <= 1) return businessLabel;
    final letter = String.fromCharCode(65 + vendorIndex);
    final slot = ref.t(BKeys.invoiceVendorBlock, fallback: 'Vendor');
    return '$slot $letter · $businessLabel';
  }

  String _moneyOrDash(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '—';
    return raw.trim();
  }

  String _summaryAmount(String? raw) {
    final v = _moneyOrDash(raw);
    if (v == '—') return v;
    return '$_currency $v';
  }

  Widget _metaRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AllColor.grey500,
                height: 1.25,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AllColor.black,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByVendor(details.items);
    final customerLine =
        details.cusName != null && details.cusName!.trim().isNotEmpty
            ? details.cusName!.trim()
            : '—';

    final headerStyle = TextStyle(
      fontSize: 11.sp,
      fontWeight: FontWeight.w700,
      color: AllColor.black54,
      letterSpacing: 0.2,
    );
    final cellStyle = TextStyle(
      fontSize: 13.sp,
      color: AllColor.black,
      height: 1.3,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 18.h),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AllColor.grey200.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AllColor.orange50.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AllColor.orange200.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _metaRow(
                  ref.t(BKeys.customer, fallback: 'Customer'),
                  customerLine,
                ),
                _metaRow(
                  ref.t(BKeys.orderNumber, fallback: 'Order Number'),
                  _orderNumberDisplay(),
                  isLast: true,
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            ref.t(BKeys.items, fallback: 'Items'),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AllColor.black,
            ),
          ),
          SizedBox(height: 10.h),
          ...List.generate(grouped.length, (vendorIndex) {
            final entry = grouped[vendorIndex];
            final vendorId = entry.key;
            final lines = entry.value;
            final vendorName = lines.first.vendor?.businessName?.trim();
            final vLabel = (vendorName != null && vendorName.isNotEmpty)
                ? vendorName
                : '${ref.t(BKeys.vendorLabel)}$vendorId';
            final sectionTitle = _vendorBlockTitle(
              ref,
              vendorIndex,
              grouped.length,
              vLabel,
            );

            return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: AllColor.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AllColor.grey200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 11.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AllColor.orange50.withValues(alpha: 0.9),
                            AllColor.white,
                          ],
                        ),
                        border: Border(
                          bottom: BorderSide(color: AllColor.grey200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            size: 20.sp,
                            color: _accent,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              sectionTitle,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: AllColor.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      color: AllColor.grey100,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              ref.t(BKeys.productName, fallback: 'Product name'),
                              style: headerStyle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ref.t(
                                BKeys.numberOfProducts,
                                fallback: 'Number of products',
                              ),
                              style: headerStyle,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ref.t(BKeys.cost, fallback: 'Cost'),
                              style: headerStyle,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...lines.asMap().entries.map((e) {
                      final item = e.value;
                      final isLast = e.key == lines.length - 1;
                      final product = item.product;
                      final name = product?.name.isNotEmpty == true
                          ? product!.name
                          : '${ref.t(BKeys.productLabel)}${item.productId}';
                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    name,
                                    style: cellStyle,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${item.quantity}',
                                    style: cellStyle.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item.totalPay,
                                    style: cellStyle.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: _accent,
                                      fontSize: 14.sp,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              indent: 12.w,
                              endIndent: 12.w,
                              color: AllColor.grey200,
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              );
          }),
          SizedBox(height: 6.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
            decoration: BoxDecoration(
              color: AllColor.grey100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AllColor.grey200),
            ),
            child: Column(
              children: [
                _feeLine(
                  ref.t(BKeys.deliveryCharge, fallback: 'Delivery charge'),
                  _summaryAmount(_effectiveDeliveryChargeRaw()),
                ),
                SizedBox(height: 8.h),
                _feeLine(
                  ref.t(BKeys.tax, fallback: 'Tax'),
                  _summaryAmount(details.vat),
                ),
                SizedBox(height: 8.h),
                _feeLine(
                  ref.t(BKeys.platformFees, fallback: 'Platform fees'),
                  _summaryAmount(details.platformFee),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Divider(height: 1, color: AllColor.grey300),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 12.h, 0, 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        ref.t(BKeys.totalFees, fallback: 'Total fees'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AllColor.black,
                        ),
                      ),
                      Text(
                        '$_currency ${details.payable}',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                          color: AllColor.black,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(top: 14.h),
            child: Divider(height: 1, color: AllColor.grey200),
          ),
          Padding(
            padding: EdgeInsets.only(top: 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AllColor.grey100,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AllColor.grey200),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 32.h,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'Market Jango',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AllColor.grey500,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _shareInvoiceReceiptPdf(context, ref),
                  icon: Icon(
                    Icons.download_rounded,
                    size: 20.sp,
                    color: _accent,
                  ),
                  label: Text(
                    ref.t(BKeys.download, fallback: 'Download'),
                    style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: _accent,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeLine(String label, String value) {
    final isDash = value == '—';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: AllColor.grey500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDash ? AllColor.grey300 : AllColor.black,
          ),
        ),
      ],
    );
  }

  Future<void> _shareInvoiceReceiptPdf(BuildContext context, WidgetRef ref) async {
    final labels = InvoiceReceiptPdfLabels(
      invoiceTitle: '${ref.t(BKeys.invoiceDetails)} #$invoiceId',
      customerLabel: ref.t(BKeys.customer, fallback: 'Customer'),
      customerValue: details.cusName ?? '—',
      orderNumberLabel: ref.t(BKeys.orderNumber, fallback: 'Order Number'),
      itemsTitle: ref.t(BKeys.items, fallback: 'Items'),
      productNameColumn: ref.t(BKeys.productName, fallback: 'Product name'),
      numberOfProductsColumn:
          ref.t(BKeys.numberOfProducts, fallback: 'Number of products'),
      costColumn: ref.t(BKeys.cost, fallback: 'Cost'),
      deliveryLabel: ref.t(BKeys.deliveryCharge, fallback: 'Delivery charge'),
      taxLabel: ref.t(BKeys.tax, fallback: 'Tax'),
      platformFeesLabel: ref.t(BKeys.platformFees, fallback: 'Platform fees'),
      totalFeesLabel: ref.t(BKeys.totalFees, fallback: 'Total fees'),
      vendorSlotWord: ref.t(BKeys.invoiceVendorBlock, fallback: 'Vendor'),
      vendorIdPrefix: ref.t(BKeys.vendorLabel),
      productFallbackPrefix: ref.t(BKeys.productLabel),
    );

    final nav = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AllColor.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
    );

    var dialogClosed = false;
    try {
      final bytes = await buildInvoiceReceiptPdfBytes(
        details: details,
        labels: labels,
        orderNumberValue: _orderNumberDisplay(),
        deliveryValue: _summaryAmount(_effectiveDeliveryChargeRaw()),
        taxValue: _summaryAmount(details.vat),
        platformValue: _summaryAmount(details.platformFee),
        totalValue: '$_currency ${details.payable}',
      );
      if (context.mounted) {
        nav.pop();
        dialogClosed = true;
      }
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'invoice_${invoiceId}_receipt.pdf',
      );
    } catch (e, st) {
      debugPrint('Invoice PDF: $e\n$st');
      if (context.mounted && !dialogClosed) {
        nav.pop();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            content: Text(ref.t(BKeys.errorOccurred)),
          ),
        );
      }
    }
  }
}
