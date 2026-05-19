import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_invoice_print_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/util/vendor_invoice_printer_service.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/util/vendor_printer_prefs.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

/// Choose 58mm Bluetooth (OEM) or 80mm Wi‑Fi/Ethernet (Epson/Star).
class VendorInvoicePrintSheet extends StatefulWidget {
  const VendorInvoicePrintSheet({super.key, required this.data});

  final VendorInvoicePrintData data;

  static Future<void> show(BuildContext context, VendorInvoicePrintData data) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => VendorInvoicePrintSheet(data: data),
    );
  }

  @override
  State<VendorInvoicePrintSheet> createState() => _VendorInvoicePrintSheetState();
}

class _VendorInvoicePrintSheetState extends State<VendorInvoicePrintSheet> {
  bool _busy = false;
  String? _savedMac;
  String? _savedName;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final s = await VendorPrinterPrefs.saved58Printer();
    if (mounted) {
      setState(() {
        _savedMac = s.mac;
        _savedName = s.name;
      });
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Printed',
          message: 'Sent to printer successfully.',
          type: CustomSnackType.success,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Print failed',
          message: e.toString().replaceFirst('Exception: ', ''),
          type: CustomSnackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _print58Saved() async {
    final mac = _savedMac;
    final name = _savedName ?? 'Printer';
    if (mac == null || mac.isEmpty) {
      await _pickBluetoothPrinter();
      return;
    }
    await _run(
      () => VendorInvoicePrinterService.print58mmBluetooth(
        data: widget.data,
        macAddress: mac,
        printerName: name,
      ),
    );
  }

  Future<void> _pickBluetoothPrinter() async {
    final block = await VendorInvoicePrinterService.ensureBluetoothReady();
    if (block != null) {
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Bluetooth',
          message: block,
          type: CustomSnackType.error,
        );
      }
      return;
    }

    List<BluetoothInfo> devices;
    try {
      devices = await VendorInvoicePrinterService.listPairedPrinters();
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Error',
          message: e.toString(),
          type: CustomSnackType.error,
        );
      }
      return;
    }

    if (!mounted) return;
    if (devices.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: 'No printer',
        message:
            'Pair your 58mm printer (XPrinter, Goojprt, HSPOS, etc.) in phone Bluetooth settings, then try again.',
        type: CustomSnackType.error,
      );
      return;
    }

    final picked = await showModalBottomSheet<BluetoothInfo>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Select Bluetooth printer',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
            ),
            ...devices.map(
              (d) => ListTile(
                leading: const Icon(Icons.print_outlined),
                title: Text(d.name),
                subtitle: Text(d.macAdress),
                onTap: () => Navigator.pop(ctx, d),
              ),
            ),
          ],
        ),
      ),
    );

    if (picked == null || !mounted) return;

    await _run(
      () => VendorInvoicePrinterService.print58mmBluetooth(
        data: widget.data,
        macAddress: picked.macAdress,
        printerName: picked.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Print invoice',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4.h),
          Text(
            'Order ${widget.data.orderNumber}',
            style: TextStyle(fontSize: 13.sp, color: AllColor.grey500),
          ),
          SizedBox(height: 16.h),
          if (_busy) const Center(child: CircularProgressIndicator()),
          if (!_busy) ...[
            _PrintOptionTile(
              icon: Icons.bluetooth,
              title: '58mm Bluetooth',
              subtitle: _savedName != null
                  ? 'OEM (XPrinter, Goojprt, HSPOS) · Last: $_savedName'
                  : 'Chinese OEM · pair in Bluetooth settings',
              onTap: _print58Saved,
            ),
            SizedBox(height: 10.h),
            _PrintOptionTile(
              icon: Icons.wifi,
              title: '80mm Wi‑Fi / Ethernet',
              subtitle: 'Epson / Star · uses invoice PDF + system print',
              onTap: () => _run(
                () => VendorInvoicePrinterService.print80mmInvoicePdf(
                  data: widget.data,
                ),
              ),
            ),
            if (_savedMac != null) ...[
              SizedBox(height: 8.h),
              TextButton(
                onPressed: _pickBluetoothPrinter,
                child: const Text('Change Bluetooth printer'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _PrintOptionTile extends StatelessWidget {
  const _PrintOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AllColor.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AllColor.grey200),
          ),
          child: Row(
            children: [
              Icon(icon, color: AllColor.loginButtomColor, size: 28.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AllColor.grey500),
            ],
          ),
        ),
      ),
    );
  }
}
