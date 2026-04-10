import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_barcode/data/vendor_barcode_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_barcode/screen/vendor_barcode_scan_screen.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/vendor_order_auth.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

/// Walk-in / POS manual order — `POST /vendor/manual-orders` ([doc/details.md]).
class VendorCreateManualOrderScreen extends StatefulWidget {
  const VendorCreateManualOrderScreen({super.key, this.presetProductId});

  final int? presetProductId;

  static const routeName = '/vendor/manual-order/create';

  @override
  State<VendorCreateManualOrderScreen> createState() =>
      _VendorCreateManualOrderScreenState();
}

int _toInt(dynamic v, {int d = 0}) {
  if (v == null) return d;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? d;
}

double _toDouble(dynamic v, {double d = 0}) {
  if (v == null) return d;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString().replaceAll(',', '')) ?? d;
}

class _PosProduct {
  _PosProduct({
    required this.id,
    required this.name,
    required this.sellPrice,
    required this.stock,
    this.sizeLabel,
    this.colorLabel,
  });

  final int id;
  final String name;
  final double sellPrice;
  final int stock;
  final String? sizeLabel;
  final String? colorLabel;
}

class _CartLine {
  _CartLine({required this.product}) : qty = TextEditingController(text: '1');

  final _PosProduct product;
  final TextEditingController qty;

  void dispose() => qty.dispose();
}

