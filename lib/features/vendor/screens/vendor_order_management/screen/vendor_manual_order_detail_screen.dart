import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/widget/vendor_assign_driver_sheet.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/util/vendor_order_document_local_save.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/widget/vendor_marketplace_line_product_card.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/widget/vendor_order_assign_rules.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_invoice_print_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/widget/vendor_invoice_print_sheet.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/widget/vendor_order_document_download_row.dart';
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
  final _fulfillmentNote = TextEditingController();
  final _addProductId = TextEditingController();
  final _addQty = TextEditingController(text: '1');
  bool _busy = false;

  int? _focusLineItemId;
  VendorMarketplaceLineDetail? _focusLineDetail;
  VendorOrderAssignmentPayload? _assignment;
  bool _assignmentLoadFailed = false;
  bool _focusLineLoading = false;
  bool _unassignBusy = false;
  String? _nextStatus;
  bool _savingStatus = false;
  String? _docLoadingKey;

  /// Sentinel: never equals a real line id, so cancelling a line does not pop this route.
  static const int _noPrimaryLineId = -1;

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
    _fulfillmentNote.dispose();
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
        await _ensureFocusLineAndLoadDetail();
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

  Future<void> _ensureFocusLineAndLoadDetail() async {
    final inv = _inv;
    if (inv == null || inv.items.isEmpty) {
      if (mounted) {
        setState(() {
          _focusLineItemId = null;
          _focusLineDetail = null;
          _assignment = null;
          _assignmentLoadFailed = false;
          _nextStatus = null;
          _focusLineLoading = false;
        });
      }
      return;
    }
    final ids = inv.items.map((e) => e.id).toSet();
    if (_focusLineItemId == null || !ids.contains(_focusLineItemId)) {
      _focusLineItemId = inv.items.first.id;
    }
    await _loadFocusLineDetail();
  }

  Future<void> _loadFocusLineDetail() async {
    final id = _focusLineItemId;
    if (id == null) return;
    if (mounted) setState(() => _focusLineLoading = true);
    try {
      final d = await VendorOrderApi.instance.fetchMarketplaceLineDetail(id);
      VendorOrderAssignmentPayload? assign;
      var assignFail = false;
      try {
        assign = await VendorOrderApi.instance.fetchOrderAssignmentHistory(id);
      } catch (_) {
        assign = null;
        assignFail = true;
      }
      if (!mounted) return;
      setState(() {
        _focusLineDetail = d;
        _assignment = assign;
        _assignmentLoadFailed = assignFail;
        _nextStatus = d.allowedNextStatuses.isNotEmpty
            ? d.allowedNextStatuses.first
            : null;
        _fulfillmentNote.text = d.lineNote ?? '';
        _focusLineLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _focusLineDetail = null;
        _assignment = null;
        _assignmentLoadFailed = true;
        _nextStatus = null;
        _focusLineLoading = false;
      });
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

  String _customer(VendorManualOrderInvoice inv) {
    final n = inv.customerName?.trim();
    final p = inv.customerPhone?.trim();
    if (n != null && n.isNotEmpty) {
      if (p != null && p.isNotEmpty) return '$n · $p';
      return n;
    }
    if (p != null && p.isNotEmpty) return p;
    return '—';
  }

  String _payment(VendorManualOrderInvoice inv) {
    final a = inv.paymentMethod?.trim();
    if (a != null && a.isNotEmpty) return a;
    return '—';
  }

  String _modeFromItems(VendorManualOrderInvoice inv) {
    if (inv.items.isEmpty) return '—';
    final set = inv.items
        .map((e) => e.status.trim())
        .where((s) => s.isNotEmpty)
        .toSet();
    if (set.isEmpty) return '—';
    if (set.length == 1) return set.first;
    return 'Mixed';
  }

  String _addrOrDash(String? raw) {
    final s = raw?.trim();
    if (s != null && s.isNotEmpty) return s;
    return '—';
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

  String _orderGateStatus(VendorMarketplaceLineDetail d) {
    final root = d.parentOrderStatus?.trim();
    if (root != null && root.isNotEmpty) return root;
    final o = d.invoice.orderStatus?.trim();
    if (o != null && o.isNotEmpty) return o;
    return d.invoice.status;
  }

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
    final d = _focusLineDetail;
    final lineId = _focusLineItemId;
    if (d == null || lineId == null || !mounted) return;
    if (!_canAssignDriverToLine(d)) {
      GlobalSnackbar.show(
        context,
        title: 'Cannot assign driver',
        message: _assignDriverBlockedHint(d),
        type: CustomSnackType.error,
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        final h = MediaQuery.sizeOf(context).height * 0.58;
        return SafeArea(
          child: SizedBox(
            height: h,
            child: VendorAssignDriverSheet(
              lineId: lineId,
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

  Future<void> _unassignDriver() async {
    final lineId = _focusLineItemId;
    if (lineId == null) return;
    setState(() => _unassignBusy = true);
    try {
      await VendorOrderApi.instance.unassignDriverFromOrderItem(lineId);
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

  Future<void> _saveLineStatus() async {
    final d = _focusLineDetail;
    final lineId = _focusLineItemId;
    final status = _nextStatus;
    if (d == null || lineId == null || status == null || status.isEmpty) {
      return;
    }
    setState(() => _savingStatus = true);
    try {
      await VendorOrderApi.instance.updateMarketplaceLineStatus(
        id: lineId,
        status: status,
        note: _fulfillmentNote.text.trim().isEmpty
            ? null
            : _fulfillmentNote.text.trim(),
      );
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Updated',
          message: 'Status updated',
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
      if (mounted) setState(() => _savingStatus = false);
    }
  }

  int _manualOrderDocumentPathId(VendorManualOrderInvoice inv) {
    final oid = inv.orderRecordId;
    if (oid != null && oid > 0) return oid;
    final iid = inv.id;
    if (iid > 0) return iid;
    return 0;
  }

  Future<void> _openPrintInvoice(VendorManualOrderInvoice inv) async {
    final pathId = _manualOrderDocumentPathId(inv);
    if (pathId <= 0) {
      GlobalSnackbar.show(
        context,
        title: 'Unavailable',
        message: 'Could not resolve order id for printing.',
        type: CustomSnackType.error,
      );
      return;
    }
    final data = VendorInvoicePrintData.fromManualInvoice(inv, pathId);
    await VendorInvoicePrintSheet.show(context, data);
  }

  Future<void> _openOrderDocument(
    VendorManualOrderInvoice inv,
    bool deliveryLabel,
  ) async {
    final pathId = _manualOrderDocumentPathId(inv);
    if (pathId <= 0) {
      GlobalSnackbar.show(
        context,
        title: 'Unavailable',
        message: 'Could not resolve order id for download.',
        type: CustomSnackType.error,
      );
      return;
    }
    final key = deliveryLabel ? 'label' : 'invoice';
    setState(() => _docLoadingKey = key);
    try {
      final doc = deliveryLabel
          ? await VendorOrderApi.instance
              .fetchVendorAllOrderDeliveryLabelDocument(pathId)
          : await VendorOrderApi.instance
              .fetchVendorAllOrderInvoiceDocument(pathId);
      if (!mounted) return;
      final orderNo = inv.orderNumber.trim().isEmpty
          ? '$pathId'
          : inv.orderNumber.trim();
      await saveVendorOrderDocumentLocallyAndShare(
        context: context,
        bytes: doc.bytes,
        contentType: doc.contentType,
        orderLabel: orderNo,
        isDeliveryLabel: deliveryLabel,
      );
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Download complete',
          message:
              'Your PDF is ready. If you chose Downloads or Files in the menu, '
              'look there; otherwise the file is kept in the app so you can '
              'share it again whenever you like.',
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
      if (mounted) setState(() => _docLoadingKey = null);
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
        await _ensureFocusLineAndLoadDetail();
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
    setState(() => _busy = true);
    try {
      final updated = await VendorOrderApi.instance.deliverManualOrder(
        invoiceId: widget.invoiceId,
        customerPaid: null,
        note: null,
      );
      if (mounted) {
        setState(() => _inv = updated);
        GlobalSnackbar.show(
          context,
          title: 'Delivered',
          message: 'Order marked delivered',
          type: CustomSnackType.success,
        );
        await _ensureFocusLineAndLoadDetail();
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

  List<Widget> _buildFulfillmentSections(VendorManualOrderInvoice inv) {
    if (inv.items.isEmpty) return [];
    if (_focusLineLoading) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    final d = _focusLineDetail;
    if (d == null) {
      return [
        _section(
          children: [
            Text(
              'Driver assignment and line status need line details from the server. '
              'Pull to refresh or pick another line.',
              style: TextStyle(fontSize: 13.sp, color: AllColor.grey500),
            ),
          ],
        ),
      ];
    }
    return [
      SizedBox(height: 12.h),
      _section(
        children: [
          TextField(
            controller: _fulfillmentNote,
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
                  value: _nextStatus != null &&
                          d.allowedNextStatuses.contains(_nextStatus)
                      ? _nextStatus
                      : d.allowedNextStatuses.first,
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
    ];
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
    final showDeliver =
        inv.status.toLowerCase() != 'completed' &&
        inv.status.toLowerCase() != 'complete';
    final showUpdateStatus =
        _focusLineDetail != null &&
        _focusLineDetail!.allowedNextStatuses.isNotEmpty;
    final bottomCount =
        (showDeliver ? 1 : 0) + (showUpdateStatus ? 1 : 0);
    final listBottomPad = bottomCount == 2
        ? 200.h
        : bottomCount == 1
        ? 150.h
        : 120.h;

    return Stack(
      children: [
        Positioned.fill(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, listBottomPad),
            children: [
              _section(
                children: [
                  _kv('Customer name', _customer(inv)),
                  _kv(
                    'Order number',
                    inv.orderNumber.isEmpty ? '—' : inv.orderNumber,
                  ),
                  _kv(
                    'Invoice status',
                    inv.status.isEmpty ? '—' : inv.status,
                  ),
                  _kv('Payment', _payment(inv)),
                  _kv('Mode', _modeFromItems(inv)),
                  _kv('Destination', '—'),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(2.w, 4.h, 2.w, 0),
                child: VendorOrderDocumentDownloadRow(
                  loadingKey: _docLoadingKey,
                  onInvoiceTap: () => _openOrderDocument(inv, false),
                  onDeliveryTap: () => _openOrderDocument(inv, true),
                  onPrintInvoiceTap: () => _openPrintInvoice(inv),
                ),
              ),
              SizedBox(height: 12.h),
              if (inv.items.isNotEmpty) ...[
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
                ...inv.items.asMap().entries.map(
                  (e) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: VendorMarketplaceLineProductCard(
                      line: vendorMarketplaceLineFromManualItem(e.value, inv),
                      indexOneBased: e.key + 1,
                      screenLineId: _noPrimaryLineId,
                      onRefresh: _load,
                    ),
                  ),
                ),
                if (inv.items.length > 1) ...[
                  SizedBox(height: 4.h),
                  _section(
                    children: [
                      Text(
                        'Line for driver & status',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.sp,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      InputDecorator(
                        decoration: _inputDecoration(
                          label: 'Invoice line',
                          hint: null,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _focusLineItemId != null &&
                                    inv.items.any(
                                      (it) => it.id == _focusLineItemId,
                                    )
                                ? _focusLineItemId
                                : inv.items.first.id,
                            isExpanded: true,
                            items: inv.items
                                .map(
                                  (it) => DropdownMenuItem<int>(
                                    value: it.id,
                                    child: Text(
                                      'Line #${it.id} · ${(it.productName ?? 'Product').trim().isEmpty ? 'Product #${it.productId}' : (it.productName ?? '').trim()}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) async {
                              if (v == null) return;
                              setState(() => _focusLineItemId = v);
                              await _loadFocusLineDetail();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                ..._buildFulfillmentSections(inv),
              ],
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
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AllColor.grey500,
                      ),
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
                        side: BorderSide(
                          color: AllColor.loginButtomColor,
                          width: 1.2,
                        ),
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
            ],
          ),
        ),
        ),
        if (bottomCount > 0)
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 16.h,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showUpdateStatus)
                    FilledButton(
                      onPressed: (_savingStatus || _busy) ? null : _saveLineStatus,
                      style: FilledButton.styleFrom(
                        backgroundColor: AllColor.loginButtomColor,
                        foregroundColor: Colors.white,
                        shape: _fieldShape,
                        minimumSize: Size(double.infinity, 48.h),
                        elevation: 0,
                      ),
                      child: _savingStatus
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Update status',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  if (showUpdateStatus && showDeliver) SizedBox(height: 10.h),
                  if (showDeliver)
                    FilledButton(
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
                ],
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
