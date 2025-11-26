// models/driver_order_model.dart
import 'dart:convert';

DriverAllOrdersResponse driverAllOrdersResponseFromJson(String s) =>
    DriverAllOrdersResponse.fromJson(jsonDecode(s) as Map<String, dynamic>);

class DriverAllOrdersResponse {
  final String status;
  final String? message;
  final OrdersPage data;

  DriverAllOrdersResponse({
    required this.status,
    this.message,
    required this.data,
  });

  factory DriverAllOrdersResponse.fromJson(Map<String, dynamic> j) {
    return DriverAllOrdersResponse(
      status: (j['status'] ?? '').toString(),
      message: j['message']?.toString(),
      data: OrdersPage.fromJson(j['data'] as Map<String, dynamic>),
    );
  }
}

class OrdersPage {
  final int currentPage;
  final List<DriverOrderEntity> data;
  final int lastPage;

  OrdersPage({
    required this.currentPage,
    required this.data,
    required this.lastPage,
  });

  factory OrdersPage.fromJson(Map<String, dynamic> j) {
    final list = (j['data'] as List? ?? [])
        .map((e) => DriverOrderEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    return OrdersPage(
      currentPage: _toInt(j['current_page']),
      data: list,
      lastPage: _toInt(j['last_page']),
    );
  }
}

class DriverOrderEntity {
  final int id;
  final int quantity;
  final String tranId;
  final String status; // e.g. "AssignedOrder"
  final double salePrice;
  final int invoiceId;
  final int productId;
  final int vendorId;
  final int driverId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int invoiceCount;
  final InvoiceEntity? invoice;

  DriverOrderEntity({
    required this.id,
    required this.quantity,
    required this.tranId,
    required this.status,
    required this.salePrice,
    required this.invoiceId,
    required this.productId,
    required this.vendorId,
    required this.driverId,
    this.createdAt,
    this.updatedAt,
    required this.invoiceCount,
    this.invoice,
  });

  factory DriverOrderEntity.fromJson(Map<String, dynamic> j) {
    return DriverOrderEntity(
      id: _toInt(j['id']),
      quantity: _toInt(j['quantity']),
      tranId: (j['tran_id'] ?? '').toString(),
      status: (j['status'] ?? '').toString(),
      salePrice: _toDouble(j['sale_price']),
      invoiceId: _toInt(j['invoice_id']),
      productId: _toInt(j['product_id']),
      vendorId: _toInt(j['vendor_id']),
      driverId: _toInt(j['driver_id']),
      createdAt: _toDate(j['created_at']),
      updatedAt: _toDate(j['updated_at']),
      invoiceCount: _toInt(j['invoice_count']),
      invoice: j['invoice'] == null
          ? null
          : InvoiceEntity.fromJson(j['invoice'] as Map<String, dynamic>),
    );
  }
}

class InvoiceEntity {
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
  final String deliveryStatus; // "Pending"/"Delivered"/...
  final String status; // payment status e.g. "successful"
  final String transactionId;
  final String taxRef; // <- orderId হিসেবে ব্যবহার
  final String currency;
  final int userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InvoiceEntity({
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
    this.distance,
    required this.deliveryStatus,
    required this.status,
    required this.transactionId,
    required this.taxRef,
    required this.currency,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory InvoiceEntity.fromJson(Map<String, dynamic> j) {
    return InvoiceEntity(
      id: _toInt(j['id']),
      total: (j['total'] ?? '0').toString(),
      vat: (j['vat'] ?? '0').toString(),
      payable: (j['payable'] ?? '0').toString(),
      cusName: (j['cus_name'] ?? '').toString(),
      cusEmail: (j['cus_email'] ?? '').toString(),
      cusPhone: (j['cus_phone'] ?? '').toString(),
      shipAddress: (j['ship_address'] ?? '').toString(),
      shipCity: (j['ship_city'] ?? '').toString(),
      shipCountry: (j['ship_country'] ?? '').toString(),
      pickupAddress: (j['pickup_address'] ?? '').toString(),
      dropOfAddress: (j['drop_of_address'] ?? '').toString(),
      distance: j['distance']?.toString(),
      deliveryStatus: (j['delivery_status'] ?? '').toString(),
      status: (j['status'] ?? '').toString(),
      transactionId: (j['transaction_id'] ?? '').toString(),
      taxRef: (j['tax_ref'] ?? '').toString(),
      currency: (j['currency'] ?? '').toString(),
      userId: _toInt(j['user_id']),
      createdAt: _toDate(j['created_at']),
      updatedAt: _toDate(j['updated_at']),
    );
  }
}

int _toInt(dynamic v) =>
    v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);
double _toDouble(dynamic v) => v == null
    ? 0.0
    : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);
DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return null;
  }
}
