// vendor_pending_order_model.dart / asign_to_order_driver_model.dart

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
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: VendorPendingOrderPage.fromJson(json['data'] ?? {}),
    );
  }
}

class VendorPendingOrderPage {
  final int currentPage;
  final List<VendorPendingOrder> data;
  final int lastPage;
  final int perPage;
  final int total;

  VendorPendingOrderPage({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory VendorPendingOrderPage.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return VendorPendingOrderPage(
      currentPage: _toInt(json['current_page']),
      data: (json['data'] as List? ?? [])
          .map((e) => VendorPendingOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastPage: _toInt(json['last_page']),
      perPage: _toInt(json['per_page']),
      total: _toInt(json['total']),
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

  /// 🔹 নতুন ফিল্ডগুলো (JSON থেকে)
  final String? pickupAddress;
  final String? currentAddress;
  final String? shipAddress;
  final String? distance;
  final String? deliveryCharge;

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
    this.pickupAddress,
    this.currentAddress,
    this.shipAddress,
    this.distance,
    this.deliveryCharge,
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

      pickupAddress: json['pickup_address']?.toString(),
      currentAddress: json['current_address']?.toString(),
      shipAddress: json['ship_address']?.toString(),
      distance: json['distance']?.toString(),
      deliveryCharge: json['delivery_charge']?.toString(),

      invoice: json['invoice'] == null
          ? null
          : VendorInvoice.fromJson(json['invoice'] as Map<String, dynamic>),
    );
  }
}

class VendorInvoice {
  final int id;
  final String total;
  final String vat;
  final String payable;
  final String? paymentMethod;
  final String status;

  VendorInvoice({
    required this.id,
    required this.total,
    required this.vat,
    required this.payable,
    this.paymentMethod,
    required this.status,
  });

  factory VendorInvoice.fromJson(Map<String, dynamic> json) {
    return VendorInvoice(
      id: json['id'] ?? 0,
      total: json['total']?.toString() ?? '',
      vat: json['vat']?.toString() ?? '',
      payable: json['payable']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString(),
      status: json['status']?.toString() ?? '',
    );
  }
}
