import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';

/// Invoice + delivery label actions (matches vendor marketplace / walk-in design).
class VendorOrderDocumentDownloadRow extends StatelessWidget {
  const VendorOrderDocumentDownloadRow({
    super.key,
    this.loadingKey,
    required this.onInvoiceTap,
    required this.onDeliveryTap,
    this.onPrintInvoiceTap,
    this.printBusy = false,
  });

  /// `'invoice'` | `'label'` | `null`
  final String? loadingKey;
  final VoidCallback onInvoiceTap;
  final VoidCallback onDeliveryTap;
  final VoidCallback? onPrintInvoiceTap;
  final bool printBusy;

  @override
  Widget build(BuildContext context) {
    final invBusy = loadingKey == 'invoice';
    final lblBusy = loadingKey == 'label';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: invBusy ? null : onInvoiceTap,
                icon: invBusy
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.download_outlined, size: 18.sp),
                label: Text(
                  'Invoice (PDF)',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AllColor.loginButtomColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AllColor.loginButtomColor,
                  side: BorderSide(color: AllColor.loginButtomColor, width: 1.2),
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: lblBusy ? null : onDeliveryTap,
                icon: lblBusy
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.download_outlined, size: 18.sp),
                label: Text(
                  'Delivery label (PDF)',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E3A5F),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E3A5F),
                  side: BorderSide(color: AllColor.grey300, width: 1.2),
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (onPrintInvoiceTap != null) ...[
          SizedBox(height: 10.h),
          FilledButton.icon(
            onPressed: printBusy ? null : onPrintInvoiceTap,
            icon: printBusy
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(Icons.print_outlined, size: 20.sp),
            label: Text(
              'Print invoice',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AllColor.loginButtomColor,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
