import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

class VendorMarketplaceOrderDetailScreen extends ConsumerStatefulWidget {
  const VendorMarketplaceOrderDetailScreen({super.key, required this.lineId});

  final int lineId;

  static String routePath(int id) => '/vendor/marketplace-order/$id';

  @override
  ConsumerState<VendorMarketplaceOrderDetailScreen> createState() =>
      _VendorMarketplaceOrderDetailScreenState();
}

class _VendorMarketplaceOrderDetailScreenState
    extends ConsumerState<VendorMarketplaceOrderDetailScreen> {
  VendorMarketplaceLineDetail? _detail;
  bool _loading = true;
  String? _error;
  final _note = TextEditingController();
  String? _nextStatus;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await VendorOrderApi.instance.fetchMarketplaceLineDetail(widget.lineId);
      if (mounted) {
        setState(() {
          _detail = d;
          _nextStatus = d.allowedNextStatuses.isNotEmpty ? d.allowedNextStatuses.first : null;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    final d = _detail;
    final status = _nextStatus;
    if (d == null || status == null || status.isEmpty) return;
    setState(() => _saving = true);
    try {
      await VendorOrderApi.instance.updateMarketplaceLineStatus(
        id: widget.lineId,
        status: status,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Updated',
          message: 'Status updated',
          type: CustomSnackType.success,
        );
        context.pop(true);
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
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Line #${widget.lineId}',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Text(_error!),
            ))
          : _buildBody(_detail!),
      bottomNavigationBar: _detail == null || _detail!.allowedNextStatuses.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AllColor.loginButtomColor,
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                  child: _saving
                      ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Update status'),
                ),
              ),
            ),
    );
  }

  Widget _buildBody(VendorMarketplaceLineDetail d) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _card(
            title: 'Product',
            child: Text(
              d.product.name.isEmpty ? '#${d.productId}' : d.product.name,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 10.h),
          _card(
            title: 'Order',
            child: Text(
              'Number: ${d.invoice.orderNumber}\n'
              'Invoice status: ${d.invoice.status}\n'
              'Payment: ${d.invoice.paymentMethod ?? "—"}',
            ),
          ),
          SizedBox(height: 10.h),
          _card(
            title: 'Line',
            child: Text(
              'Status: ${d.status}\n'
              'Quantity: ${d.quantity}\n'
              'Sale: ${d.salePrice}',
            ),
          ),
          if (d.driver != null && d.driver!.id > 0) ...[
            SizedBox(height: 10.h),
            _card(
              title: 'Driver',
              child: Text(d.driver!.name.isEmpty ? '#${d.driver!.id}' : d.driver!.name),
            ),
          ],
          SizedBox(height: 16.h),
          Text(
            'Set next status',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<String>(
            initialValue: _nextStatus,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: d.allowedNextStatuses
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _nextStatus = v),
          ),
          if (d.allowedNextStatuses.isEmpty)
            Text(
              'No further transitions (check API / order state).',
              style: TextStyle(color: AllColor.grey500, fontSize: 13.sp),
            ),
          SizedBox(height: 12.h),
          TextField(
            controller: _note,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Material(
      color: AllColor.white,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: AllColor.grey500,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            child,
          ],
        ),
      ),
    );
  }
}
