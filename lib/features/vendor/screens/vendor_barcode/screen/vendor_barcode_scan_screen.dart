import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_barcode/data/vendor_barcode_api.dart';
import 'vendor_barcode_product_detail_screen.dart';

class VendorBarcodeScanScreen extends StatefulWidget {
  const VendorBarcodeScanScreen({
    super.key,
    this.returnProductIdOnSuccess = false,
  });

  /// When true (e.g. opened from walk-in POS), successful lookup pops with
  /// `Navigator.pop(context, productId)` instead of opening product detail.
  final bool returnProductIdOnSuccess;

  static const routeName = '/vendor/barcodes/scan';

  @override
  State<VendorBarcodeScanScreen> createState() => _VendorBarcodeScanScreenState();
}

class _VendorBarcodeScanScreenState extends State<VendorBarcodeScanScreen> {
  late final MobileScannerController _controller;
  final _manual = TextEditingController();
  bool _busy = false;
  DateTime? _lastDetect;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _manual.dispose();
    super.dispose();
  }

  Future<void> _lookup(String raw) async {
    final code = raw.trim();
    if (code.isEmpty || _busy) return;
    final now = DateTime.now();
    if (_lastDetect != null &&
        now.difference(_lastDetect!) < const Duration(milliseconds: 1200)) {
      return;
    }
    _lastDetect = now;

    setState(() => _busy = true);
    try {
      final product = await VendorBarcodeApi.instance.scanBarcode(code);
      if (!mounted) return;
      await _controller.stop();
      if (!mounted) return;
      if (widget.returnProductIdOnSuccess) {
        context.pop(product.id);
        return;
      }
      context.pushReplacement(
        VendorBarcodeProductDetailScreen.routePath(product.id),
      );
    } catch (e) {
      if (!mounted) return;
      GlobalSnackbar.show(
        context,
        title: 'Scan',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: CustomSnackType.error,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_busy) return;
    final codes = capture.barcodes;
    if (codes.isEmpty) return;
    final b = codes.first;
    final v = b.rawValue ?? b.displayValue;
    if (v == null || v.isEmpty) return;
    _lookup(v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Scan barcode'),
        actions: [
          IconButton(
            tooltip: 'Torch',
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),
                if (_busy)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                Positioned(
                  left: 16.w,
                  right: 16.w,
                  bottom: 24.h,
                  child: Text(
                    'Point the camera at a barcode or QR code on your label.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: AllColor.white,
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + MediaQuery.paddingOf(context).bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Or enter code manually',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    color: AllColor.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manual,
                        decoration: const InputDecoration(
                          hintText: 'Paste or type barcode',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    FilledButton(
                      onPressed: _busy ? null : () => _lookup(_manual.text),
                      style: FilledButton.styleFrom(
                        backgroundColor: AllColor.loginButtomColor,
                      ),
                      child: const Text('Look up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
