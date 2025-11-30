// lib/core/screen/global_tracking/model/tracking_details_model.dart

class TrackingDetailsResponse {
  final String status;
  final String message;
  final TrackingInvoice data;

  TrackingDetailsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TrackingDetailsResponse.fromJson(Map<String, dynamic> json) {
    return TrackingDetailsResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: TrackingInvoice.fromJson(json['data'] ?? {}),
    );
  }
}

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
  final String deliveryStatus; // Pending / AssignedOrder / Ongoing / Completed / Cancelled
  final String status;
  final String transactionId;
  final String taxRef;
  final String currency;
  final int userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<TrackingStatusLog> statusLogs;

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
    required this.statusLogs,
  });

  factory TrackingInvoice.fromJson(Map<String, dynamic> json) {
    DateTime? _parse(String? s) =>
        s == null ? null : DateTime.tryParse(s);

    return TrackingInvoice(
      id: json['id'] ?? 0,
      total: json['total'] ?? '',
      vat: json['vat'] ?? '',
      payable: json['payable'] ?? '',
      cusName: json['cus_name'] ?? '',
      cusEmail: json['cus_email'] ?? '',
      cusPhone: json['cus_phone'] ?? '',
      shipAddress: json['ship_address'] ?? '',
      shipCity: json['ship_city'] ?? '',
      shipCountry: json['ship_country'] ?? '',
      pickupAddress: json['pickup_address'] ?? '',
      dropOfAddress: json['drop_of_address'] ?? '',
      distance: json['distance']?.toString(),
      deliveryStatus: json['delivery_status'] ?? '',
      status: json['status'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      taxRef: json['tax_ref'] ?? '',
      currency: json['currency'] ?? '',
      userId: json['user_id'] ?? 0,
      createdAt: _parse(json['created_at']),
      updatedAt: _parse(json['updated_at']),
      statusLogs: (json['status_logs'] as List<dynamic>? ?? [])
          .map((e) => TrackingStatusLog.fromJson(e))
          .toList(),
    );
  }
}

class TrackingStatusLog {
  final int id;
  final String status; // Complete / Pending / ...
  final String note;
  final int isActive;
  final int invoiceId;
  final int invoiceItemId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TrackingStatusLog({
    required this.id,
    required this.status,
    required this.note,
    required this.isActive,
    required this.invoiceId,
    required this.invoiceItemId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrackingStatusLog.fromJson(Map<String, dynamic> json) {
    DateTime? _parse(String? s) =>
        s == null ? null : DateTime.tryParse(s);

    return TrackingStatusLog(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      note: json['note'] ?? '',
      isActive: json['is_active'] ?? 0,
      invoiceId: json['invoice_id'] ?? 0,
      invoiceItemId: json['invoice_item_id'] ?? 0,
      createdAt: _parse(json['created_at']),
      updatedAt: _parse(json['updated_at']),
    );
  }
}