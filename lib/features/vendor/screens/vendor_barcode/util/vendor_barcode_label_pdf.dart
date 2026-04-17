import 'dart:typed_data';

import 'package:barcode/barcode.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:market_jango/features/vendor/screens/vendor_barcode/model/vendor_barcode_models.dart';

/// Printable label with Code 128 + essential product fields (no sell price, URLs,
/// expiry, variant, barcode text row, or duplicate print_data block).
Future<Uint8List> buildBarcodeLabelTemplatePdf(
  VendorBarcodeLabelsResult r,
) async {
  final d = r.printData;
  final p = r.product;
  final doc = pw.Document();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (ctx) {
        return [
          pw.Text(
            'Barcode label template',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
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
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
          pw.SizedBox(height: 20),
          _sectionTitle('Product'),
          pw.SizedBox(height: 8),
          _row('ID', '${p.id}'),
          _row('Name', p.name),
          _row('SKU', p.sku),
          _row('Barcode', p.barcode),
          _row('Regular price', '${p.regularPrice}'),
          _row('Stock', '${p.stock}'),
          _row('Description', p.description),
          _row('Vendor', p.vendorName),
          _row(
            'Weight',
            p.weight == null ? '—' : '${p.weight} ${p.weightUnit}',
          ),
          _row(
            'Category',
            p.category.name.isEmpty
                ? '—'
                : '${p.category.name} (id ${p.category.id})',
          ),
          _row(
            'Business (vendor)',
            p.vendor.businessName.isEmpty
                ? '—'
                : '${p.vendor.businessName} (id ${p.vendor.id})',
          ),
          _row('Label count requested', '${r.labelCount}'),
          _row('Copies', '${d.copies}'),
          pw.SizedBox(height: 16),
          pw.Text(
            'Scannable Code 128 barcode above. Use “Download PDF template” from the app to share this file.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ];
      },
    ),
  );

  return doc.save();
}

pw.Widget _sectionTitle(String t) {
  return pw.Text(
    t,
    style: pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.grey800,
    ),
  );
}

pw.Widget _row(String label, String? value) {
  final v = value == null || value.isEmpty ? '—' : value;
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 130,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            v,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    ),
  );
}
