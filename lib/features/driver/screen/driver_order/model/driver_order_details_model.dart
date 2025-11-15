class DriverTrackingResponse {
  final String status;
  final String message;
  final DriverTrackingData data;

  DriverTrackingResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DriverTrackingResponse.fromJson(Map<String, dynamic> json) {
    return DriverTrackingResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: DriverTrackingData.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// data object (main info)
class DriverTrackingData {
  final int id;
  final int quantity;
  final String tranId;
  final String status;
  final num salePrice;
  final int invoiceId;
  final int productId;
  final int vendorId;
  final int driverId;
  final String createdAt;
  final String updatedAt;
  final TrackingInvoice invoice;

  DriverTrackingData({
    required this.id,
    required this.quantity,
    required this.tranId,
    required this.status,
    required this.salePrice,
    required this.invoiceId,
    required this.productId,
    required this.vendorId,
    required this.driverId,
    required this.createdAt,
    required this.updatedAt,
    required this.invoice,
  });

  factory DriverTrackingData.fromJson(Map<String, dynamic> json) {
    return DriverTrackingData(
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      tranId: json['tran_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      salePrice: json['sale_price'] ?? 0,
      invoiceId: json['invoice_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      driverId: json['driver_id'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      invoice: TrackingInvoice.fromJson(
        json['invoice'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// invoice object
class TrackingInvoice {
  final int id;
  final String total;
  final String vat;
  final String payable;
  final String cusName;
  final String cusEmail;
  final String cusPhone;
  final String shipAddress;
  final String shipCity;
  final String shipCountry;
  final String pickupAddress;
  final String dropOfAddress;
  final String? distance;
  final String deliveryStatus;
  final String status;
  final String transactionId;
  final String taxRef;
  final String currency;
  final int userId;
  final String createdAt;
  final String updatedAt;

  /// raw list – future e chaile alada model banate parba
  final List<dynamic> statusLogTransports;

  TrackingInvoice({
    required this.id,
    required this.total,
    required this.vat,
    required this.payable,
    required this.cusName,
    required this.cusEmail,
    required this.cusPhone,
    required this.shipAddress,
    required this.shipCity,
    required this.shipCountry,
    required this.pickupAddress,
    required this.dropOfAddress,
    required this.distance,
    required this.deliveryStatus,
    required this.status,
    required this.transactionId,
    required this.taxRef,
    required this.currency,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.statusLogTransports,
  });

  factory TrackingInvoice.fromJson(Map<String, dynamic> json) {
    return TrackingInvoice(
      id: json['id'] ?? 0,
      total: json['total']?.toString() ?? '',
      vat: json['vat']?.toString() ?? '',
      payable: json['payable']?.toString() ?? '',
      cusName: json['cus_name']?.toString() ?? '',
      cusEmail: json['cus_email']?.toString() ?? '',
      cusPhone: json['cus_phone']?.toString() ?? '',
      shipAddress: json['ship_address']?.toString() ?? '',
      shipCity: json['ship_city']?.toString() ?? '',
      shipCountry: json['ship_country']?.toString() ?? '',
      pickupAddress: json['pickup_address']?.toString() ?? '',
      dropOfAddress: json['drop_of_address']?.toString() ?? '',
      distance: json['distance']?.toString(),
      deliveryStatus: json['delivery_status']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString() ?? '',
      taxRef: json['tax_ref']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      statusLogTransports:
          (json['status_log_transports'] as List?)?.toList() ?? const [],
    );
  }
}
