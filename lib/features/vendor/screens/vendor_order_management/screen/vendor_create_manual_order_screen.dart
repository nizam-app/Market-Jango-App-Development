import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

class VendorCreateManualOrderScreen extends ConsumerStatefulWidget {
  const VendorCreateManualOrderScreen({super.key, this.presetProductId});

  /// When opening from barcode flow, pre-select this product on the first line.
  final int? presetProductId;

  static const routeName = '/vendor/manual-order/create';

  @override
  ConsumerState<VendorCreateManualOrderScreen> createState() =>
      _VendorCreateManualOrderScreenState();
}

int _pid(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

class _LineRow {
  _LineRow() : qty = TextEditingController(text: '1');
  int? productId;
  final TextEditingController qty;

  void dispose() => qty.dispose();
}

class _VendorCreateManualOrderScreenState
    extends ConsumerState<VendorCreateManualOrderScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _paid = TextEditingController();
  String _payment = 'Cash';
  final List<_LineRow> _lines = [_LineRow()];
  bool _submitting = false;

  List<Map<String, dynamic>> _productChoices = [];
  bool _loadingProducts = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadProducts();
      if (!mounted) return;
      final preset = widget.presetProductId;
      if (preset != null && _lines.isNotEmpty) {
        final exists = _productChoices.any((p) => (p['id'] as int) == preset);
        if (exists) {
          setState(() => _lines[0].productId = preset);
        }
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _paid.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  void _addLine() {
    setState(() => _lines.add(_LineRow()));
  }

  void _removeLine(int i) {
    if (_lines.length <= 1) return;
    setState(() {
      _lines[i].dispose();
      _lines.removeAt(i);
    });
  }

  Future<void> _loadProducts() async {
    setState(() => _loadingProducts = true);
    try {
      final token = await ref.read(authTokenProvider.future);
      if (token == null) throw Exception('Not signed in');
      final uri = Uri.parse('${VendorAPIController.vendor_product}?page=1');
      final res = await http.get(
        uri,
        headers: {'Accept': 'application/json', 'token': token},
      );
      if (res.statusCode != 200) throw Exception('Products ${res.statusCode}');
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = body['data'];
      final list = data is Map && data['data'] is List
          ? (data['data'] as List)
          : data is List
          ? data
          : <dynamic>[];
      final mapped = list
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => {
              'id': _pid(e['id']),
              'name': e['name']?.toString() ?? '',
            },
          )
          .where((e) => (e['id'] as int) > 0)
          .toList();
      if (mounted) setState(() => _productChoices = mapped);
    } catch (_) {
      if (mounted) setState(() => _productChoices = []);
    } finally {
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) {
      GlobalSnackbar.show(
        context,
        title: 'Required',
        message: 'Customer name is required',
        type: CustomSnackType.error,
      );
      return;
    }
    final items = <Map<String, int>>[];
    for (final l in _lines) {
      final pid = l.productId;
      final q = int.tryParse(l.qty.text.trim()) ?? 0;
      if (pid != null && pid > 0 && q > 0) {
        items.add({'product_id': pid, 'quantity': q});
      }
    }
    if (items.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: 'Items',
        message: 'Add at least one product line',
        type: CustomSnackType.error,
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await VendorOrderApi.instance.createManualOrder(
        customerName: _name.text.trim(),
        customerPhone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        paymentMethod: _payment,
        customerPaid: _paid.text.trim().isEmpty
            ? null
            : double.tryParse(_paid.text.trim()),
        items: items,
      );
      if (mounted) context.pop(true);
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
          'New walk-in order',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Customer name *',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: _phone,
            decoration: const InputDecoration(
              labelText: 'Phone (optional)',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),
          DropdownButtonFormField<String>(
            initialValue: _payment,
            decoration: const InputDecoration(
              labelText: 'Payment method',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: const [
              DropdownMenuItem(value: 'Cash', child: Text('Cash')),
              DropdownMenuItem(value: 'Card', child: Text('Card')),
              DropdownMenuItem(value: 'Mobile', child: Text('Mobile')),
            ],
            onChanged: (v) => setState(() => _payment = v ?? 'Cash'),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: _paid,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Customer paid (optional)',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Text(
                'Products',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.sp),
              ),
              const Spacer(),
              if (_loadingProducts)
                SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              TextButton(onPressed: _loadProducts, child: const Text('Refresh')),
            ],
          ),
          SizedBox(height: 8.h),
          ...List.generate(_lines.length, (i) {
            final line = _lines[i];
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _productChoices.isEmpty
                        ? InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Product',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            child: Text(
                              'No products — tap Refresh',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AllColor.grey500,
                              ),
                            ),
                          )
                        : DropdownButtonFormField<int>(
                            initialValue: line.productId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Product',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: _productChoices
                                .map(
                                  (p) => DropdownMenuItem<int>(
                                    value: p['id'] as int,
                                    child: Text(
                                      p['name'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() => line.productId = v);
                            },
                          ),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    width: 72.w,
                    child: TextField(
                      controller: line.qty,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Qty',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _lines.length <= 1 ? null : () => _removeLine(i),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                ],
              ),
            );
          }),
          OutlinedButton.icon(
            onPressed: _addLine,
            icon: const Icon(Icons.add),
            label: const Text('Add line'),
          ),
          SizedBox(height: 24.h),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AllColor.loginButtomColor,
              minimumSize: Size(double.infinity, 48.h),
            ),
            child: _submitting
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Create order'),
          ),
        ],
      ),
    );
  }
}
