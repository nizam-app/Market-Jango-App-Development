// lib/features/buyer/screens/order/model/order_summary.dart
import 'dart:convert';

class OrdersResponse {
  final String? status;
  final String? message;
  final OrdersPageData? data;

  OrdersResponse({this.status, this.message, this.data});

  factory OrdersResponse.fromJson(Map<String, dynamic> json) => OrdersResponse(
    status: json['status']?.toString(),
    message: json['message']?.toString(),
    data: (json['data'] is Map<String, dynamic>)
        ? OrdersPageData.fromJson(json['data'] as Map<String, dynamic>)
        : null,
  );

  static OrdersResponse fromJsonString(String body) =>
      OrdersResponse.fromJson(jsonDecode(body) as Map<String, dynamic>);
}

/// data -> [ { ...one order row... } ]
class OrdersPageData {
  final List<Order> orders;
  final int currentPage;
  final int lastPage;
  final int? total;

  OrdersPageData({
    required this.orders,
    required this.currentPage,
    required this.lastPage,
    this.total,
  });

  factory OrdersPageData.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?) ?? const [];

    return OrdersPageData(
      orders: list
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
      // API te na thakleo default 1/1 nibo
      currentPage: _toIntNullable(json['current_page']) ?? 1,
      lastPage: _toIntNullable(json['last_page']) ?? 1,
      total: _toIntNullable(json['total']),
    );
  }
}

/// ===================== ORDER (ekta row) =====================
class Order {
  final int id;
  final String? cusName;
  final String? cusEmail;
  final String? cusPhone;

  final String? pickupAddress;
  final String? currentAddress;
  final String? note;

  final double? currentLatitude;
  final double? currentLongitude;

  final String? shipAddress;
  final double? shipLatitude;
  final double? shipLongitude;

  final int quantity;
  final String tranId;
  final String status; // raw status from API (Pending / Not Deliver ...)
  final double distance;
  final double salePrice;
  final double deliveryCharge;

  final int invoiceId;
  final int productId;
  final int vendorId;
  final int userId;
  final int? driverId;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Invoice invoice;
  final Product product;

  Order({
    required this.id,
    required this.cusName,
    required this.cusEmail,
    required this.cusPhone,
    required this.pickupAddress,
    required this.currentAddress,
    required this.note,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.shipAddress,
    required this.shipLatitude,
    required this.shipLongitude,
    required this.quantity,
    required this.tranId,
    required this.status,
    required this.distance,
    required this.salePrice,
    required this.deliveryCharge,
    required this.invoiceId,
    required this.productId,
    required this.vendorId,
    required this.userId,
    required this.driverId,
    required this.createdAt,
    required this.updatedAt,
    required this.invoice,
    required this.product,
  });

  /// UI te dekhabo ei order id
  /// age tax_ref, na thakle tran_id
  String get orderCode => invoice.taxRef.isNotEmpty ? invoice.taxRef : tranId;

  /// main status (Not Deliver => Pending)
  String get effectiveStatus {
    final base = status.isNotEmpty ? status : (invoice.status ?? 'Pending');

    final lower = base.toLowerCase();
    if (lower == 'not deliver' || lower == 'not delivered') {
      return 'Pending';
    }
    return base;
  }

  /// Order model er moddhe add koro (jaigata bhalo jekhane ichcha):
  bool get isCompleted => effectiveStatus.toLowerCase() == 'complete';

  /// short description for card
  ///
  /// Pending       → Driver has not received
  /// AssignedOrder → Assigned to the driver
  /// On The Way    → The product is on the way
  /// Complete      → The order has complete
  String get statusDescription {
    switch (effectiveStatus.toLowerCase()) {
      case 'pending':
        return 'Driver has not received';
      case 'assignedorder':
      case 'assigned order':
        return 'Assigned to the driver';
      case 'on the way':
      case 'ontheway':
        return 'The product is on the way';
      case 'complete':
      case 'completed':
        return 'The order has complete';
      default:
        return '';
    }
  }

  /// Payment badge text
  /// FW  → Payment successful
  /// OPU → Cash on delivery
  String get paymentLabel {
    final method = (invoice.paymentMethod ?? '').toUpperCase();
    if (method == 'FW') return 'Payment successful';
    if (method == 'OPU') return 'Cash on delivery';
    return '';
  }

  /// old name jodi onno jaiga use kore, same value return
  String get paymentMethodLabel => paymentLabel;

