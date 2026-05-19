import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';

/// Walk-in bill preview after order create — receipt layout + print / copy actions.
class VendorWalkInBillPreviewDialog extends StatelessWidget {
  const VendorWalkInBillPreviewDialog({
    super.key,
    required this.invoice,
    required this.billText,
    required this.onPrint,
    required this.onCopy,
    required this.onClose,
  });

  final VendorManualOrderInvoice invoice;
  final String billText;
  final VoidCallback onPrint;
  final VoidCallback onCopy;
  final VoidCallback onClose;

  static Future<void> show(
    BuildContext context, {
    required VendorManualOrderInvoice invoice,
    required String billText,
    required VoidCallback onPrint,
    required VoidCallback onCopy,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => VendorWalkInBillPreviewDialog(
        invoice: invoice,
        billText: billText,
        onPrint: () {
          Navigator.pop(ctx);
          onPrint();
        },
        onCopy: () {
          onCopy();
          Navigator.pop(ctx);
        },
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inv = invoice;
    final orange = AllColor.loginButtomColor;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.82),
        decoration: BoxDecoration(
          color: AllColor.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(onClose: onClose),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SuccessBanner(orderNumber: inv.orderNumber),
                    SizedBox(height: 16.h),
                    _ReceiptCard(invoice: inv),
                  ],
                ),
              ),
            ),
            _Actions(
              onPrint: onPrint,
              onCopy: onCopy,
              onClose: onClose,
              accent: orange,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 8.w, 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AllColor.orange50.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: AllColor.loginButtomColor,
              size: 26.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order created',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AllColor.black,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Preview your bill before printing',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AllColor.grey500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close_rounded, color: AllColor.grey500, size: 22.sp),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3F4F6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.orderNumber});

  final String orderNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF6EE7B7).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: const Color(0xFF059669), size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Walk-in order saved',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF065F46),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  orderNumber.isEmpty ? '—' : orderNumber,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF047857),
                    fontFamily: 'monospace',
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

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.invoice});

  final VendorManualOrderInvoice invoice;

  @override
  Widget build(BuildContext context) {
    final inv = invoice;
    final paid = inv.summary.customerPaid?.trim();
    final change = inv.summary.change?.trim();
    final hasPaid = paid != null && paid.isNotEmpty && paid != '—';
    final hasChange = change != null && change.isNotEmpty && change != '—';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AllColor.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
            child: Column(
              children: [
                Text(
                  'MARKET JANGO',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AllColor.grey500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'WALK-IN RECEIPT',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AllColor.black,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AllColor.grey200),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                _ReceiptRow(
                  label: 'Customer',
                  value: inv.customerName?.trim().isNotEmpty == true
                      ? inv.customerName!.trim()
                      : '—',
                ),
                SizedBox(height: 8.h),
                _ReceiptRow(
                  label: 'Payment',
                  value: inv.paymentMethod?.trim().isNotEmpty == true
                      ? inv.paymentMethod!.trim()
                      : '—',
                ),
                if (inv.customerPhone != null &&
                    inv.customerPhone!.trim().isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  _ReceiptRow(label: 'Phone', value: inv.customerPhone!.trim()),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: AllColor.grey200),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ITEMS',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AllColor.grey500,
                  ),
                ),
                SizedBox(height: 8.h),
                if (inv.items.isEmpty)
                  Text(
                    'No line items',
                    style: TextStyle(fontSize: 13.sp, color: AllColor.grey500),
                  )
                else
                  ...inv.items.map(
                    (line) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _ItemRow(line: line),
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: AllColor.grey200),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _ReceiptRow(
                  label: 'Payable',
                  value: inv.summary.payable.isEmpty ? '—' : inv.summary.payable,
                  valueBold: true,
                  valueLarge: true,
                ),
                if (hasPaid) ...[
                  SizedBox(height: 8.h),
                  _ReceiptRow(label: 'Paid', value: paid),
                ],
                if (hasChange) ...[
                  SizedBox(height: 8.h),
                  _ReceiptRow(label: 'Change', value: change),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.valueBold = false,
    this.valueLarge = false,
  });

  final String label;
  final String value;
  final bool valueBold;
  final bool valueLarge;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88.w,
          child: Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: valueLarge ? 16.sp : 13.sp,
              fontWeight: valueBold ? FontWeight.w800 : FontWeight.w600,
              color: AllColor.black,
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.line});

  final VendorManualLineItem line;

  @override
  Widget build(BuildContext context) {
    final name = (line.productName ?? '').trim().isNotEmpty
        ? line.productName!.trim()
        : 'Product #${line.productId}';
    final total = line.totalPay?.trim();
    final unit = line.unitPrice?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AllColor.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AllColor.grey200),
          ),
          child: Text(
            '${line.quantity}',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: AllColor.loginButtomColor,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AllColor.black,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  _StatusChip(status: line.status),
                  const Spacer(),
                  if (total != null && total.isNotEmpty)
                    Text(
                      total,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else if (unit != null && unit.isNotEmpty)
                    Text(
                      unit,
                      style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color bg = const Color(0xFFF3F4F6);
    Color fg = AllColor.grey500;
    if (s.contains('pending')) {
      bg = AllColor.orange50.withValues(alpha: 0.8);
      fg = AllColor.loginButtomColor;
    } else if (s.contains('deliver') || s.contains('complete')) {
      bg = const Color(0xFFECFDF5);
      fg = const Color(0xFF059669);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.isEmpty ? '—' : status,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.onPrint,
    required this.onCopy,
    required this.onClose,
    required this.accent,
  });

  final VoidCallback onPrint;
  final VoidCallback onCopy;
  final VoidCallback onClose;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        border: Border(top: BorderSide(color: AllColor.grey200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: onPrint,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: Icon(Icons.print_rounded, size: 22.sp),
            label: Text(
              'Print bill',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCopy,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accent,
                    side: BorderSide(color: AllColor.grey300),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: Icon(Icons.copy_rounded, size: 18.sp),
                  label: Text(
                    'Copy text',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: onClose,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AllColor.black87,
                    side: BorderSide(color: AllColor.grey300),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
