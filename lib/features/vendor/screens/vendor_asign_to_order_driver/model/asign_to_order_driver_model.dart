// vendor_pending_order_model.dart

class VendorPendingOrderResponse {
  final String status;
  final String message;
  final VendorPendingOrderPage data;

  VendorPendingOrderResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory VendorPendingOrderResponse.fromJson(Map<String, dynamic> json) {
    return VendorPendingOrderResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: VendorPendingOrderPage.fromJson(json['data'] ?? {}),
    );
  }
}

class VendorPendingOrderPage {
  final int currentPage;
  final List<VendorPendingOrder> data;

  VendorPendingOrderPage({
    required this.currentPage,
    required this.data,
  });

  factory VendorPendingOrderPage.fromJson(Map<String, dynamic> json) {
    return VendorPendingOrderPage(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List? ?? [])
          .map((e) => VendorPendingOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class VendorPendingOrder {
  final int id;
  final int quantity;
  final String tranId;
  final String status;
  final double salePrice;
  final int invoiceId;
  final int productId;
  final int vendorId;
  final int? driverId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final VendorInvoice? invoice;

  VendorPendingOrder({
    required this.id,
    required this.quantity,
    required this.tranId,
    required this.status,
    required this.salePrice,
    required this.invoiceId,
    required this.productId,
    required this.vendorId,
    this.driverId,
    this.createdAt,
    this.updatedAt,
    this.invoice,
  });

  factory VendorPendingOrder.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return VendorPendingOrder(
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      tranId: json['tran_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      salePrice: _toDouble(json['sale_price']),
      invoiceId: json['invoice_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      driverId: json['driver_id'],
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      invoice: json['invoice'] == null
          ? null
          : VendorInvoice.fromJson(json['invoice'] as Map<String, dynamic>),
    );
  }
}

class VendorInvoice {
  final int id;
  final String subTotal;
  final String vat;
  final String? total;

  VendorInvoice({
    required this.id,
    required this.subTotal,
    required this.vat,
    this.total,
  });

  factory VendorInvoice.fromJson(Map<String, dynamic> json) {
    return VendorInvoice(
      id: json['id'] ?? 0,
      subTotal: json['sub_total']?.toString() ?? '',
      vat: json['vat']?.toString() ?? '',
      total: json['total']?.toString(),
    );
  }
}