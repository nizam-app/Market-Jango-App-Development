import 'package:flutter/material.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_invoice_print_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/util/vendor_esc_pos_receipt.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/widget/vendor_printer_choice_sheet.dart';

/// Print vendor invoice — 58mm Bluetooth or 80mm Wi‑Fi/Ethernet.
class VendorInvoicePrintSheet {
  VendorInvoicePrintSheet._();

  static Future<void> show(
    BuildContext context,
    VendorInvoicePrintData data,
  ) {
    return VendorPrinterChoiceSheet.show(
      context,
      title: 'Print invoice',
      subtitle: 'Order ${data.orderNumber}',
      subtitle80: 'Epson / Star · invoice PDF from server',
      pdfJobName: 'invoice_${data.orderNumber}',
      build58Bytes: () async => VendorEscPosReceipt.build58mm(data),
      build80Pdf: () async {
        final doc = await VendorOrderApi.instance
            .fetchVendorAllOrderInvoiceDocument(data.orderDocumentPathId);
        if (doc.bytes.isEmpty) {
          throw Exception('Invoice PDF is empty.');
        }
        return doc.bytes;
      },
    );
  }
}
