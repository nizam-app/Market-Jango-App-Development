import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/vendor_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/models/global_search_model.dart';
import 'package:market_jango/core/widget/global_search_bar.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/data/global_search_riverpod.dart';
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
  final _customerPaid = TextEditingController();

  /// `true` = Cash; `false` = Card / Mobile (online).
  bool _payCash = true;
  /// Stored value must match API: `Card` or `Mobile`.
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
    _customerPaid.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  /// API expects `Cash`, `Card`, or `Mobile` (see `createManualOrder`).
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

  /// Full border/label overrides so this screen matches itself — global
  /// [ThemeData.inputDecorationTheme] uses pill radius (50) and gold borders.
  InputDecoration _fieldDeco(String label, {String? hint}) {
    final radius = BorderRadius.circular(10.r);
    final idle = BorderSide(color: AllColor.grey200, width: 1);
    final focus = BorderSide(color: AllColor.loginButtomColor, width: 1.5);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(
        color: AllColor.grey500,
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: AllColor.grey500,
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
      ),
      floatingLabelStyle: TextStyle(
        color: AllColor.black87,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: AllColor.white,
      isDense: true,
      border: OutlineInputBorder(borderRadius: radius, borderSide: idle),
      enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: idle),
      focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: focus),
      disabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: idle),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AllColor.red200, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AllColor.red200, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WALK IN',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AllColor.black,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Add line items below, then customer & payment. Saved via POST /api/vendor/manual-orders.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AllColor.grey500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.table_rows_rounded, color: AllColor.loginButtomColor, size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                'Order line items',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.sp),
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
          Text(
            'Add products',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: AllColor.grey500,
            ),
          ),
          SizedBox(height: 8.h),
          Consumer(
            builder: (context, ref, _) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GlobalSearchBar<GlobalSearchResponse,
                        GlobalSearchProduct>(
                      provider: searchProvider,
                      itemsSelector: (res) => res.products,
                      itemBuilder: (context, p) =>
                          ProductSuggestionTile(p: p),
                      onItemSelected: (p) => _addProductById(p.id),
                      hintText: ref.t(VKeys.searchProducts),
                      debounce: const Duration(seconds: 1),
                      minChars: 1,
                      showResults: true,
                      resultsMaxHeight: 380,
                      autofocus: false,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton.filled(
                    onPressed: _loadingCatalog ? null : _openScanner,
                    style: IconButton.styleFrom(
                      backgroundColor: AllColor.loginButtomColor,
                      foregroundColor: AllColor.white,
                      fixedSize: Size(48.r, 48.r),
                    ),
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    tooltip: 'Scan barcode',
                  ),
                ],
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              'Same search as vendor home — type, then tap a product to add.',
              style: TextStyle(
                fontSize: 11.sp,
                color: AllColor.grey500,
                height: 1.3,
              ),
            ),
          ),
          if (_loadingCatalog)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: const Center(child: CircularProgressIndicator()),
            ),
          SizedBox(height: 8.h),
          Text(
            'Customer',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: AllColor.grey500,
            ),
          ),
          SizedBox(height: 8.h),
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
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15.sp,
              color: AllColor.black,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Choose how the customer paid, then enter cash tender if needed.',
            style: TextStyle(fontSize: 12.sp, color: AllColor.grey500, height: 1.3),
          ),
          SizedBox(height: 12.h),
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
            SizedBox(height: 12.h),
            DropdownButtonFormField<String>(
              initialValue: _nonCashMethod,
              decoration: _fieldDeco('Method'),
              items: const [
                DropdownMenuItem(value: 'Card', child: Text('Card')),
                DropdownMenuItem(
                  value: 'Mobile',
                  child: Text('Mobile money'),
                ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _nonCashMethod = v);
              },
            ),
          ],
          if (_payCash) ...[
            SizedBox(height: 14.h),
            _cashTenderCard(
              totalStr: totalStr,
              tender: tender,
              changeStr: changeStr,
            ),
          ],
          SizedBox(height: 16.h),
          _orderStatusInfoCard(),
          SizedBox(height: 20.h),
          FilledButton(
            onPressed: _submitting
                ? null
                : () => _submit(showBill: false),
            style: FilledButton.styleFrom(
              backgroundColor: AllColor.loginButtomColor,
              foregroundColor: AllColor.white,
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
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
              side: BorderSide(color: AllColor.loginButtomColor, width: 1.5),
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: Icon(Icons.receipt_long_outlined, size: 20.sp),
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

  Widget _cashTenderCard({
    required String totalStr,
    required double? tender,
    required String changeStr,
  }) {
    final headerStyle = TextStyle(
      fontSize: 11.sp,
      fontWeight: FontWeight.w800,
      color: AllColor.grey500,
    );
    final valueStyle = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w800,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cash',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15.sp,
            color: AllColor.black,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AllColor.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AllColor.grey200),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: AllColor.grey100,
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                child: Row(
                  children: [
                    Expanded(child: Text('Customer pays', style: headerStyle)),
                    Expanded(
                      child: Text(
                        'Total',
                        textAlign: TextAlign.center,
                        style: headerStyle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Change',
                        textAlign: TextAlign.right,
                        style: headerStyle,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: AllColor.grey200),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customerPaid,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: '0.00',
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: AllColor.grey200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: AllColor.loginButtomColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        totalStr,
                        textAlign: TextAlign.center,
                        style: valueStyle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        tender != null && tender >= _cartTotal
                            ? changeStr
                            : '—',
                        textAlign: TextAlign.right,
                        style: valueStyle.copyWith(
                          color: AllColor.loginButtomColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _orderStatusInfoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15.sp,
            color: AllColor.black,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AllColor.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AllColor.grey200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AllColor.loginButtomColor,
                size: 22.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Saved as a walk-in invoice; line items start as pending until you mark delivered from order detail.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AllColor.black87,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