  factory Order.fromJson(Map<String, dynamic> json) {
    final invoiceJson = (json['invoice'] as Map<String, dynamic>? ?? const {});
    final productJson = (json['product'] as Map<String, dynamic>? ?? const {});

    return Order(
      id: _toInt(json['id']),
      cusName: json['cus_name']?.toString(),
      cusEmail: json['cus_email']?.toString(),
      cusPhone: json['cus_phone']?.toString(),
      pickupAddress: json['pickup_address']?.toString(),
      currentAddress: json['current_address']?.toString(),
      note: json['note']?.toString(),
      currentLatitude: _toDoubleNullable(json['current_latitude']),
      currentLongitude: _toDoubleNullable(json['current_longitude']),
      shipAddress: json['ship_address']?.toString(),
      shipLatitude: _toDoubleNullable(json['ship_latitude']),
      shipLongitude: _toDoubleNullable(json['ship_longitude']),
      quantity: _toInt(json['quantity']),
      tranId: json['tran_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      distance: _toDouble(json['distance']),
      salePrice: _toDouble(json['sale_price']),
      deliveryCharge: _toDouble(json['delivery_charge']),
      invoiceId: _toInt(json['invoice_id']),
      productId: _toInt(json['product_id']),
      vendorId: _toInt(json['vendor_id']),
      userId: _toInt(json['user_id']),
      driverId: _toIntNullable(json['driver_id']),
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
      invoice: Invoice.fromJson(invoiceJson),
      product: Product.fromJson(productJson),
    );
  }
}

/// ===================== INVOICE (nested object) =====================
class Invoice {
  final int id;
  final String? cusPhone;
  final String? cusEmail;
  final String? cusName;
  final double total;
  final double vat;
  final double payable;
  final String? paymentMethod;
  final String? status;
  final String? transactionId;
  final String taxRef;
  final String currency;
  final int userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Invoice({
    required this.id,
    required this.cusPhone,
    required this.cusEmail,
    required this.cusName,
    required this.total,
    required this.vat,
    required this.payable,
    required this.paymentMethod,
    required this.status,
    required this.transactionId,
    required this.taxRef,
    required this.currency,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    id: _toInt(json['id']),
    cusPhone: json['cus_phone']?.toString(),
    cusEmail: json['cus_email']?.toString(),
    cusName: json['cus_name']?.toString(),
    total: _toDouble(json['total']),
    vat: _toDouble(json['vat']),
    payable: _toDouble(json['payable']),
    paymentMethod: json['payment_method']?.toString(),
    status: json['status']?.toString(),
    transactionId: json['transaction_id']?.toString(),
    taxRef: json['tax_ref']?.toString() ?? '',
    currency: json['currency']?.toString() ?? '',
    userId: _toInt(json['user_id']),
    createdAt: _toDate(json['created_at']),
    updatedAt: _toDate(json['updated_at']),
  );
}

/// ===================== PRODUCT (nested object) =====================
class Product {
  final int id;
  final String name;
  final String description;
  final double regularPrice;
  final double sellPrice;
  final int discount;
  final String? publicId;
  final double star;
  final String image;
  final List<String> color;
  final List<String> size;
  final String remark;
  final bool isActive;
  final int vendorId;
  final int categoryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.regularPrice,
    required this.sellPrice,
    required this.discount,
    required this.publicId,
    required this.star,
    required this.image,
    required this.color,
    required this.size,
    required this.remark,
    required this.isActive,
    required this.vendorId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: _toInt(json['id']),
    name: json['name']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    regularPrice: _toDouble(json['regular_price']),
    sellPrice: _toDouble(json['sell_price']),
    discount: _toInt(json['discount']),
    publicId: json['public_id']?.toString(),
    star: _toDouble(json['star']),
    image: json['image']?.toString() ?? '',
    color: _normalizeStringList(json['color']),
    size: _normalizeStringList(json['size']),
    remark: json['remark']?.toString() ?? '',
    isActive: _toBool(json['is_active']),
    vendorId: _toInt(json['vendor_id']),
    categoryId: _toInt(json['category_id']),
    createdAt: _toDate(json['created_at']),
    updatedAt: _toDate(json['updated_at']),
  );
}

/* ===================== helpers ===================== */

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

int? _toIntNullable(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString());
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

double? _toDoubleNullable(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

bool _toBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().toLowerCase();
  return s == 'true' || s == '1';
}

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

List<String> _normalizeStringList(dynamic v) {
  final out = <String>[];
  if (v == null) return out;

  void addFromString(String s) {
    if (s.contains(',')) {
      for (final p in s.split(',')) {
        final t = p.trim();
        if (t.isNotEmpty) out.add(t);
      }
    } else {
      final t = s.trim();
      if (t.isNotEmpty) out.add(t);
    }
  }

  if (v is List) {
    for (final e in v) {
      if (e != null) addFromString(e.toString());
    }
  } else if (v is String) {
    addFromString(v);
  } else {
    addFromString(v.toString());
  }
  return out;
}
