import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/provider/vendor_orders_provider.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

/// `GET /vendor/refunds/{id}` — approve / reject when [VendorRefundDetail.isPending].
class VendorRefundDetailScreen extends ConsumerStatefulWidget {
  const VendorRefundDetailScreen({super.key, required this.refundId});

  final int refundId;

  static String routePath(int id) => '/vendor/refund/$id';

  @override
  ConsumerState<VendorRefundDetailScreen> createState() =>
      _VendorRefundDetailScreenState();
}

class _VendorRefundDetailScreenState
    extends ConsumerState<VendorRefundDetailScreen> {
  bool _acting = false;

  Future<void> _approve() async {
    final noteCtl = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Approve refund'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'The customer will receive a wallet credit for this amount.',
                style: TextStyle(fontSize: 13.sp, color: AllColor.grey500),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: noteCtl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Approve'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      setState(() => _acting = true);
      try {
        await VendorOrderApi.instance.approveRefund(
          widget.refundId,
          note: noteCtl.text.trim().isEmpty ? null : noteCtl.text.trim(),
        );
        ref.invalidate(vendorRefundDetailProvider(widget.refundId));
        ref.invalidate(vendorRefundsPayloadProvider);
        if (mounted) {
          GlobalSnackbar.show(
            context,
            title: 'Done',
            message: 'Refund approved',
            type: CustomSnackType.success,
          );
        }
      } catch (e) {
        if (mounted) {
          GlobalSnackbar.show(
            context,
            title: 'Error',
            message: e.toString().replaceFirst('Exception: ', ''),
            type: CustomSnackType.error,
          );
        }
      } finally {
        if (mounted) setState(() => _acting = false);
      }
    } finally {
      noteCtl.dispose();
    }
  }

  Future<void> _reject() async {
    final noteCtl = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Reject refund'),
          content: TextField(
            controller: noteCtl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason (required)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AllColor.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reject'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      final note = noteCtl.text.trim();
      if (note.isEmpty) {
        GlobalSnackbar.show(
          context,
          title: 'Note required',
          message: 'Please enter a rejection reason.',
          type: CustomSnackType.error,
        );
        return;
      }
      setState(() => _acting = true);
      try {
        await VendorOrderApi.instance.rejectRefund(widget.refundId, note: note);
        ref.invalidate(vendorRefundDetailProvider(widget.refundId));
        ref.invalidate(vendorRefundsPayloadProvider);
        if (mounted) {
          GlobalSnackbar.show(
            context,
            title: 'Done',
            message: 'Refund rejected',
            type: CustomSnackType.success,
          );
        }
      } catch (e) {
        if (mounted) {
          GlobalSnackbar.show(
            context,
            title: 'Error',
            message: e.toString().replaceFirst('Exception: ', ''),
            type: CustomSnackType.error,
          );
        }
      } finally {
        if (mounted) setState(() => _acting = false);
      }
    } finally {
      noteCtl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(vendorRefundDetailProvider(widget.refundId));

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
          'Refund #${widget.refundId}',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(e.toString()),
          ),
        ),
        data: (d) => _body(context, d),
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (d) {
          if (!d.isPending || _acting) return null;
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reject,
                      child: const Text('Reject'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: FilledButton(
                      onPressed: _approve,
                      style: FilledButton.styleFrom(
                        backgroundColor: AllColor.loginButtomColor,
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }

  Widget _body(BuildContext context, VendorRefundDetail d) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(vendorRefundDetailProvider(widget.refundId));
      },
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AllColor.blue500.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: AllColor.blue500.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              'If you approve, the customer receives a wallet credit for this refund amount — not your vendor wallet.',
              style: TextStyle(fontSize: 13.sp, height: 1.35),
            ),
          ),
          SizedBox(height: 16.h),
          _card(
            children: [
              _kv('Status', d.status),
              _kv('Amount', d.amount.toString()),
              if (d.requestedBy != null && d.requestedBy!.isNotEmpty)
                _kv('Requested by', d.requestedBy!),
              _kv('Product', d.productName.isEmpty ? '—' : d.productName),
              _kv('Order', d.orderNumber.isEmpty ? '—' : d.orderNumber),
              _kv('Customer', d.customerName.isEmpty ? '—' : d.customerName),
              if (d.customerPhone != null && d.customerPhone!.isNotEmpty)
                _kv('Phone', d.customerPhone!),
            ],
          ),
          SizedBox(height: 12.h),
          _card(
            children: [
              Text(
                'Reason',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(d.reason.isEmpty ? '—' : d.reason, style: TextStyle(fontSize: 14.sp)),
            ],
          ),
          if (d.reviewNote != null && d.reviewNote!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _card(
              children: [
                Text(
                  'Review note',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(d.reviewNote!, style: TextStyle(fontSize: 14.sp)),
                if (d.reviewerName != null && d.reviewerName!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      'Reviewer: ${d.reviewerName}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AllColor.grey500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AllColor.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              k,
              style: TextStyle(
                fontSize: 13.sp,
                color: AllColor.grey500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
