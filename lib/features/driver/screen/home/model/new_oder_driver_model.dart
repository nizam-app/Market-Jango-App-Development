import 'dart:convert';

DriverNewOrdersResponse driverNewOrdersResponseFromJson(String s) =>
    DriverNewOrdersResponse.fromJson(jsonDecode(s) as Map<String, dynamic>);

class DriverNewOrdersResponse {
  final String status;
  final String? message;
  final OrdersPage data;

  DriverNewOrdersResponse({
    required this.status,
    this.message,
    required this.data,
  });

  factory DriverNewOrdersResponse.fromJson(Map<String, dynamic> j) =>
      DriverNewOrdersResponse(
        status: (j['status'] ?? '').toString(),
        message: j['message']?.toString(),
        data: OrdersPage.fromJson(j['data'] as Map<String, dynamic>),
      );
}

class OrdersPage {
  final int currentPage;
  final List<DriverOrder> data;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  OrdersPage({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory OrdersPage.fromJson(Map<String, dynamic> j) => OrdersPage(
    currentPage: _toInt(j['current_page']),
    data: ((j['data'] as List?) ?? [])
        .map((e) => DriverOrder.fromJson(e as Map<String, dynamic>))
        .toList(),
    lastPage: _toInt(j['last_page']),
    nextPageUrl: j['next_page_url']?.toString(),
    prevPageUrl: j['prev_page_url']?.toString(),
  );
}

class DriverOrder {
  final int id;
  final int quantity;
  final String tranId;
  final String status;
  final double salePrice;
  final int invoiceId;
  final int productId;
  final int vendorId;
  final int driverId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Invoice? invoice;

  DriverOrder({
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

  factory DriverOrder.fromJson(Map<String, dynamic> j) => DriverOrder(
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
    invoice: j['invoice'] == null
        ? null
        : Invoice.fromJson(j['invoice'] as Map<String, dynamic>),
  );
}

class Invoice {
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Invoice({
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
  });

  factory Invoice.fromJson(Map<String, dynamic> j) => Invoice(
    id: _toInt(j['id']),
    total: (j['total'] ?? '').toString(),
    vat: (j['vat'] ?? '').toString(),
    payable: (j['payable'] ?? '').toString(),
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

int _toInt(dynamic v) =>
    v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);
double _toDouble(dynamic v) => v == null
    ? 0.0
    : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);
DateTime? _toDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());