class _VendorCreateManualOrderScreenState
    extends State<VendorCreateManualOrderScreen> {
  final _customerName = TextEditingController();
  final _customerPhone = TextEditingController();
  final _search = TextEditingController();
  final _customerPaid = TextEditingController();

  /// `true` = Cash; `false` = Card / Mobile (online).
  bool _payCash = true;
  String _nonCashMethod = 'Card';

  final List<_CartLine> _lines = [];
  List<_PosProduct> _catalog = [];
  bool _loadingCatalog = false;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCatalog();
      if (!mounted) return;
      final preset = widget.presetProductId;
      if (preset != null) {
        await _addProductById(preset);
      }
    });
  }

  @override
  void dispose() {
    _customerName.dispose();
    _customerPhone.dispose();
    _search.dispose();
    _customerPaid.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  String _paymentMethodApi() {
    if (_payCash) return 'Cash';
    return _nonCashMethod;
  }

  double get _cartTotal {
    var sum = 0.0;
    for (final l in _lines) {
      final q = int.tryParse(l.qty.text.trim()) ?? 0;
      if (q > 0) sum += l.product.sellPrice * q;
    }
    return sum;
  }

  double? get _tenderAmount {
    if (!_payCash) return null;
    final t = _customerPaid.text.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t.replaceAll(',', ''));
  }

  double? get _changeDue {
    final tender = _tenderAmount;
    if (tender == null) return null;
    final due = tender - _cartTotal;
    if (due < 0) return null;
    return due;
  }

  Future<void> _loadCatalog() async {
    setState(() => _loadingCatalog = true);
    try {
      final headers = await vendorOrderApiHeaders();
      final uri = Uri.parse('${VendorAPIController.vendor_product}?page=1');
      final res = await http.get(uri, headers: headers);
      if (res.statusCode != 200) {
        throw Exception('Products HTTP ${res.statusCode}');
      }
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = body['data'];
      final list = data is Map && data['data'] is List
          ? (data['data'] as List)
          : data is List
              ? data
              : <dynamic>[];
      final mapped = <_PosProduct>[];
      for (final e in list.whereType<Map<String, dynamic>>()) {
        final id = _toInt(e['id']);
        if (id <= 0) continue;
        final name = e['name']?.toString() ?? 'Product $id';
        final price = _toDouble(e['sell_price'] ?? e['price'] ?? e['regular_price']);
        final stock = _toInt(e['stock'] ?? e['quantity']);
        String? size;
        String? color;
        final pv = e['product_variation'];
        if (pv is Map<String, dynamic>) {
          size ??= pv['size']?.toString();
          color ??= pv['color']?.toString();
        }
        final attrs = e['attributes'];
        if (attrs is List) {
          for (final a in attrs.whereType<Map<String, dynamic>>()) {
            final n = a['name']?.toString().toLowerCase() ?? '';
            final val = a['value']?.toString() ?? a['attribute_value']?.toString();
            if (val == null || val.isEmpty) continue;
            if (n.contains('size')) size = val;
            if (n.contains('color') || n.contains('colour')) color = val;
          }
        }
        mapped.add(
          _PosProduct(
            id: id,
            name: name,
            sellPrice: price,
            stock: stock,
            sizeLabel: size,
            colorLabel: color,
          ),
        );
      }
      if (mounted) setState(() => _catalog = mapped);
    } catch (_) {
      if (mounted) setState(() => _catalog = []);
    } finally {
      if (mounted) setState(() => _loadingCatalog = false);
    }
  }

  _PosProduct? _findInCatalog(int id) {
    for (final p in _catalog) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<_PosProduct?> _resolveProduct(int id) async {
    final local = _findInCatalog(id);
    if (local != null) return local;
    try {
      final b = await VendorBarcodeApi.instance.fetchProductBarcode(id);
      return _PosProduct(
        id: b.id,
        name: b.name,
        sellPrice: b.sellPrice,
        stock: b.stock,
        sizeLabel: null,
        colorLabel: null,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _addProductById(int id) async {
    final p = await _resolveProduct(id);
    if (!mounted) return;
    if (p == null) {
      GlobalSnackbar.show(
        context,
        title: 'Product',
        message: 'Could not load product #$id',
        type: CustomSnackType.error,
      );
      return;
    }
    _addOrIncrementLine(p);
  }

  void _addOrIncrementLine(_PosProduct p) {
    for (final l in _lines) {
      if (l.product.id == p.id) {
        final q = int.tryParse(l.qty.text.trim()) ?? 0;
        l.qty.text = '${q + 1}';
        setState(() {});
        return;
      }
    }
    setState(() => _lines.add(_CartLine(product: p)));
  }

  void _pickProductFromSearch() {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: 'Search',
        message: 'Type a product name to search',
        type: CustomSnackType.warning,
      );
      return;
    }
    final matches = _catalog
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
    if (matches.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: 'Search',
        message: 'No products match “$q”',
        type: CustomSnackType.warning,
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'Pick product',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
                ),
              ),
              ...matches.take(40).map(
                    (p) => ListTile(
                      title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        'USD ${p.sellPrice.toStringAsFixed(2)} · stock ${p.stock}',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _addOrIncrementLine(p);
                        _search.clear();
                      },
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openScanner() async {
    final id = await context.push<int?>(
      VendorBarcodeScanScreen.routeName,
      extra: true,
    );
    if (!mounted || id == null) return;
    await _addProductById(id);
  }

  void _removeLine(int i) {
    setState(() {
      _lines[i].dispose();
      _lines.removeAt(i);
    });
  }

  Future<void> _submit({required bool showBill}) async {
    final name = _customerName.text.trim();
    if (name.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: 'Required',
        message: 'Customer name is required',
        type: CustomSnackType.error,
      );
      return;
    }
    if (name.length > 100) {
      GlobalSnackbar.show(
        context,
        title: 'Name',
        message: 'Customer name must be at most 100 characters',
        type: CustomSnackType.error,
      );
      return;
    }
    final items = <Map<String, int>>[];
    for (final l in _lines) {
      final q = int.tryParse(l.qty.text.trim()) ?? 0;
      if (q <= 0) continue;
      if (q > l.product.stock) {
        GlobalSnackbar.show(
          context,
          title: 'Stock',
          message: '${l.product.name}: max ${l.product.stock}',
          type: CustomSnackType.error,
        );
        return;
      }
      items.add({'product_id': l.product.id, 'quantity': q});
    }
    if (items.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: 'Cart',
        message: 'Add at least one product',
        type: CustomSnackType.error,
      );
      return;
    }

    double? paidApi;
    if (_payCash) {
      final t = _customerPaid.text.trim();
      paidApi = t.isEmpty ? null : double.tryParse(t.replaceAll(',', ''));
      if (paidApi != null) {
        if (paidApi < 0) {
          GlobalSnackbar.show(
            context,
            title: 'Cash',
            message: 'Customer paid must be zero or greater',
            type: CustomSnackType.error,
          );
          return;
        }
        if (paidApi < _cartTotal) {
          GlobalSnackbar.show(
            context,
            title: 'Cash',
            message: 'Customer amount is less than total',
            type: CustomSnackType.error,
          );
          return;
        }
      }
    }

    final phone = _customerPhone.text.trim();
    if (phone.length > 30) {
      GlobalSnackbar.show(
        context,
        title: 'Phone',
        message: 'Phone must be at most 30 characters',
        type: CustomSnackType.error,
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final inv = await VendorOrderApi.instance.createManualOrder(
        customerName: name,
        customerPhone: phone.isEmpty ? null : phone,
        paymentMethod: _paymentMethodApi(),
        customerPaid: paidApi,
        items: items,
      );
      if (!mounted) return;
      if (showBill) {
        await _showBillSheet(inv);
      }
      if (mounted) context.pop(inv.id);
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
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _showBillSheet(VendorManualOrderInvoice inv) async {
    final buf = StringBuffer()
      ..writeln('WALK-IN — ${inv.orderNumber}')
      ..writeln('Customer: ${inv.customerName ?? '—'}')
      ..writeln('Payment: ${inv.paymentMethod ?? _paymentMethodApi()}')
      ..writeln('---');
    for (final line in inv.items) {
      buf.writeln(
        '${line.productName ?? 'Item'} × ${line.quantity}  (${line.status})',
      );
    }
    buf
      ..writeln('---')
      ..writeln('Payable: ${inv.summary.payable}')
      ..writeln(
        'Paid: ${inv.summary.customerPaid ?? '—'}  Change: ${inv.summary.change ?? '—'}',
      );

    final text = buf.toString();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Print bill',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
        ),
        content: SingleChildScrollView(child: SelectableText(text)),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                GlobalSnackbar.show(
                  context,
                  title: 'Copied',
                  message: 'Bill text copied to clipboard',
                  type: CustomSnackType.success,
                );
              }
            },
            child: const Text('Copy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: AllColor.loginButtomColor,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDeco(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AllColor.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalStr = _cartTotal.toStringAsFixed(2);
    final tender = _tenderAmount;
    final changeStr = _changeDue != null
        ? _changeDue!.toStringAsFixed(2)
        : (tender != null && tender < _cartTotal ? '—' : '—');

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
          'New walk-in order',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
            decoration: BoxDecoration(
              color: AllColor.orange50.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AllColor.orange200),
            ),
            child: Text(
              'WALK IN',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: AllColor.black,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          TextField(
            controller: _customerName,
            textCapitalization: TextCapitalization.words,
            maxLength: 100,
            buildCounter: (
              context, {
              required currentLength,
              required isFocused,
              maxLength,
            }) =>
                const SizedBox.shrink(),
            decoration: _fieldDeco('NAME', hint: 'Customer name (required)'),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _customerPhone,
            keyboardType: TextInputType.phone,
            maxLength: 30,
            buildCounter: (
              context, {
              required currentLength,
              required isFocused,
              maxLength,
            }) =>
                const SizedBox.shrink(),
            decoration: _fieldDeco(
              'Phone',
              hint: 'Optional (e.g. +254700123456)',
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'SEARCH by (product / scan)',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AllColor.grey500,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _pickProductFromSearch(),
                  decoration: _fieldDeco(
                    'Search products',
                    hint: 'Type name, then Enter',
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              IconButton.filled(
                onPressed: _loadingCatalog ? null : _openScanner,
                style: IconButton.styleFrom(
                  backgroundColor: AllColor.loginButtomColor,
                  foregroundColor: AllColor.white,
                ),
                icon: const Icon(Icons.qr_code_scanner_rounded),
                tooltip: 'Scan barcode',
              ),
            ],
          ),
          TextButton.icon(
            onPressed: _loadingCatalog ? null : _pickProductFromSearch,
            icon: const Icon(Icons.add_shopping_cart_outlined),
            label: const Text('Add from search'),
          ),
          if (_loadingCatalog)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: const Center(child: CircularProgressIndicator()),
            ),
          Row(
            children: [
              Text(
                'Order lines',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.sp),
              ),
              const Spacer(),
              TextButton(
                onPressed: _loadCatalog,
                child: const Text('Refresh catalog'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _linesTableCard(),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
            decoration: BoxDecoration(
              color: AllColor.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AllColor.grey200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total amount',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'USD $totalStr',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: AllColor.loginButtomColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Payment',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _payOptionTile(
                  label: 'Pay by cash',
                  selected: _payCash,
                  onTap: () => setState(() => _payCash = true),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _payOptionTile(
                  label: 'Pay online / card',
                  selected: !_payCash,
                  onTap: () => setState(() => _payCash = false),
                ),
              ),
            ],
          ),
          if (!_payCash) ...[
            SizedBox(height: 10.h),
            DropdownButtonFormField<String>(
              value: _nonCashMethod,
              decoration: _fieldDeco('Method'),
              items: const [
                DropdownMenuItem(value: 'Card', child: Text('Card')),
                DropdownMenuItem(value: 'Mobile', child: Text('Mobile money')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _nonCashMethod = v);
              },
            ),
          ],
          if (_payCash) ...[
            SizedBox(height: 14.h),
            Text(
              'Cash',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp),
            ),
            SizedBox(height: 8.h),
            Table(
              border: TableBorder.all(color: AllColor.grey200),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: AllColor.grey100),
                  children: [
                    _tableHeader('Customer pays'),
                    _tableHeader('Total'),
                    _tableHeader('Change'),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(6.w),
                      child: TextField(
                        controller: _customerPaid,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.00',
                          isDense: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Text(
                        totalStr,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Text(
                        tender != null && tender >= _cartTotal
                            ? changeStr
                            : '—',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AllColor.loginButtomColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          SizedBox(height: 16.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
            subtitle: Text(
              'Saved as a walk-in invoice; line items start as pending until you mark delivered from order detail.',
              style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
            ),
            trailing: Icon(Icons.chevron_right, color: AllColor.grey500),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
              side: BorderSide(color: AllColor.grey200),
            ),
            tileColor: AllColor.white,
          ),
          SizedBox(height: 20.h),
          FilledButton(
            onPressed: _submitting
                ? null
                : () => _submit(showBill: false),
            style: FilledButton.styleFrom(
              backgroundColor: AllColor.loginButtomColor,
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'Create order',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          OutlinedButton.icon(
            onPressed: _submitting
                ? null
                : () => _submit(showBill: true),
            style: OutlinedButton.styleFrom(
              foregroundColor: AllColor.loginButtomColor,
              side: BorderSide(color: AllColor.loginButtomColor),
              minimumSize: Size(double.infinity, 46.h),
            ),
            icon: const Icon(Icons.receipt_long_outlined),
            label: Text(
              'Create order & preview bill',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (_submitting)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _tableHeader(String t) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Text(
        t,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _payOptionTile({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AllColor.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? AllColor.loginButtomColor : AllColor.grey200,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AllColor.loginButtomColor : AllColor.grey500,
                size: 22,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linesTableCard() {
    if (_lines.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AllColor.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AllColor.grey200),
        ),
        child: Text(
          'No lines yet — search or scan to add products.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AllColor.grey500, fontSize: 13.sp),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AllColor.grey200),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 6.h),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Product',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: AllColor.grey500,
                    ),
                  ),
                ),
                SizedBox(
                  width: 36.w,
                  child: Text(
                    'QTY',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: AllColor.grey500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 44.w,
                  child: Text(
                    'SIZE',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: AllColor.grey500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 44.w,
                  child: Text(
                    'COLOUR',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: AllColor.grey500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 52.w,
                  child: Text(
                    'AMT',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: AllColor.grey500,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...List.generate(_lines.length, (i) {
            final line = _lines[i];
            final q = int.tryParse(line.qty.text.trim()) ?? 0;
            final amt = (q > 0 ? line.product.sellPrice * q : 0).toStringAsFixed(0);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          line.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 36.w,
                        child: TextField(
                          controller: line.qty,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.sp),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 6),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      SizedBox(
                        width: 44.w,
                        child: Text(
                          line.product.sizeLabel?.isNotEmpty == true
                              ? line.product.sizeLabel!
                              : '—',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10.sp),
                        ),
                      ),
                      SizedBox(
                        width: 44.w,
                        child: Text(
                          line.product.colorLabel?.isNotEmpty == true
                              ? line.product.colorLabel!
                              : '—',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10.sp),
                        ),
                      ),
                      SizedBox(
                        width: 52.w,
                        child: Text(
                          amt,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: AllColor.loginButtomColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
                  child: Wrap(
                    spacing: 12.w,
                    children: [
                      TextButton(
                        onPressed: i >= _lines.length - 1
                            ? null
                            : () {
                                setState(() {
                                  final t = _lines.removeAt(i);
                                  _lines.insert(i + 1, t);
                                });
                              },
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AllColor.blue500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _removeLine(i),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AllColor.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < _lines.length - 1) const Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}
