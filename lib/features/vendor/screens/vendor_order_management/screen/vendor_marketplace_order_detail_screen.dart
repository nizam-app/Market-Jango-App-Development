import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/provider/vendor_orders_provider.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/widget/vendor_assign_driver_sheet.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/widget/vendor_marketplace_line_product_card.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/widget/vendor_order_assign_rules.dart';
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

  /// Status the backend uses for “order must be pending/processing” (parent order first).
  String _orderGateStatus(VendorMarketplaceLineDetail d) {
    final root = d.parentOrderStatus?.trim();
    if (root != null && root.isNotEmpty) return root;
    final o = d.invoice.orderStatus?.trim();
    if (o != null && o.isNotEmpty) return o;
    return d.invoice.status;
  }

  /// Assign is allowed when this **line** is still Pending/Processing (fulfilment),
  /// or when both invoice (order gate) and line are Pending/Processing (legacy rule).
  bool _canAssignDriverToLine(VendorMarketplaceLineDetail d) {
    if (VendorOrderAssignRules.isPendingOrProcessingStatus(d.status)) {
      return true;
    }
    return VendorOrderAssignRules.isPendingOrProcessingStatus(
          _orderGateStatus(d),
        ) &&
        VendorOrderAssignRules.isPendingOrProcessingStatus(d.status);
  }

  String _assignDriverBlockedHint(VendorMarketplaceLineDetail d) {
    if (_canAssignDriverToLine(d)) return '';
    final gate = _orderGateStatus(d);
    if (!VendorOrderAssignRules.isPendingOrProcessingStatus(gate)) {
      final label =
          (d.parentOrderStatus != null &&
                  d.parentOrderStatus!.trim().isNotEmpty) ||
              (d.invoice.orderStatus != null &&
                  d.invoice.orderStatus!.trim().isNotEmpty)
          ? 'order'
          : 'invoice';
      return 'Driver assignment needs this line to be Pending or Processing, '
          'or the $label to allow fulfilment. Current $label status: '
          '${gate.isEmpty ? '—' : gate}. Line status: '
          '${d.status.isEmpty ? '—' : d.status}.';
    }
    return 'This line must be Pending or Processing to assign a driver. '
        'Current line status: ${d.status.isEmpty ? '—' : d.status}.';
  }

  Future<void> _openAssignDriverSheet() async {
    final d = _detail;
    if (d == null || !mounted) return;
    if (!_canAssignDriverToLine(d)) {
      GlobalSnackbar.show(
        context,
        title: 'Cannot assign driver',
        message: _assignDriverBlockedHint(d),
        type: CustomSnackType.error,
      );
      return;
    }
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        final h = MediaQuery.sizeOf(context).height * 0.58;
        return SafeArea(
          child: SizedBox(
            height: h,
            child: VendorAssignDriverSheet(
              lineId: widget.lineId,
              invoiceStatus: _orderGateStatus(d),
              lineStatus: d.status,
              onAssigned: () async {
                Navigator.of(sheetCtx).pop();
                await _load();
              },
              onAssignFailed: _load,
            ),
          ),
        );
      },
    );
  }

  /// Dismisses a local overlay (e.g. modal bottom sheet) first, then pops this route.
  void _handleDetailBack() {
    if (!mounted) return;
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
      return;
    }
    if (context.canPop()) {
      context.pop();
    }
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleDetailBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: AllColor.white,
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: CustomBackButton(onTap: _handleDetailBack),
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
      ),
    );
  }

  Widget _buildBody(VendorMarketplaceLineDetail d) {
    final orderGate = _orderGateStatus(d);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
        children: [
          _section(
            children: [
              _kv('Customer name', _customer(d)),
              _kv(
                'Order number',
                d.invoice.orderNumber.isEmpty ? '—' : d.invoice.orderNumber,
              ),
              _kv(
                'Invoice status',
                d.invoice.status.isEmpty ? '—' : d.invoice.status,
              ),
              if (orderGate.trim().isNotEmpty && orderGate != d.invoice.status)
                _kv('Order status', orderGate),
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
          if (d.lineItems.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
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
            ...d.lineItems.asMap().entries.map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: VendorMarketplaceLineProductCard(
                  line: e.value,
                  indexOneBased: e.key + 1,
                  screenLineId: widget.lineId,
                  onRefresh: _load,
                ),
              ),
            ),
          ] else
            VendorMarketplaceLineProductCard(
              line: d,
              indexOneBased: 1,
              screenLineId: widget.lineId,
              onRefresh: _load,
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
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
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
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AllColor.orange50.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.local_shipping_outlined,
                      color: AllColor.loginButtomColor,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assign to drivers',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15.sp,
                            color: AllColor.black,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Pick-up and drop-off for this line.',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: AllColor.grey500,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AllColor.grey200),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FROM',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AllColor.grey500,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              _addrOrDash(d.pickupAddress),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AllColor.black,
                                height: 1.3,
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
                              'TO',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AllColor.grey500,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              _addrOrDash(d.shipAddress),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AllColor.black,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              if (_assignmentLoadFailed)
                Text(
                  'Assignment history could not be loaded. Pull to refresh to retry.',
                  style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
                )
              else if (_assignment != null &&
                  _assignment!.assignments.isNotEmpty) ...[
                Text(
                  'Assignment history',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AllColor.grey500,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                ..._assignment!.assignments.map(
                  (a) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AllColor.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AllColor.grey200),
                      ),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8.w,
                        runSpacing: 6.h,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AllColor.orange50.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              a.status,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: AllColor.loginButtomColor,
                              ),
                            ),
                          ),
                          Text(
                            a.driver == null || a.driver!.name.isEmpty
                                ? 'Driver #${a.driver?.id ?? "—"}'
                                : a.driver!.name,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AllColor.black,
                            ),
                          ),
                          if (a.assignedByName != null &&
                              a.assignedByName!.trim().isNotEmpty)
                            Text(
                              '· ${a.assignedByName}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AllColor.grey500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else if (_assignment != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    'No assignments yet for this line.',
                    style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
                  ),
                ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: FilledButton.icon(
                      onPressed: _canAssignDriverToLine(d)
                          ? _openAssignDriverSheet
                          : null,
                      icon: Icon(Icons.person_add_outlined, size: 20.sp),
                      label: Text(
                        'Assign driver',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AllColor.loginButtomColor,
                        foregroundColor: AllColor.white,
                        disabledBackgroundColor: AllColor.grey300,
                        disabledForegroundColor: AllColor.grey.shade600,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: (!_showUnassignButton(d) || _unassignBusy)
                          ? null
                          : _unassignDriver,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AllColor.grey.shade800,
                        side: BorderSide(color: AllColor.grey.shade400),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: _unassignBusy
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Remove',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              if (!_canAssignDriverToLine(d)) ...[
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AllColor.grey100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18.sp,
                        color: AllColor.grey500,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _assignDriverBlockedHint(d),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AllColor.grey.shade600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                  Icon(
                    Icons.chevron_right,
                    color: AllColor.grey500,
                    size: 22.sp,
                  ),
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
}
