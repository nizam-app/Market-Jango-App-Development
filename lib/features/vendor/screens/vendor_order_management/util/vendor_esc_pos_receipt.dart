import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_invoice_print_data.dart';
import 'package:print_bluetooth_thermal/post_code.dart';

/// ESC/POS bytes for 58mm Chinese OEM Bluetooth printers (ESC/POS).
class VendorEscPosReceipt {
  VendorEscPosReceipt._();

  static const int _chars58 = 32;

  static List<int> build58mm(VendorInvoicePrintData data) {
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

    line('MARKET JANGO', align: AlignPos.center, bold: true, size: FontSize.big);
    line('INVOICE', align: AlignPos.center, bold: true);
    line('--------------------------------');

    if (data.vendorName != null && data.vendorName!.trim().isNotEmpty) {
      line(data.vendorName!.trim(), bold: true);
    }
    line('Order: ${data.orderNumber}', bold: true);
    line('Status: ${data.status}');
    if (data.createdAt != null) {
      line('Date: ${data.createdAt!.toLocal()}'.split('.').first);
    }
    if (data.customerName != null && data.customerName!.trim().isNotEmpty) {
      line('Customer: ${_fit(data.customerName!.trim(), _chars58 - 10)}');
    }
    if (data.paymentMethod != null && data.paymentMethod!.trim().isNotEmpty) {
      line('Pay: ${data.paymentMethod!.trim()}');
    }
    if (data.shipAddress != null && data.shipAddress!.trim().isNotEmpty) {
      for (final part in _wrap(data.shipAddress!.trim(), _chars58)) {
        line(part);
      }
    }

    line('--------------------------------');
    line('ITEMS', bold: true);

    for (final item in data.lines) {
      line(_fit(item.name, _chars58), bold: true);
      line(
        ' ${item.quantity} x ${item.unitPrice} = ${item.lineTotal}',
      );
    }

    line('--------------------------------');
    if (data.total != null &&
        data.total!.isNotEmpty &&
        data.total != data.payable) {
      line('Subtotal: ${data.total}', align: AlignPos.right);
    }
    line('TOTAL: ${data.payable}', align: AlignPos.right, bold: true, size: FontSize.doubleHeight);
    line('--------------------------------');
    line('Thank you', align: AlignPos.center);
    line('58mm BT | ESC/POS', align: AlignPos.center, size: FontSize.compressed);

    out.addAll(PostCode.cut());
    return out;
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
