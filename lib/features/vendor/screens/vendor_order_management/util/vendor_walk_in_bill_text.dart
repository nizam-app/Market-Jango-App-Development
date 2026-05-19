import 'dart:typed_data';

import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Plain-text walk-in bill for thermal print / clipboard.
String formatWalkInBillText(VendorManualOrderInvoice inv) {
  final buf = StringBuffer()
    ..writeln('WALK-IN — ${inv.orderNumber}')
    ..writeln('Customer: ${inv.customerName ?? '—'}')
    ..writeln('Payment: ${inv.paymentMethod ?? '—'}')
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
  return buf.toString();
}

int walkInOrderDocumentPathId(VendorManualOrderInvoice inv) {
  final oid = inv.orderRecordId;
  if (oid != null && oid > 0) return oid;
  if (inv.id > 0) return inv.id;
  return 0;
}

/// 80mm fallback when server invoice PDF is unavailable.
Future<Uint8List> buildWalkInBillTextPdf(String billText) async {
  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      margin: const pw.EdgeInsets.all(12),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (final line in billText.split('\n'))
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(
                line,
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
        ],
      ),
    ),
  );
  return doc.save();
}
