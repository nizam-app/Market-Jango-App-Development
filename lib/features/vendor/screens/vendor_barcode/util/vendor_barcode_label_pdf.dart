import 'dart:typed_data';

import 'package:barcode/barcode.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:market_jango/features/vendor/screens/vendor_barcode/model/vendor_barcode_models.dart';

/// Single-page printable label with scannable Code 128 bars + text (like retail labels).
Future<Uint8List> buildBarcodeLabelTemplatePdf(VendorBarcodeLabelsResult r) async {
  final d = r.printData;
  final doc = pw.Document();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Barcode label template',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 16),
            if (d.barcode.isNotEmpty)
              pw.Center(
                child: pw.Container(
                  width: 300,
                  height: 120,
                  color: PdfColors.white,
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: d.barcode,
                    drawText: true,
                    color: PdfColors.black,
                    backgroundColor: PdfColors.white,
                    width: 284,
                    height: 104,
                    textStyle: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.black,
                    ),
                    textPadding: 4,
                  ),
                ),
              )
            else
              pw.Text(
                'No barcode string',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 1),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _row('Product', d.productName),
                  pw.SizedBox(height: 8),
                  _row('Price', d.price.toString()),
                  pw.SizedBox(height: 8),
                  _row('Vendor', d.vendorName),
                  pw.SizedBox(height: 8),
                  _row('Copies (per print_data)', '${d.copies}'),
                  pw.SizedBox(height: 8),
                  _row('Label count requested', '${r.labelCount}'),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Scannable Code 128 barcode above. Use “Download PDF template” from the app to share this file.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        );
      },
    ),
  );

  return doc.save();
}

pw.Widget _row(String label, String value) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(
        width: 120,
        child: pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
      ),
      pw.Expanded(
        child: pw.Text(
          value.isEmpty ? '—' : value,
          style: const pw.TextStyle(fontSize: 12),
        ),
      ),
    ],
  );
}
