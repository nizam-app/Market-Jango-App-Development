import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';

/// Walk-in / manual invoice line — same visual language as marketplace line card.
class VendorManualOrderLineCard extends StatefulWidget {
  const VendorManualOrderLineCard({
    super.key,
    required this.item,
    required this.indexOneBased,
    required this.invoiceId,
    required this.canEdit,
    required this.onRefresh,
  });

  final VendorManualLineItem item;
  final int indexOneBased;
  final int invoiceId;
  final bool canEdit;
  final Future<void> Function() onRefresh;

  @override
  State<VendorManualOrderLineCard> createState() =>
      _VendorManualOrderLineCardState();
}

class _VendorManualOrderLineCardState extends State<VendorManualOrderLineCard> {
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
    _qty = widget.item.quantity;
  }

  @override
  void didUpdateWidget(covariant VendorManualOrderLineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.quantity != widget.item.quantity) {
      _qty = widget.item.quantity;
    }
  }

  @override
  void dispose() {
    _qtyReason.dispose();
    super.dispose();
  }

  String _productTitle() {
    final n = (widget.item.productName ?? '').trim();
    return n.isEmpty ? 'Product #${widget.item.productId}' : n;
  }

  String _saleLine() {
    final u = widget.item.unitPrice?.trim() ?? '';
    final tp = widget.item.totalPay?.trim() ?? '';
    final sp = widget.item.salePrice;
    final salePart = u.isNotEmpty ? u : (sp != null ? '$sp' : '—');
    final payPart = tp.isNotEmpty ? tp : (sp != null ? '$sp' : '—');
    return 'Sale: $salePart · Total pay: $payPart · Qty: ${widget.item.quantity}';
  }

  bool get _qtyDirty => _qty != widget.item.quantity;

  bool get _canApplyQty =>
      !_qtyBusy && _qtyDirty && _qtyReason.text.trim().isNotEmpty;

  InputBorder _qtyFieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Future<void> _confirmCancel() async {
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Cancel line',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Remove this product line from the walk-in order.',
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: AllColor.grey300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: AllColor.loginButtomColor, width: 1.5),
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
              style: TextStyle(fontWeight: FontWeight.w600, color: AllColor.grey500),
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
    try {
      await VendorOrderApi.instance.deleteManualOrderItem(
        invoiceId: widget.invoiceId,
        itemId: widget.item.id,
      );
      if (!mounted) return;
      GlobalSnackbar.show(
        context,
        title: 'Removed',
        message: 'Line cancelled',
        type: CustomSnackType.success,
      );
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
      if (mounted) setState(() => _cancelBusy = false);
    }
  }

  Future<void> _applyQuantity() async {
    if (!_qtyDirty) {
      GlobalSnackbar.show(
        context,
        title: 'No change',
        message: 'Use + / − to change quantity first.',
        type: CustomSnackType.error,
      );
      return;
    }
    final reason = _qtyReason.text.trim();
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
      final it = widget.item;
      if (_qty > it.quantity) {
        await VendorOrderApi.instance.addManualOrderItem(
          invoiceId: widget.invoiceId,
          productId: it.productId,
          quantity: _qty - it.quantity,
        );
      } else {
        await VendorOrderApi.instance.deleteManualOrderItem(
          invoiceId: widget.invoiceId,
          itemId: it.id,
        );
        await VendorOrderApi.instance.addManualOrderItem(
          invoiceId: widget.invoiceId,
          productId: it.productId,
          quantity: _qty,
        );
      }
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

  Widget _statusBadge() {
    final label = _statusLabel(widget.item.status);
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
                if (widget.canEdit) ...[
                  SizedBox(width: 8.w),
                  OutlinedButton(
                    onPressed: _cancelBusy ? null : _confirmCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB91C1C),
                      side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
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
              'Line #${widget.item.id}',
              style: TextStyle(
                fontSize: 12.sp,
                color: AllColor.grey500,
                fontWeight: FontWeight.w500,
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
            if (widget.item.lineNote != null &&
                widget.item.lineNote!.trim().isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                'Note: ${widget.item.lineNote!.trim()}',
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
                        '—',
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
            if (widget.canEdit) ...[
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: 36.w,
          height: 36.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: enabled ? _cardBorder : AllColor.grey200,
            ),
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
