// models/driver_all_orders_model.dart
import 'dart:convert';

DriverAllOrdersResponse driverAllOrdersResponseFromJson(String s) =>
    DriverAllOrdersResponse.fromJson(jsonDecode(s) as Map<String, dynamic>);

class DriverAllOrdersResponse {
  final String status;
  final String? message;
  final OrdersPage data;

  DriverAllOrdersResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DriverAllOrdersResponse.fromJson(Map<String, dynamic> j) {
    final rawData = j['data'];

    // backend কখনও কখনও শুধু list পাঠালে / null দিলে crash আটকানোর জন্য
    if (rawData is Map<String, dynamic>) {
      return DriverAllOrdersResponse(
        status: (j['status'] ?? '').toString(),
        message: j['message']?.toString(),
        data: OrdersPage.fromJson(rawData),
      );
    } else if (rawData is List) {
      return DriverAllOrdersResponse(
        status: (j['status'] ?? '').toString(),
        message: j['message']?.toString(),
        data: OrdersPage.fromList(rawData),
      );
    } else {
      return DriverAllOrdersResponse(
        status: (j['status'] ?? '').toString(),
        message: j['message']?.toString(),
        data: OrdersPage.empty(),
      );
    }
  }
}

/// "data": { "data": [ ... ] }
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

    final cp = _toInt(j['current_page']);
    final lp = _toInt(j['last_page']);

    return OrdersPage(
      currentPage: cp == 0 ? 1 : cp,
      lastPage: lp == 0 ? 1 : lp,
      data: list,
    );
  }

  factory OrdersPage.fromList(List<dynamic> listJson) {
    final list = listJson
        .map((e) => DriverOrderEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    return OrdersPage(currentPage: 1, lastPage: 1, data: list);
  }

  factory OrdersPage.empty() =>
      OrdersPage(currentPage: 1, lastPage: 1, data: const []);
}

/// ================== ORDER (outer object) ==================
class DriverOrderEntity {
  final int id;
  final int quantity;
  final String tranId;
  final String status; // e.g. "AssignedOrder", "Complete", "Not Deliver"
  final double salePrice;
  final int invoiceId;
  final int productId;
  final int vendorId;
  final int userId;
  final int driverId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // customer + address
  final String cusName;
  final String cusEmail;
  final String cusPhone;
  final String pickupAddress;
  final String shipAddress;
  final String? currentAddress;
  final String? note;

  // geo
  final double? currentLatitude;
  final double? currentLongitude;
  final double? shipLatitude;
  final double? shipLongitude;

  // others
  final String? distance; // "0.00"
  final String deliveryCharge; // "0.00"

  final InvoiceEntity? invoice;
  final ProductEntity? product;

  DriverOrderEntity({
    required this.id,
    required this.quantity,
    required this.tranId,
    required this.status,
    required this.salePrice,
    required this.invoiceId,
    required this.productId,
    required this.vendorId,
    required this.userId,
    required this.driverId,
    required this.createdAt,
    required this.updatedAt,
    required this.cusName,
    required this.cusEmail,
    required this.cusPhone,
    required this.pickupAddress,
    required this.shipAddress,
    required this.currentAddress,
    required this.note,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.shipLatitude,
    required this.shipLongitude,
    required this.distance,
    required this.deliveryCharge,
    required this.invoice,
    required this.product,
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
      userId: _toInt(j['user_id']),
      driverId: _toInt(j['driver_id']),
      createdAt: _toDate(j['created_at']),
      updatedAt: _toDate(j['updated_at']),

      cusName: (j['cus_name'] ?? '').toString(),
      cusEmail: (j['cus_email'] ?? '').toString(),
      cusPhone: (j['cus_phone'] ?? '').toString(),
      pickupAddress: (j['pickup_address'] ?? '').toString(),
      shipAddress: (j['ship_address'] ?? '').toString(),

      currentAddress: j['current_address']?.toString(),
      note: j['note']?.toString(),

      currentLatitude: _toDoubleOrNull(j['current_latitude']),
      currentLongitude: _toDoubleOrNull(j['current_longitude']),
      shipLatitude: _toDoubleOrNull(j['ship_latitude']),
      shipLongitude: _toDoubleOrNull(j['ship_longitude']),

      distance: j['distance']?.toString(),
      deliveryCharge: (j['delivery_charge'] ?? '0').toString(),

      invoice: j['invoice'] == null
          ? null
          : InvoiceEntity.fromJson(j['invoice'] as Map<String, dynamic>),
      product: j['product'] == null
          ? null
          : ProductEntity.fromJson(j['product'] as Map<String, dynamic>),
    );
  }
}

