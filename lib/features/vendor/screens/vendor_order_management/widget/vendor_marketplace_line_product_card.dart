import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';

/// One invoice line: summary, status, driver, cancel, quantity + reason.
class VendorMarketplaceLineProductCard extends StatefulWidget {
  const VendorMarketplaceLineProductCard({
    super.key,
    required this.line,
    required this.indexOneBased,
    required this.screenLineId,
    required this.onRefresh,
  });

  final VendorMarketplaceLine line;
  final int indexOneBased;
  final int screenLineId;
  final Future<void> Function() onRefresh;

  @override
  State<VendorMarketplaceLineProductCard> createState() =>
      _VendorMarketplaceLineProductCardState();
}

class _VendorMarketplaceLineProductCardState
    extends State<VendorMarketplaceLineProductCard> {
  late int _qty;
  final _qtyReason = TextEditingController();
  bool _cancelBusy = false;
  bool _qtyBusy = false;

  static const _titleColor = Color(0xFF111827);
  static const _cardBorder = Color(0xFFE5E7EB);
  static const _panelBg = Color(0xFFF3F4F6);

  @override
  void initState() {
    super.initState();
    _qty = widget.line.quantity;
  }

  @override
  void didUpdateWidget(covariant VendorMarketplaceLineProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.line.id != widget.line.id ||
        oldWidget.line.quantity != widget.line.quantity) {
      _qty = widget.line.quantity;
    }
  }

  @override
  void dispose() {
    _qtyReason.dispose();
    super.dispose();
  }

  String _productTitle() {
    final n = widget.line.product.name.trim();
    return n.isEmpty ? 'Product #${widget.line.productId}' : n;
  }

  String _saleLine() {
    final u = widget.line.unitPrice?.trim() ?? '';
    final tp = widget.line.totalPay?.trim() ?? '';
    final salePart = u.isNotEmpty ? u : widget.line.salePrice.toString();
    final payPart = tp.isNotEmpty ? tp : widget.line.salePrice.toString();
    return 'Sale: $salePart · Total pay: $payPart · Qty: ${widget.line.quantity}';
  }

  String _vendorLine() {
    final v = widget.line.vendorName?.trim();
    if (v != null && v.isNotEmpty) {
      return 'Vendor: $v · Line #${widget.line.id}';
    }
    return 'Line #${widget.line.id}';
  }

  String _driverLabel() {
    final d = widget.line.driver;
    if (d != null && d.id > 0) {
      final n = d.name.trim();
      return n.isNotEmpty ? n : 'Driver #${d.id}';
    }
    return '—';
  }

  String _statusLabel(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '—';
    return t
        .split(RegExp(r'[\s_]+'))
        .where((w) => w.isNotEmpty)
        .map(
          (w) =>
              '${w[0].toUpperCase()}${w.length > 1 ? w.substring(1).toLowerCase() : ''}',
        )
        .join(' ');
  }

  bool get _lineClosed {
    final s = widget.line.status.toLowerCase().trim();
    return s == 'cancelled' ||
        s == 'canceled' ||
        s == 'completed' ||
        s == 'complete';
  }

  bool get _canCancel => !_lineClosed;

  bool get _canEditQuantity => !_lineClosed;

  bool get _qtyDirty => _qty != widget.line.quantity;

  bool get _canApplyQty =>
      !_qtyBusy && _qtyDirty && _qtyReason.text.trim().isNotEmpty;

  Future<void> _confirmCancel() async {
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Cancel line',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'This removes line #${widget.line.id} from the order.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AllColor.grey500,
                height: 1.4,
              ),
            ),
            SizedBox(height: 14.h),
            TextField(
              controller: reason,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Reason *',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: AllColor.grey300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(
                    color: AllColor.loginButtomColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Back',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AllColor.grey500,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AllColor.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel line'),
          ),
        ],
      ),
    );
    final r = reason.text.trim();
    reason.dispose();
    if (ok != true || !mounted) return;
    if (r.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: 'Reason required',
        message: 'Enter a cancellation reason.',
        type: CustomSnackType.error,
      );
      return;
    }
    setState(() => _cancelBusy = true);
    var poppedRoute = false;
    try {
      await VendorOrderApi.instance.cancelMarketplaceLine(
        invoiceItemId: widget.line.id,
        reason: r,
      );
      if (!mounted) return;
      GlobalSnackbar.show(
        context,
        title: 'Cancelled',
        message: 'Line removed',
        type: CustomSnackType.success,
      );
      if (widget.line.id == widget.screenLineId) {
        context.pop(true);
        poppedRoute = true;
      } else {
        await widget.onRefresh();
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
      // After [context.pop], this State can still report [mounted] until the next
      // frame; calling [setState] then trips framework assertions.
      if (mounted && !poppedRoute) {
        setState(() => _cancelBusy = false);
      }
    }
  }

  Future<void> _applyQuantity() async {
    final reason = _qtyReason.text.trim();
    if (!_qtyDirty) {
      GlobalSnackbar.show(
        context,
        title: 'No change',
        message: 'Use + / − to change quantity first.',
        type: CustomSnackType.error,
      );
      return;
    }
    if (reason.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: 'Reason required',
        message: 'Enter why the quantity is changing.',
        type: CustomSnackType.error,
      );
      return;
    }
    if (_qty < 1) {
      GlobalSnackbar.show(
        context,
        title: 'Invalid quantity',
        message: 'Quantity must be at least 1.',
        type: CustomSnackType.error,
      );
      return;
    }
    setState(() => _qtyBusy = true);
    try {
      await VendorOrderApi.instance.patchMarketplaceLineQuantity(
        invoiceItemId: widget.line.id,
        quantity: _qty,
        reason: reason,
      );
      if (!mounted) return;
      GlobalSnackbar.show(
        context,
        title: 'Updated',
        message: 'Quantity saved',
        type: CustomSnackType.success,
      );
      _qtyReason.clear();
      await widget.onRefresh();
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
      if (mounted) setState(() => _qtyBusy = false);
    }
  }

  Widget _statusBadge() {
    final label = _statusLabel(widget.line.status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AllColor.orange50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AllColor.loginButtomColor.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: AllColor.loginButtomColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  InputBorder _qtyFieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
        decoration: BoxDecoration(
          color: AllColor.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${widget.indexOneBased}. ${_productTitle()}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: _titleColor,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (_canCancel) ...[
                  SizedBox(width: 8.w),
                  OutlinedButton(
                    onPressed: _cancelBusy ? null : _confirmCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB91C1C),
                      side: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 1.2,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      minimumSize: Size(0, 36.h),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: _cancelBusy
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFEF4444),
                            ),
                          )
                        : Text(
                            'Cancel line',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              _vendorLine(),
              style: TextStyle(
                fontSize: 12.sp,
                color: AllColor.grey500,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              _saleLine(),
              style: TextStyle(
                fontSize: 12.sp,
                color: AllColor.grey.shade600,
                height: 1.35,
              ),
            ),
            if (widget.line.lineNote != null &&
                widget.line.lineNote!.trim().isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                'Note: ${widget.line.lineNote!.trim()}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AllColor.grey.shade600,
                  fontStyle: FontStyle.italic,
                  height: 1.35,
                ),
              ),
            ],
            SizedBox(height: 14.h),
            Divider(height: 1, thickness: 1, color: AllColor.grey200),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Wrap(
                spacing: 16.w,
                runSpacing: 8.h,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AllColor.grey500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _statusBadge(),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Driver',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AllColor.grey500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _driverLabel(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: _titleColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_canEditQuantity) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
                decoration: BoxDecoration(
                  color: _panelBg,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: _cardBorder.withValues(alpha: 0.7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AllColor.grey500,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.35,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _stepButton(
                          icon: Icons.remove_rounded,
                          onTap: _qtyBusy
                              ? null
                              : () => setState(
                                  () => _qty = (_qty - 1).clamp(1, 99999),
                                ),
                        ),
                        Container(
                          constraints: BoxConstraints(minWidth: 36.w),
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            vertical: 6.h,
                            horizontal: 8.w,
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 6.w),
                          decoration: BoxDecoration(
                            color: AllColor.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: _cardBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            '$_qty',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: _titleColor,
                            ),
                          ),
                        ),
                        _stepButton(
                          icon: Icons.add_rounded,
                          onTap: _qtyBusy
                              ? null
                              : () => setState(
                                  () => _qty = (_qty + 1).clamp(1, 99999),
                                ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Reason required to apply',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AllColor.grey500,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: _qtyReason,
                      enabled: !_qtyBusy,
                      maxLines: 2,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(fontSize: 13.sp, color: _titleColor),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Reason for quantity change (required)',
                        hintStyle: TextStyle(
                          fontSize: 12.sp,
                          color: AllColor.grey.shade400,
                        ),
                        filled: true,
                        fillColor: AllColor.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 9.h,
                        ),
                        border: _qtyFieldBorder(AllColor.orange200),
                        enabledBorder: _qtyFieldBorder(AllColor.orange200),
                        focusedBorder: _qtyFieldBorder(
                          AllColor.loginButtomColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _canApplyQty ? _applyQuantity : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AllColor.loginButtomColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AllColor.grey300,
                          disabledForegroundColor: AllColor.grey500,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          elevation: _canApplyQty ? 0 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: _qtyBusy
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Apply quantity',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stepButton({required IconData icon, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return Material(
      color: AllColor.white,
      borderRadius: BorderRadius.circular(8.r),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: 36.w,
          height: 36.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: enabled ? _cardBorder : AllColor.grey200),
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: enabled ? _titleColor : AllColor.grey.shade400,
          ),
        ),
      ),
    );
  }
}
