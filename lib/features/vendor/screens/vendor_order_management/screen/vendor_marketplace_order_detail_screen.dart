import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/provider/vendor_orders_provider.dart';
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
  bool _refundBusy = false;
  VendorOrderAssignmentPayload? _assignment;
  bool _assignmentLoadFailed = false;
  bool _unassignBusy = false;

  static final _fieldShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
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
    _note.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await VendorOrderApi.instance.fetchMarketplaceLineDetail(
        widget.lineId,
      );
      VendorOrderAssignmentPayload? assign;
      var assignFail = false;
      try {
        assign = await VendorOrderApi.instance.fetchOrderAssignmentHistory(
          widget.lineId,
        );
      } catch (_) {
        assign = null;
        assignFail = true;
      }
      if (mounted) {
        setState(() {
          _detail = d;
          _assignment = assign;
          _assignmentLoadFailed = assignFail;
          _nextStatus = d.allowedNextStatuses.isNotEmpty
              ? d.allowedNextStatuses.first
              : null;
          _note.text = d.lineNote ?? '';
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

  String _customer(VendorMarketplaceLineDetail d) {
    final a = d.lineCustomerName?.trim();
    if (a != null && a.isNotEmpty) return a;
    final b = d.invoice.cusName?.trim();
    if (b != null && b.isNotEmpty) return b;
    return '—';
  }

  String _payment(VendorMarketplaceLineDetail d) {
    final a = d.linePaymentMethod?.trim();
    if (a != null && a.isNotEmpty) return a;
    return d.invoice.paymentMethod ?? '—';
  }

  /// Mode = invoice line `status` (e.g. pending, processing).
  String _modeFromStatus(VendorMarketplaceLineDetail d) {
    final s = d.status.trim();
    return s.isEmpty ? '—' : s;
  }

  /// Destination = `ship_address` only (no pickup fallback).
  String _destinationFromShip(VendorMarketplaceLineDetail d) {
    final s = d.shipAddress?.trim();
    if (s != null && s.isNotEmpty) return s;
    return '—';
  }

  String _addrOrDash(String? raw) {
    final s = raw?.trim();
    if (s != null && s.isNotEmpty) return s;
    return '—';
  }

  String _saleAmount(VendorMarketplaceLineDetail d) {
    final t = d.totalPay?.trim();
    if (t != null && t.isNotEmpty) return t;
    return d.salePrice.toString();
  }

  bool _canRequestRefund(VendorMarketplaceLineDetail d) {
    final s = d.status.toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '');
    return s.contains('delivered') || s.contains('returned');
  }

  bool _assignmentIsTerminal(String status) {
    final t = status.toLowerCase().trim();
    return t == 'rejected' || t == 'cancelled' || t == 'delivered';
  }

  bool _showUnassignButton(VendorMarketplaceLineDetail d) {
    if (d.driver != null && d.driver!.id > 0) return true;
    final p = _assignment;
    if (p == null || p.assignments.isEmpty) return false;
    return !_assignmentIsTerminal(p.assignments.first.status);
  }

  Future<void> _openAssignDriverSheet() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        final h = MediaQuery.sizeOf(context).height * 0.58;
        return SafeArea(
          child: SizedBox(
            height: h,
            child: _VendorAssignDriverSheet(
              lineId: widget.lineId,
              onAssigned: () async {
                Navigator.of(sheetCtx).pop();
                await _load();
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _unassignDriver() async {
    setState(() => _unassignBusy = true);
    try {
      await VendorOrderApi.instance.unassignDriverFromOrderItem(widget.lineId);
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Updated',
          message: 'Driver assignment removed',
          type: CustomSnackType.success,
        );
        await _load();
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
      if (mounted) setState(() => _unassignBusy = false);
    }
  }

  Future<void> _openRefundDialog() async {
    final d = _detail;
    if (d == null) return;
    final reason = TextEditingController();
    final amount = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request refund'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Creates a pending refund for this line. Leave amount empty to use the full line total.',
                style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: reason,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    final r = reason.text.trim();
    final amtRaw = amount.text.trim();
    reason.dispose();
    amount.dispose();
    if (submitted != true || !mounted) return;
    if (r.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: 'Reason required',
        message: 'Please enter a refund reason.',
        type: CustomSnackType.error,
      );
      return;
    }
    double? amt;
    if (amtRaw.isNotEmpty) {
      amt = double.tryParse(amtRaw.replaceAll(',', ''));
      if (amt == null) {
        GlobalSnackbar.show(
          context,
          title: 'Invalid amount',
          message: 'Enter a valid number or leave amount empty.',
          type: CustomSnackType.error,
        );
        return;
      }
    }
    setState(() => _refundBusy = true);
    try {
      await VendorOrderApi.instance.requestMarketplaceLineRefund(
        invoiceItemId: widget.lineId,
        reason: r,
        amount: amt,
      );
      ref.invalidate(vendorRefundsPayloadProvider);
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Submitted',
          message: 'Refund request created',
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
      if (mounted) setState(() => _refundBusy = false);
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
          'LINE #${widget.lineId}',
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
          : _buildBody(_detail!),
      bottomNavigationBar:
          _detail == null || _detail!.allowedNextStatuses.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AllColor.loginButtomColor,
                    shape: _fieldShape,
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
    final productName =
        d.product.name.isEmpty ? '#${d.productId}' : d.product.name;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
        children: [
          _section(
            children: [
              _kv('Customer name', _customer(d)),
              _kv('Order number', d.invoice.orderNumber.isEmpty ? '—' : d.invoice.orderNumber),
              _kv('Invoice status', d.invoice.status.isEmpty ? '—' : d.invoice.status),
              _kv('Payment', _payment(d)),
              _kv('Mode', _modeFromStatus(d)),
              _kv('Destination', _destinationFromShip(d)),
              if (d.driver != null && d.driver!.id > 0)
                _kv(
                  'Driver',
                  d.driver!.name.isEmpty ? '#${d.driver!.id}' : d.driver!.name,
                ),
            ],
          ),
          SizedBox(height: 12.h),
          _section(
            children: [
              Text(
                '1. Product name: $productName',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AllColor.black,
                ),
              ),
              SizedBox(height: 10.h),
              _bullet('Quantity: ${d.quantity}'),
              _bullet('Sale: ${_saleAmount(d)}'),
              if (d.unitPrice != null && d.unitPrice!.trim().isNotEmpty)
                _bullet('Unit price: ${d.unitPrice}'),
            ],
          ),
          if (_canRequestRefund(d)) ...[
            SizedBox(height: 12.h),
            _section(
              children: [
                Text(
                  'Refund request',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: AllColor.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'For delivered or returned lines you can open a refund (pending until you approve it in Refunds).',
                  style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
                ),
                SizedBox(height: 12.h),
                OutlinedButton(
                  onPressed: _refundBusy ? null : _openRefundDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AllColor.loginButtomColor,
                    side: BorderSide(color: AllColor.loginButtomColor),
                  ),
                  child: _refundBusy
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Request refund'),
                ),
              ],
            ),
          ],
          SizedBox(height: 12.h),
          _section(
            children: [
              TextField(
                controller: _note,
                maxLines: 3,
                decoration: _inputDecoration(
                  label: 'Note (optional)',
                  hint: 'Reason or message for status change',
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _section(
            children: [
              Text(
                'Assign to drivers',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: AllColor.black,
                ),
              ),
              SizedBox(height: 12.h),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AllColor.grey500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            _addrOrDash(d.pickupAddress),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AllColor.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: AllColor.grey300,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AllColor.grey500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            _addrOrDash(d.shipAddress),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AllColor.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              if (_assignmentLoadFailed)
                Text(
                  'Assignment history could not be loaded. Pull to refresh to retry.',
                  style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
                )
              else if (_assignment != null && _assignment!.assignments.isNotEmpty) ...[
                Text(
                  'Assignment history',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AllColor.grey500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                ..._assignment!.assignments.map(
                  (a) => Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(
                      '${a.status} · ${a.driver == null || a.driver!.name.isEmpty ? "Driver #${a.driver?.id ?? "—"}" : a.driver!.name}'
                      '${a.assignedByName != null && a.assignedByName!.isNotEmpty ? " · by ${a.assignedByName}" : ""}',
                      style: TextStyle(fontSize: 13.sp, color: AllColor.black),
                    ),
                  ),
                ),
              ] else if (_assignment != null)
                Text(
                  'No assignments yet for this line.',
                  style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
                ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _openAssignDriverSheet,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AllColor.loginButtomColor,
                        side: BorderSide(color: AllColor.loginButtomColor),
                      ),
                      child: const Text('Assign driver'),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          (!_showUnassignButton(d) || _unassignBusy)
                              ? null
                              : _unassignDriver,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AllColor.grey.shade700,
                        side: BorderSide(color: AllColor.grey300),
                      ),
                      child: _unassignBusy
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Remove assignment'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _section(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Set next status',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: AllColor.black,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AllColor.grey500, size: 22.sp),
                ],
              ),
              SizedBox(height: 10.h),
              if (d.allowedNextStatuses.isEmpty)
                Text(
                  'No further transitions (check API / order state).',
                  style: TextStyle(color: AllColor.grey500, fontSize: 13.sp),
                )
              else
                InputDecorator(
                  decoration: _inputDecoration(),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _nextStatus,
                      isExpanded: true,
                      hint: Text(
                        'Select status',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AllColor.grey500,
                        ),
                      ),
                      items: d.allowedNextStatuses
                          .map(
                            (s) => DropdownMenuItem<String>(
                              value: s,
                              child: Text(s),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _nextStatus = v),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AllColor.grey300),
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
          width: 118.w,
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
              fontWeight: FontWeight.w500,
              color: AllColor.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        '• $text',
        style: TextStyle(fontSize: 13.sp, color: AllColor.black, height: 1.35),
      ),
    );
  }
}

class _VendorAssignDriverSheet extends StatefulWidget {
  const _VendorAssignDriverSheet({
    required this.lineId,
    required this.onAssigned,
  });

  final int lineId;
  final Future<void> Function() onAssigned;

  @override
  State<_VendorAssignDriverSheet> createState() => _VendorAssignDriverSheetState();
}

class _VendorAssignDriverSheetState extends State<_VendorAssignDriverSheet> {
  final _search = TextEditingController();
  List<VendorAvailableDriver> _drivers = [];
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final q = _search.text.trim();
      final list = await VendorOrderApi.instance.fetchAvailableDrivers(
        search: q.isEmpty ? null : q,
      );
      if (mounted) {
        setState(() {
          _drivers = list;
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

  Future<void> _assign(VendorAvailableDriver dr) async {
    setState(() => _submitting = true);
    try {
      await VendorOrderApi.instance.assignDriverToOrderItem(
        invoiceItemId: widget.lineId,
        driverId: dr.id,
      );
      if (!mounted) return;
      GlobalSnackbar.show(
        context,
        title: 'Assigned',
        message: 'Driver assigned to this line',
        type: CustomSnackType.success,
      );
      await widget.onAssigned();
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Error',
          message: e.toString().replaceFirst('Exception: ', ''),
          type: CustomSnackType.error,
        );
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Available drivers',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AllColor.black,
                  ),
                ),
              ),
              IconButton(
                onPressed: _loading || _submitting ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Search by name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                  ),
                  onSubmitted: (_) => _fetch(),
                ),
              ),
              SizedBox(width: 8.w),
              FilledButton(
                onPressed: _loading || _submitting ? null : _fetch,
                style: FilledButton.styleFrom(
                  backgroundColor: AllColor.loginButtomColor,
                ),
                child: const Text('Search'),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AllColor.grey500, fontSize: 13.sp),
                        ),
                      ),
                    )
                  : _drivers.isEmpty
                      ? Center(
                          child: Text(
                            'No drivers match your search.',
                            style: TextStyle(color: AllColor.grey500, fontSize: 13.sp),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: _drivers.length,
                          itemBuilder: (ctx, i) {
                            final dr = _drivers[i];
                            final label =
                                dr.name.isEmpty ? 'Driver #${dr.id}' : dr.name;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(label),
                              trailing: _submitting
                                  ? SizedBox(
                                      width: 22.w,
                                      height: 22.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.chevron_right),
                              onTap: _submitting ? null : () => _assign(dr),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}
