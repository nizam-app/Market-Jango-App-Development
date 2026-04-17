import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/widget/vendor_manual_order_line_card.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

class VendorManualOrderDetailScreen extends ConsumerStatefulWidget {
  const VendorManualOrderDetailScreen({super.key, required this.invoiceId});

  final int invoiceId;

  static String routePath(int id) => '/vendor/manual-order/$id';

  @override
  ConsumerState<VendorManualOrderDetailScreen> createState() =>
      _VendorManualOrderDetailScreenState();
}

class _VendorManualOrderDetailScreenState
    extends ConsumerState<VendorManualOrderDetailScreen> {
  VendorManualOrderInvoice? _inv;
  bool _loading = true;
  String? _error;
  final _paid = TextEditingController();
  final _note = TextEditingController();
  final _addProductId = TextEditingController();
  final _addQty = TextEditingController(text: '1');
  bool _busy = false;

  static final _fieldShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8.r),
  );

  InputDecoration _inputDecoration({String? label, String? hint}) {
    final orange = AllColor.loginButtomColor;
    final soft = AllColor.orange200;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AllColor.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: soft, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: orange, width: 1.5),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _paid.dispose();
    _note.dispose();
    _addProductId.dispose();
    _addQty.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await VendorOrderApi.instance.fetchManualOrderDetail(
        widget.invoiceId,
      );
      if (mounted) {
        setState(() {
          _inv = d;
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

  bool _isPendingLine(VendorManualLineItem it) {
    final s = it.status.toLowerCase();
    return s == 'pending';
  }

  bool _invoiceAllowsEdits(VendorManualOrderInvoice inv) {
    final s = inv.status.toLowerCase().trim();
    return s != 'completed' &&
        s != 'complete' &&
        s != 'cancelled' &&
        s != 'canceled';
  }

  Future<void> _addLine() async {
    final pid = int.tryParse(_addProductId.text.trim());
    final q = int.tryParse(_addQty.text.trim());
    if (pid == null || q == null || q < 1) {
      GlobalSnackbar.show(
        context,
        title: 'Invalid',
        message: 'Enter product ID and quantity',
        type: CustomSnackType.error,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final updated = await VendorOrderApi.instance.addManualOrderItem(
        invoiceId: widget.invoiceId,
        productId: pid,
        quantity: q,
      );
      if (mounted) {
        setState(() {
          _inv = updated;
          _addProductId.clear();
          _addQty.text = '1';
        });
        GlobalSnackbar.show(
          context,
          title: 'Added',
          message: 'Line updated',
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
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deliver() async {
    final paid = _paid.text.trim().isEmpty
        ? null
        : double.tryParse(_paid.text.trim());
    setState(() => _busy = true);
    try {
      final updated = await VendorOrderApi.instance.deliverManualOrder(
        invoiceId: widget.invoiceId,
        customerPaid: paid,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (mounted) {
        setState(() => _inv = updated);
        GlobalSnackbar.show(
          context,
          title: 'Delivered',
          message: 'Order marked delivered',
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
      if (mounted) setState(() => _busy = false);
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
          _inv?.orderNumber.isNotEmpty == true
              ? _inv!.orderNumber
              : 'Order #${widget.invoiceId}',
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
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(_error!),
              ),
            )
          : _buildBody(_inv!),
    );
  }

  Widget _buildBody(VendorManualOrderInvoice inv) {
    final hasPending = inv.items.any(_isPendingLine);
    final allowEdits = _invoiceAllowsEdits(inv);
    final showDeliver = inv.status.toLowerCase() != 'completed' &&
        inv.status.toLowerCase() != 'complete';

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 120.h),
            children: [
              _section(
                children: [
                  Text(
                    inv.customerName ?? 'Customer',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  if (inv.customerPhone != null &&
                      inv.customerPhone!.trim().isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      inv.customerPhone!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AllColor.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  SizedBox(height: 10.h),
                  _kv(
                    'Totals',
                    'Total ${inv.summary.total} · Payable ${inv.summary.payable}',
                  ),
                  if (inv.summary.customerPaid != null &&
                      inv.summary.customerPaid!.trim().isNotEmpty)
                    _kv('Paid', inv.summary.customerPaid!),
                  if (inv.summary.change != null &&
                      inv.summary.change!.trim().isNotEmpty)
                    _kv('Change', inv.summary.change!),
                  _kv(
                    'Status',
                    '${inv.status}${inv.paymentMethod != null && inv.paymentMethod!.trim().isNotEmpty ? ' · ${inv.paymentMethod}' : ''}',
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Padding(
                padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Line items',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF374151),
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Each product on this invoice.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AllColor.grey500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              ...inv.items.asMap().entries.map(
                (e) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: VendorManualOrderLineCard(
                    item: e.value,
                    indexOneBased: e.key + 1,
                    invoiceId: widget.invoiceId,
                    canEdit: allowEdits && _isPendingLine(e.value),
                    onRefresh: _load,
                  ),
                ),
              ),
              if (hasPending && allowEdits) ...[
                SizedBox(height: 4.h),
                _section(
                  children: [
                    Text(
                      'Add line',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.sp,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Merge by product ID adds to existing quantity.',
                      style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _addProductId,
                            enabled: !_busy,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              label: 'Product ID',
                              hint: 'e.g. 34',
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        SizedBox(
                          width: 88.w,
                          child: TextField(
                            controller: _addQty,
                            enabled: !_busy,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              label: 'Qty',
                              hint: '1',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    OutlinedButton(
                      onPressed: _busy ? null : _addLine,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AllColor.loginButtomColor,
                        side: BorderSide(color: AllColor.loginButtomColor, width: 1.2),
                        minimumSize: Size(double.infinity, 44.h),
                        shape: _fieldShape,
                      ),
                      child: Text(
                        'Add / merge line',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 12.h),
              _section(
                children: [
                  Text(
                    'Update order',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.sp,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Customer paid & note when marking delivered (optional).',
                    style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _paid,
                    enabled: !_busy && showDeliver,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _inputDecoration(
                      label: 'Customer paid (optional)',
                      hint: 'For deliver',
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _note,
                    enabled: !_busy && showDeliver,
                    maxLines: 3,
                    decoration: _inputDecoration(
                      label: 'Note (optional)',
                      hint: 'Reason or message for delivery',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDeliver)
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 16.h,
            child: SafeArea(
              child: FilledButton(
                onPressed: _busy ? null : _deliver,
                style: FilledButton.styleFrom(
                  backgroundColor: AllColor.loginButtomColor,
                  foregroundColor: Colors.white,
                  shape: _fieldShape,
                  minimumSize: Size(double.infinity, 48.h),
                  elevation: 0,
                ),
                child: _busy
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Mark delivered',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _section({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _spaced(children),
      ),
    );
  }

  List<Widget> _spaced(List<Widget> items) {
    if (items.isEmpty) return items;
    final out = <Widget>[items.first];
    for (var i = 1; i < items.length; i++) {
      out.add(SizedBox(height: 10.h));
      out.add(items[i]);
    }
    return out;
  }

  Widget _kv(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 108.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AllColor.grey500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AllColor.black87,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