/// ================== INVOICE ==================
class InvoiceEntity {
  final int id;
  final String total;
  final String vat;
  final String payable;
  final String? paymentMethod;
  final String status; // "successful", "Pending" ...
  final String transactionId; // can be empty string if null
  final String taxRef; // order id reference
  final String currency;
  final String cusName;
  final String cusEmail;
  final String cusPhone;
  final int userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InvoiceEntity({
    required this.id,
    required this.total,
    required this.vat,
    required this.payable,
    required this.paymentMethod,
    required this.status,
    required this.transactionId,
    required this.taxRef,
    required this.currency,
    required this.cusName,
    required this.cusEmail,
    required this.cusPhone,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceEntity.fromJson(Map<String, dynamic> j) {
    return InvoiceEntity(
      id: _toInt(j['id']),
      total: (j['total'] ?? '0').toString(),
      vat: (j['vat'] ?? '0').toString(),
      payable: (j['payable'] ?? '0').toString(),
      paymentMethod: j['payment_method']?.toString(),
      status: (j['status'] ?? '').toString(),
      transactionId: (j['transaction_id'] ?? '').toString(),
      taxRef: (j['tax_ref'] ?? '').toString(),
      currency: (j['currency'] ?? '').toString(),
      cusName: (j['cus_name'] ?? '').toString(),
      cusEmail: (j['cus_email'] ?? '').toString(),
      cusPhone: (j['cus_phone'] ?? '').toString(),
      userId: _toInt(j['user_id']),
      createdAt: _toDate(j['created_at']),
      updatedAt: _toDate(j['updated_at']),
    );
  }
}

/// ================== PRODUCT ==================
class ProductEntity {
  final int id;
  final String name;
  final String description;
  final String regularPrice;
  final String sellPrice;
  final int discount;
  final String publicId;
  final int star;
  final String image;
  final List<String> color;
  final List<String> size;
  final String remark;
  final int isActive;
  final int newItem;
  final int justForYou;
  final int topProduct;
  final int vendorId;
  final int categoryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductEntity({
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
    required this.newItem,
    required this.justForYou,
    required this.topProduct,
    required this.vendorId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductEntity.fromJson(Map<String, dynamic> j) {
    return ProductEntity(
      id: _toInt(j['id']),
      name: (j['name'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      regularPrice: (j['regular_price'] ?? '').toString(),
      sellPrice: (j['sell_price'] ?? '').toString(),
      discount: _toInt(j['discount']),
      publicId: (j['public_id'] ?? '').toString(),
      star: _toInt(j['star']),
      image: (j['image'] ?? '').toString(),
      color: ((j['color'] as List?) ?? []).map((e) => e.toString()).toList(),
      size: ((j['size'] as List?) ?? []).map((e) => e.toString()).toList(),
      remark: (j['remark'] ?? '').toString(),
      isActive: _toInt(j['is_active']),
      newItem: _toInt(j['new_item']),
      justForYou: _toInt(j['just_for_you']),
      topProduct: _toInt(j['top_product']),
      vendorId: _toInt(j['vendor_id']),
      categoryId: _toInt(j['category_id']),
      createdAt: _toDate(j['created_at']),
      updatedAt: _toDate(j['updated_at']),
    );
  }
}

/// ================== helpers ==================
int _toInt(dynamic v) =>
    v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);

double _toDouble(dynamic v) => v == null
    ? 0.0
    : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);

double? _toDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  return double.tryParse(s);
}

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return null;
  }
}
