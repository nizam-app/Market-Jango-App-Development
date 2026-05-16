import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/buyer/screens/refunds/provider/buyer_refunds_provider.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

/// Single buyer refund — `GET /api/buyer/refunds/{id}` (read-only; doc §E).
class BuyerRefundDetailScreen extends ConsumerWidget {
  const BuyerRefundDetailScreen({super.key, required this.refundId});

  static const routeName = '/buyer/refund_detail';

  final int refundId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(buyerRefundDetailProvider(refundId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AllColor.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: const CustomBackButton(),
        ),
        title: Text(
          'Refund #$refundId',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(buyerRefundDetailProvider(refundId));
          await ref.read(buyerRefundDetailProvider(refundId).future);
        },
        child: async.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 120),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(24.w),
            children: [Text(e.toString())],
          ),
          data: (d) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            children: [
              _row('Status', d.status),
              _row('Amount', d.amount.toString()),
              _row('Product', d.productName),
              _row('Order', d.orderNumber),
              if (d.customerName.isNotEmpty) _row('Customer', d.customerName),
              if (d.customerPhone != null && d.customerPhone!.isNotEmpty)
                _row('Phone', d.customerPhone!),
              _row('Reason', d.reason),
              if (d.reviewNote != null && d.reviewNote!.trim().isNotEmpty)
                _row('Vendor note', d.reviewNote!.trim()),
              if (d.reviewerName != null && d.reviewerName!.trim().isNotEmpty)
                _row('Reviewed by', d.reviewerName!.trim()),
              SizedBox(height: 16.h),
              Text(
                'Only the vendor can approve or reject this request. If approved, your wallet is credited.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AllColor.grey500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AllColor.grey500,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
