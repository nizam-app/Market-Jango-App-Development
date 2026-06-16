import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../model/invoice_details_model.dart';

/// Localized / display strings for the PDF receipt.
class InvoiceReceiptPdfLabels {
  const InvoiceReceiptPdfLabels({
    required this.invoiceTitle,
    required this.customerLabel,
    required this.customerValue,
    required this.orderNumberLabel,
    required this.itemsTitle,
    required this.productNameColumn,
    required this.numberOfProductsColumn,
    required this.costColumn,
    required this.deliveryLabel,
    required this.taxLabel,
    required this.platformFeesLabel,
    required this.totalFeesLabel,
    required this.vendorSlotWord,
    required this.vendorIdPrefix,
    required this.productFallbackPrefix,
  });

  final String invoiceTitle;
  final String customerLabel;
  final String customerValue;
  final String orderNumberLabel;
  final String itemsTitle;
  final String productNameColumn;
  final String numberOfProductsColumn;
  final String costColumn;
  final String deliveryLabel;
  final String taxLabel;
  final String platformFeesLabel;
  final String totalFeesLabel;
  final String vendorSlotWord;
  final String vendorIdPrefix;
  final String productFallbackPrefix;
}

String _vendorPdfTitle({
  required String vendorSlotWord,
  required int vendorIndex,
  required int totalVendors,
  required String businessLabel,
}) {
  if (totalVendors <= 1) return businessLabel;
  final letter = String.fromCharCode(65 + vendorIndex);
  return '$vendorSlotWord $letter · $businessLabel';
}

pw.Widget _pdfCell(
  String text, {
  bool bold = false,
  bool center = false,
  bool right = false,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
      textAlign: center
          ? pw.TextAlign.center
          : right
              ? pw.TextAlign.right
              : pw.TextAlign.left,
    ),
  );
}

pw.Widget _pdfSummaryRow(String label, String value, {bool emphasize = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Text(label, style: pw.TextStyle(fontSize: 10)),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: emphasize ? 12 : 10,
            fontWeight:
                emphasize ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

/// Builds a printable invoice receipt (A4 PDF bytes).
Future<Uint8List> buildInvoiceReceiptPdfBytes({
  required InvoiceDetails details,
  required InvoiceReceiptPdfLabels labels,
  required String orderNumberValue,
  required String deliveryValue,
  required String taxValue,
  required String platformValue,
  required String totalValue,
}) async {
  final grouped = <int, List<InvoiceItemDetail>>{};
  for (final item in details.items) {
    grouped.putIfAbsent(item.vendorId, () => []).add(item);
  }
  final vendorIds = grouped.keys.toList()..sort();

  pw.ImageProvider? logo;
  try {
    final data = await rootBundle.load('assets/images/logo.png');
    logo = pw.MemoryImage(data.buffer.asUint8List());
  } catch (_) {}

  pw.Widget vendorBlock(int vendorIndex) {
    final vendorId = vendorIds[vendorIndex];
    final lines = grouped[vendorId]!;
    final vendorName = lines.first.vendor?.businessName?.trim();
    final business = (vendorName != null && vendorName.isNotEmpty)
        ? vendorName
        : '${labels.vendorIdPrefix}$vendorId';
    final title = _vendorPdfTitle(
      vendorSlotWord: labels.vendorSlotWord,
      vendorIndex: vendorIndex,
      totalVendors: vendorIds.length,
      businessLabel: business,
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (vendorIndex > 0) pw.SizedBox(height: 12),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2.2),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _pdfCell(labels.productNameColumn, bold: true),
                _pdfCell(labels.numberOfProductsColumn, bold: true, center: true),
                _pdfCell(labels.costColumn, bold: true, right: true),
              ],
            ),
            for (final item in lines)
              pw.TableRow(
                children: [
                  _pdfCell(
                    item.product?.name.isNotEmpty == true
                        ? item.product!.name
                        : '${labels.productFallbackPrefix}${item.productId}',
                  ),
                  _pdfCell('${item.quantity}', center: true),
                  _pdfCell(item.totalPay, right: true),
                ],
              ),
          ],
        ),
      ],
    );
  }

  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        pw.Text(
          labels.invoiceTitle,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 20),
        pw.Text('${labels.customerLabel}: ${labels.customerValue}'),
        pw.SizedBox(height: 4),
        pw.Text('${labels.orderNumberLabel}: $orderNumberValue'),
        pw.SizedBox(height: 16),
        pw.Text(
          labels.itemsTitle,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        ...List.generate(vendorIds.length, vendorBlock),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _pdfSummaryRow(labels.deliveryLabel, deliveryValue),
              _pdfSummaryRow(labels.taxLabel, taxValue),
              _pdfSummaryRow(labels.platformFeesLabel, platformValue),
              pw.Divider(color: PdfColors.grey400, height: 12),
              _pdfSummaryRow(labels.totalFeesLabel, totalValue, emphasize: true),
            ],
          ),
        ),
        pw.SizedBox(height: 24),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (logo != null)
              pw.Image(logo, width: 88, height: 44, fit: pw.BoxFit.contain)
            else
              pw.Text(
                'Market Jango',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
            pw.Text(
              'PDF receipt',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    ),
  );

  return doc.save();
}
