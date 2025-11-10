// lib/features/buyer/model/invoice_tracking_model.dart
class InvoiceTrackingResponse {
  final String status;
  final String message;
  final InvoiceTracking data;

  InvoiceTrackingResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory InvoiceTrackingResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceTrackingResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: InvoiceTracking.fromJson(
        Map<String, dynamic>.from(json['data'] ?? const {}),
      ),
    );
  }
}

class InvoiceTracking {
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

  final String? deliveryStatus; // e.g. "Pending"
  final String? status;         // nullable
  final String? transactionId;
  final String? taxRef;
  final String? currency;
  final int? userId;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Optional: history/logs list (API যদি পাঠায়)
  final List<StatusHistory> history;

  InvoiceTracking({
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
    this.deliveryStatus,
    this.status,
    this.transactionId,
    this.taxRef,
    this.currency,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.history = const [],
  });

  factory InvoiceTracking.fromJson(Map<String, dynamic> json) {
    DateTime? _dt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());

    // history key কখনো history/histories/status_history/trackings হতে পারে
    final dynamic rawHistory =
        json['history'] ?? json['histories'] ?? json['status_history'] ?? json['trackings'];

    final List<StatusHistory> parsedHistory = (rawHistory is List)
        ? rawHistory
        .whereType<Map>()
        .map((e) => StatusHistory.fromJson(Map<String, dynamic>.from(e)))
        .toList()
        : const [];

    int? _i(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    String _s(dynamic v) => v?.toString() ?? '';

    return InvoiceTracking(
      id: _i(json['id']) ?? 0,
      total: _s(json['total']),
      vat: _s(json['vat']),
      payable: _s(json['payable']),
      cusName: _s(json['cus_name']),
      cusEmail: _s(json['cus_email']),
      cusPhone: _s(json['cus_phone']),
      shipAddress: _s(json['ship_address']),
      shipCity: _s(json['ship_city']),
      shipCountry: _s(json['ship_country']),
      deliveryStatus: json['delivery_status']?.toString(),
      status: json['status']?.toString(),
      transactionId: json['transaction_id']?.toString(),
      taxRef: json['tax_ref']?.toString(),
      currency: json['currency']?.toString(),
      userId: _i(json['user_id']),
      createdAt: _dt(json['created_at']),
      updatedAt: _dt(json['updated_at']),
      history: parsedHistory,
    );
  }
}

class StatusHistory {
  final int? id;
  final int? invoiceId;
  final String status;      // e.g. "Picked", "Shipped", "Delivered"
  final String? note;       // optional note
  final String? image;      // optional proof image url
  final DateTime? createdAt;

  StatusHistory({
    this.id,
    this.invoiceId,
    required this.status,
    this.note,
    this.image,
    this.createdAt,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    int? _i(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    DateTime? _dt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());

    return StatusHistory(
      id: _i(json['id']),
      invoiceId: _i(json['invoice_id'] ?? json['invoiceId']),
      status: (json['status'] ?? '').toString(),
      note: json['note']?.toString(),
      image: json['image']?.toString(),
      createdAt: _dt(json['created_at']),
    );
  }
}