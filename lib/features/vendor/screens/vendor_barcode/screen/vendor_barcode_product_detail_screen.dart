import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_barcode/data/vendor_barcode_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_barcode/model/vendor_barcode_models.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/screen/vendor_create_manual_order_screen.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

class VendorBarcodeProductDetailScreen extends StatefulWidget {
  const VendorBarcodeProductDetailScreen({super.key, required this.productId});

  final int productId;

  static String routePath(int id) => '/vendor/barcodes/product/$id';

  @override
  State<VendorBarcodeProductDetailScreen> createState() =>
      _VendorBarcodeProductDetailScreenState();
}

class _VendorBarcodeProductDetailScreenState
    extends State<VendorBarcodeProductDetailScreen> {
  VendorBarcodeProduct? _product;
  bool _loading = true;
  String? _error;
  bool _actionBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await VendorBarcodeApi.instance.fetchProductBarcode(widget.productId);
      if (mounted) setState(() => _product = p);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _regenerate() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New barcode?'),
        content: const Text(
          'This replaces the current barcode on the server. Old printed labels will no longer match.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Regenerate', style: TextStyle(color: AllColor.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _actionBusy = true);
    try {
      final p = await VendorBarcodeApi.instance.regenerateBarcode(widget.productId);
      if (mounted) {
        setState(() => _product = p);
        GlobalSnackbar.show(
          context,
          title: 'Updated',
          message: 'New barcode saved',
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
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _printLabels() async {
    final countCtrl = TextEditingController(text: '1');
    final submitted = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Label count'),
        content: TextField(
          controller: countCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '1–500',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final n = int.tryParse(countCtrl.text.trim()) ?? 0;
              Navigator.pop(ctx, n);
            },
            child: const Text('Get print data'),
          ),
        ],
      ),
    );
    if (submitted == null || submitted < 1 || submitted > 500) return;

    setState(() => _actionBusy = true);
    try {
      final result = await VendorBarcodeApi.instance.fetchLabelPayload(
        productId: widget.productId,
        labelCount: submitted,
      );
      if (!mounted) return;
      if (result.product.id != 0) {
        setState(() => _product = result.product);
      }
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Print label data'),
          content: SingleChildScrollView(
            child: SelectableText(
              _formatPrintData(result),
              style: TextStyle(fontSize: 13.sp, fontFamily: 'monospace'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _formatPrintData(result)));
                Navigator.pop(ctx);
                GlobalSnackbar.show(
                  context,
                  title: 'Copied',
                  message: 'Label text copied',
                  type: CustomSnackType.success,
                );
              },
              child: const Text('Copy all'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
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
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  String _formatPrintData(VendorBarcodeLabelsResult r) {
    final d = r.printData;
    return 'barcode: ${d.barcode}\n'
        'product_name: ${d.productName}\n'
        'price: ${d.price}\n'
        'vendor_name: ${d.vendorName}\n'
        'copies: ${d.copies}\n'
        'label_count: ${r.labelCount}';
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
          'Barcode',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
        actions: [
          if (!_loading && _error == null)
            IconButton(
              tooltip: 'Refresh',
              onPressed: _actionBusy ? null : _load,
              icon: const Icon(Icons.refresh),
            ),
        ],
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
          : _buildBody(_product!),
    );
  }

  Widget _buildBody(VendorBarcodeProduct p) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Material(
            color: AllColor.white,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name.isEmpty ? 'Product #${p.id}' : p.name,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Barcode',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AllColor.grey500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  SelectableText(
                    p.barcode.isEmpty ? '—' : p.barcode,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Sell ${p.sellPrice} · Regular ${p.regularPrice} · Stock ${p.stock}',
                    style: TextStyle(fontSize: 13.sp, color: AllColor.grey500),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          FilledButton.icon(
            onPressed: _actionBusy || p.barcode.isEmpty
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: p.barcode));
                    GlobalSnackbar.show(
                      context,
                      title: 'Copied',
                      message: 'Barcode copied',
                      type: CustomSnackType.success,
                    );
                  },
            style: FilledButton.styleFrom(
              backgroundColor: AllColor.loginButtomColor,
              minimumSize: Size(double.infinity, 48.h),
            ),
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Copy barcode'),
          ),
          SizedBox(height: 10.h),
          OutlinedButton.icon(
            onPressed: _actionBusy ? null : _regenerate,
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
            ),
            icon: const Icon(Icons.autorenew),
            label: const Text('Regenerate barcode'),
          ),
          SizedBox(height: 10.h),
          OutlinedButton.icon(
            onPressed: _actionBusy ? null : _printLabels,
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
            ),
            icon: const Icon(Icons.label_outline),
            label: const Text('Print label data'),
          ),
          SizedBox(height: 10.h),
          OutlinedButton.icon(
            onPressed: _actionBusy
                ? null
                : () {
                    context.push(
                      VendorCreateManualOrderScreen.routeName,
                      extra: p.id,
                    );
                  },
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
            ),
            icon: const Icon(Icons.point_of_sale),
            label: const Text('New walk-in order with this product'),
          ),
          SizedBox(height: 24.h),
          Text(
            'Scan this product with “Barcodes → Scan”, or add it to a walk-in order using the button above.',
            style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
          ),
        ],
      ),
    );
  }
}
