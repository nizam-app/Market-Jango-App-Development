import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';
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

  Future<void> _deleteLine(VendorManualLineItem it) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove line'),
        content: const Text('Remove this product from the order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Remove', style: TextStyle(color: AllColor.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      final updated = await VendorOrderApi.instance.deleteManualOrderItem(
        invoiceId: widget.invoiceId,
        itemId: it.id,
      );
      if (mounted) setState(() => _inv = updated);
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
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
            children: [
              _summary(inv),
              SizedBox(height: 16.h),
              Text(
                'Items',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.sp),
              ),
              SizedBox(height: 8.h),
              ...inv.items.map((it) {
                return Card(
                  child: ListTile(
                    title: Text(it.productName ?? 'Product #${it.productId}'),
                    subtitle: Text('Qty ${it.quantity} · ${it.status}'),
                    trailing: _isPendingLine(it)
                        ? IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: AllColor.red,
                            ),
                            onPressed: _busy ? null : () => _deleteLine(it),
                          )
                        : null,
                  ),
                );
              }),
              if (hasPending) ...[
                SizedBox(height: 16.h),
                Text(
                  'Add line',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addProductId,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Product ID',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 80.w,
                      child: TextField(
                        controller: _addQty,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Qty',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                OutlinedButton(
                  onPressed: _busy ? null : _addLine,
                  child: const Text('Add / merge line'),
                ),
              ],
              SizedBox(height: 24.h),
              TextField(
                controller: _paid,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Customer paid (optional, for deliver)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
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
            ],
          ),
        ),
        Positioned(
          left: 16.w,
          right: 16.w,
          bottom: 16.h,
          child: FilledButton(
            onPressed: _busy ? null : _deliver,
            style: FilledButton.styleFrom(
              backgroundColor: AllColor.loginButtomColor,
              minimumSize: Size(double.infinity, 48.h),
            ),
            child: const Text('Mark delivered'),
          ),
        ),
      ],
    );
  }

  Widget _summary(VendorManualOrderInvoice inv) {
    final s = inv.summary;
    return Material(
      color: AllColor.white,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              inv.customerName ?? 'Customer',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            if (inv.customerPhone != null && inv.customerPhone!.isNotEmpty)
              Text(inv.customerPhone!),
            SizedBox(height: 8.h),
            Text('Total ${s.total} · Payable ${s.payable}'),
            if (s.customerPaid != null && s.customerPaid!.isNotEmpty)
              Text('Paid ${s.customerPaid}'),
            if (s.change != null && s.change!.isNotEmpty)
              Text('Change ${s.change}'),
            SizedBox(height: 4.h),
            Text('Status: ${inv.status} · ${inv.paymentMethod ?? ""}'),
          ],
        ),
      ),
    );
  }
}
