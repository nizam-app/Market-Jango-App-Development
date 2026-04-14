import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_barcode/data/vendor_barcode_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_barcode/model/vendor_barcode_models.dart';
import 'package:market_jango/features/vendor/screens/vendor_barcode/util/vendor_barcode_label_pdf.dart';
import 'package:printing/printing.dart';
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
        barrierDismissible: true,
        builder: (ctx) => _BarcodeLabelPreviewDialog(
          result: result,
          onDownloadPdf: () async {
            Navigator.pop(ctx);
            await _downloadLabelTemplatePdf(result);
          },
          onCopyAll: () {
            Clipboard.setData(ClipboardData(text: _formatPrintData(result)));
            Navigator.pop(ctx);
            GlobalSnackbar.show(
              context,
              title: 'Copied',
              message: 'Label text copied',
              type: CustomSnackType.success,
            );
          },
          onClose: () => Navigator.pop(ctx),
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

  Future<void> _downloadLabelTemplatePdf(VendorBarcodeLabelsResult result) async {
    try {
      final bytes = await buildBarcodeLabelTemplatePdf(result);
      if (!mounted) return;
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'barcode_template_product_${result.product.id}.pdf',
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
            icon: const Icon(Icons.download_outlined),
            label: const Text('Download barcode'),
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

/// Polished preview + primary “Download PDF template” action.
class _BarcodeLabelPreviewDialog extends StatelessWidget {
  const _BarcodeLabelPreviewDialog({
    required this.result,
    required this.onDownloadPdf,
    required this.onCopyAll,
    required this.onClose,
  });

  final VendorBarcodeLabelsResult result;
  final VoidCallback onDownloadPdf;
  final VoidCallback onCopyAll;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final d = result.printData;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AllColor.orange50,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.label_outline_rounded,
                      color: AllColor.loginButtomColor,
                      size: 26.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Barcode label',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AllColor.black,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Review details, then download the PDF template.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AllColor.grey500,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              if (d.barcode.isNotEmpty)
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AllColor.grey200),
                  ),
                  child: BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: d.barcode,
                    drawText: true,
                    color: Colors.black,
                    backgroundColor: Colors.white,
                    width: 280.w,
                    height: 112.h,
                    padding: EdgeInsets.all(8.w),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textPadding: 6,
                    errorBuilder: (ctx, err) => Padding(
                      padding: EdgeInsets.all(8.w),
                      child: SelectableText(
                        d.barcode,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AllColor.grey200),
                  ),
                  child: Text(
                    'No barcode to render',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.sp, color: AllColor.grey500),
                  ),
                ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AllColor.grey200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PreviewRow(label: 'Product', value: d.productName),
                    _PreviewRow(label: 'Price', value: d.price.toString()),
                    _PreviewRow(label: 'Vendor', value: d.vendorName),
                    _PreviewRow(label: 'Copies', value: '${d.copies}'),
                    _PreviewRow(
                      label: 'Labels requested',
                      value: '${result.labelCount}',
                      isLast: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              FilledButton.icon(
                onPressed: onDownloadPdf,
                style: FilledButton.styleFrom(
                  backgroundColor: AllColor.loginButtomColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: Icon(Icons.picture_as_pdf_rounded, size: 22.sp),
                label: Text(
                  'Download PDF template',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: onCopyAll,
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 18.sp,
                      color: AllColor.grey500,
                    ),
                    label: Text(
                      'Copy as text',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AllColor.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onClose,
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AllColor.grey500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108.w,
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
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AllColor.black87,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
