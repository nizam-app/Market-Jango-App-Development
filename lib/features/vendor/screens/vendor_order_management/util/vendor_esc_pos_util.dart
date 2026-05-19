import 'package:market_jango/features/vendor/screens/vendor_barcode/model/vendor_barcode_models.dart';
import 'package:print_bluetooth_thermal/post_code.dart';

/// ESC/POS helpers for 58mm Bluetooth (plain text, barcode labels, bills).
class VendorEscPosUtil {
  VendorEscPosUtil._();

  static const int _chars58 = 32;

  static List<int> buildPlainText58mm(String text) {
    final out = <int>[];
    for (final raw in text.split('\n')) {
      final line = raw.trimRight();
      if (line.isEmpty) {
        out.addAll(PostCode.text(text: ' ', align: AlignPos.left));
        continue;
      }
      for (final part in _wrap(line, _chars58)) {
        out.addAll(PostCode.text(text: part, align: AlignPos.left));
      }
    }
    out.addAll(PostCode.cut());
    return out;
  }

  static List<int> buildBarcodeLabel58mm(
    VendorBarcodeLabelsResult result, {
    int? copies,
  }) {
    final d = result.printData;
    final p = result.product;
    final n = copies ?? d.copies;
    final out = <int>[];

    void line(
      String text, {
      AlignPos align = AlignPos.left,
      bool bold = false,
      FontSize size = FontSize.normal,
    }) {
      out.addAll(
        PostCode.text(
          text: _fit(text, _chars58),
          align: align,
          bold: bold,
          fontSize: size,
        ),
      );
    }

    for (var c = 0; c < n; c++) {
      if (c > 0) line('---');
      line('MARKET JANGO', align: AlignPos.center, bold: true);
      line(_fit(p.name.isEmpty ? 'Product #${p.id}' : p.name, _chars58),
          bold: true);
      if (p.sku.isNotEmpty) line('SKU: ${p.sku}');
      line('Price: ${p.regularPrice}');
      if (d.barcode.isNotEmpty) {
        out.addAll(PostCode.barcode(barcodeData: d.barcode));
        line(d.barcode, align: AlignPos.center, size: FontSize.compressed);
      }
      line('', align: AlignPos.center);
    }

    out.addAll(PostCode.cut());
    return out;
  }

  static VendorBarcodeLabelsResult labelsFromProduct(
    VendorBarcodeProduct p, {
    int labelCount = 1,
  }) {
    return VendorBarcodeLabelsResult(
      product: p,
      labelCount: labelCount,
      printData: VendorBarcodeLabelPrintData(
        barcode: p.barcode,
        barcodeText: p.barcodeText.isNotEmpty ? p.barcodeText : p.barcode,
        productName: p.name,
        price: p.regularPrice,
        vendorName: p.vendorName,
        sku: p.sku,
        expiryDate: p.expiryDate,
        brandLogoUrl: p.brandLogoUrl,
        variant: p.variant,
        copies: labelCount,
      ),
    );
  }

  static String _fit(String s, int max) {
    final t = s.replaceAll('\n', ' ').trim();
    if (t.length <= max) return t;
    return '${t.substring(0, max - 1)}…';
  }

  static List<String> _wrap(String text, int width) {
    final words = text.split(RegExp(r'\s+'));
    final lines = <String>[];
    var buf = '';
    for (final w in words) {
      if (w.isEmpty) continue;
      if (buf.isEmpty) {
        buf = w;
      } else if (buf.length + 1 + w.length <= width) {
        buf = '$buf $w';
      } else {
        lines.add(buf);
        buf = w;
      }
    }
    if (buf.isNotEmpty) lines.add(buf);
    return lines.isEmpty ? [text] : lines;
  }
}
