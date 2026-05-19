import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';

/// Normalized invoice payload for thermal + PDF printing.
class VendorInvoicePrintData {
  const VendorInvoicePrintData({
    required this.orderDocumentPathId,
    required this.orderNumber,
    required this.status,
    required this.lines,
    required this.payable,
    this.vendorName,
    this.customerName,
    this.paymentMethod,
    this.shipAddress,
    this.total,
    this.createdAt,
  });

  final int orderDocumentPathId;
  final String orderNumber;
  final String status;
  final String payable;
  final String? total;
  final String? vendorName;
  final String? customerName;
  final String? paymentMethod;
  final String? shipAddress;
  final DateTime? createdAt;
  final List<VendorInvoicePrintLine> lines;

  factory VendorInvoicePrintData.fromMarketplaceDetail(
    VendorMarketplaceLineDetail d,
    int orderDocumentPathId,
  ) {
    final rows = d.lineItems.isNotEmpty
        ? d.lineItems
        : <VendorMarketplaceLine>[
            VendorMarketplaceLine(
              id: d.id,
              quantity: d.quantity,
              status: d.status,
              salePrice: d.salePrice,
              invoiceId: d.invoiceId,
              productId: d.productId,
              createdAt: d.createdAt,
              invoice: d.invoice,
              product: d.product,
              unitPrice: d.unitPrice,
              totalPay: d.totalPay,
            ),
          ];

    final printLines = rows
        .map(
          (r) => VendorInvoicePrintLine(
            name: r.product.name.isNotEmpty ? r.product.name : 'Item #${r.id}',
            quantity: r.quantity,
            unitPrice: _lineUnit(r),
            lineTotal: _lineTotal(r),
          ),
        )
        .toList();

    var sum = 0.0;
    for (final r in rows) {
      sum += _lineTotalNum(r);
    }

    return VendorInvoicePrintData(
      orderDocumentPathId: orderDocumentPathId,
      orderNumber: d.invoice.orderNumber.isNotEmpty
          ? d.invoice.orderNumber
          : '#$orderDocumentPathId',
      status: d.invoice.status,
      vendorName: d.vendorName,
      customerName: d.lineCustomerName ?? d.invoice.cusName,
      paymentMethod: d.linePaymentMethod ?? d.invoice.paymentMethod,
      shipAddress: d.shipAddress,
      createdAt: d.createdAt,
      lines: printLines,
      payable: sum > 0 ? sum.toStringAsFixed(2) : _lineTotal(rows.first),
      total: sum > 0 ? sum.toStringAsFixed(2) : null,
    );
  }

  factory VendorInvoicePrintData.fromManualInvoice(
    VendorManualOrderInvoice inv,
    int orderDocumentPathId,
  ) {
    final printLines = inv.items
        .map(
          (r) => VendorInvoicePrintLine(
            name: (r.productName ?? '').trim().isNotEmpty
                ? r.productName!.trim()
                : 'Product #${r.productId}',
            quantity: r.quantity,
            unitPrice: r.unitPrice ?? _manualUnit(r),
            lineTotal: r.totalPay ?? _manualLineTotal(r),
          ),
        )
        .toList();

    return VendorInvoicePrintData(
      orderDocumentPathId: orderDocumentPathId,
      orderNumber: inv.orderNumber,
      status: inv.status,
      vendorName: null,
      customerName: inv.customerName,
      paymentMethod: inv.paymentMethod,
      createdAt: inv.createdAt,
      lines: printLines,
      payable: inv.summary.payable.isNotEmpty
          ? inv.summary.payable
          : inv.summary.total,
      total: inv.summary.total.isNotEmpty ? inv.summary.total : null,
    );
  }

  static String _lineUnit(VendorMarketplaceLine r) {
    final u = r.unitPrice?.trim();
    if (u != null && u.isNotEmpty) return u;
    return r.salePrice.toStringAsFixed(2);
  }

  static String _lineTotal(VendorMarketplaceLine r) {
    return _lineTotalNum(r).toStringAsFixed(2);
  }

  static double _lineTotalNum(VendorMarketplaceLine r) {
    final tp = r.totalPay?.replaceAll(',', '');
    final parsed = double.tryParse(tp ?? '');
    if (parsed != null) return parsed;
    return r.salePrice * r.quantity;
  }

  static String _manualUnit(VendorManualLineItem r) {
    if (r.salePrice != null) return r.salePrice!.toStringAsFixed(2);
    return '0';
  }

  static String _manualLineTotal(VendorManualLineItem r) {
    final tp = r.totalPay?.replaceAll(',', '');
    final parsed = double.tryParse(tp ?? '');
    if (parsed != null) return parsed.toStringAsFixed(2);
    return ((r.salePrice ?? 0) * r.quantity).toStringAsFixed(2);
  }
}

class VendorInvoicePrintLine {
  const VendorInvoicePrintLine({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final String name;
  final int quantity;
  final String unitPrice;
  final String lineTotal;
}
