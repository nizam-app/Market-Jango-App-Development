import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_invoice_print_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/util/vendor_esc_pos_receipt.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/util/vendor_printer_prefs.dart';
import 'package:pdf/pdf.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:printing/printing.dart';

/// 58mm Bluetooth (OEM) + 80mm Wi‑Fi/Ethernet (Epson/Star via system print).
class VendorInvoicePrinterService {
  VendorInvoicePrinterService._();

  static Future<String?> ensureBluetoothReady() async {
    if (kIsWeb) {
      return 'Bluetooth printing is not supported in the browser. Use the mobile app.';
    }
    if (!Platform.isAndroid && !Platform.isIOS) {
      return '58mm Bluetooth printing is only supported on Android and iOS.';
    }
    final enabled = await PrintBluetoothThermal.bluetoothEnabled;
    if (!enabled) {
      return 'Turn on Bluetooth on this device.';
    }
    final granted = await PrintBluetoothThermal.isPermissionBluetoothGranted;
    if (!granted) {
      return 'Allow Bluetooth permission for Market Jango in system settings.';
    }
    return null;
  }

  static Future<List<BluetoothInfo>> listPairedPrinters() {
    return PrintBluetoothThermal.pairedBluetooths;
  }

  static Future<void> print58mmBluetooth({
    required VendorInvoicePrintData data,
    required String macAddress,
    required String printerName,
  }) async {
    final block = await ensureBluetoothReady();
    if (block != null) throw Exception(block);

    final connected = await PrintBluetoothThermal.connect(
      macPrinterAddress: macAddress,
    );
    if (!connected) {
      throw Exception(
        'Could not connect to $printerName. Pair the printer in Bluetooth settings first.',
      );
    }

    await VendorPrinterPrefs.save58Printer(mac: macAddress, name: printerName);

    final bytes = VendorEscPosReceipt.build58mm(data);
    final ok = await PrintBluetoothThermal.writeBytes(bytes);
    if (!ok) {
      throw Exception('Print failed. Check paper and printer power.');
    }
  }

  /// Server invoice PDF on 80mm roll — Epson / Star on Wi‑Fi or Ethernet.
  static Future<void> print80mmInvoicePdf({
    required VendorInvoicePrintData data,
  }) async {
    final doc = await VendorOrderApi.instance.fetchVendorAllOrderInvoiceDocument(
      data.orderDocumentPathId,
    );
    if (doc.bytes.isEmpty) {
      throw Exception('Invoice PDF is empty.');
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.bytes,
      format: PdfPageFormat.roll80,
      name: 'invoice_${data.orderNumber}',
    );
  }
}
