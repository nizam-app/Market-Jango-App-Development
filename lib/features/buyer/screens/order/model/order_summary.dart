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

/// Pagination container
class OrdersPageData {
  final int currentPage;
  final List<Order> orders;
  final String? firstPageUrl;
  final int? from;
  final int lastPage;
  final String? lastPageUrl;
  final List<PageLink> links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  OrdersPageData({
    required this.currentPage,
    required this.orders,
    required this.lastPage,
    required this.links,
    this.firstPageUrl,
    this.from,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory OrdersPageData.fromJson(Map<String, dynamic> json) {
    final List dataList =
    (json['data'] is List) ? (json['data'] as List) : const [];
    return OrdersPageData(
      currentPage: _toInt(json['current_page']),
      orders: dataList
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastPage: _toInt(json['last_page']),
      links: ((json['links'] as List?) ?? const [])
          .map((e) => PageLink.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstPageUrl: json['first_page_url']?.toString(),
      from: _toIntNullable(json['from']),
      lastPageUrl: json['last_page_url']?.toString(),
      nextPageUrl: json['next_page_url']?.toString(),
      path: json['path']?.toString(),
      perPage: _toIntNullable(json['per_page']),
      prevPageUrl: json['prev_page_url']?.toString(),
      to: _toIntNullable(json['to']),
      total: _toIntNullable(json['total']),
    );
  }
}

class PageLink {
  final String? url;
  final String? label;
  final int? page;
  final bool active;

  PageLink({this.url, this.label, this.page, required this.active});

  factory PageLink.fromJson(Map<String, dynamic> json) => PageLink(
    url: json['url']?.toString(),
    label: json['label']?.toString(),
    page: _toIntNullable(json['page']),
    active: json['active'] == true,
  );
}

/// ===================== ORDER =====================
class Order {
  final int id;
  final double total;
  final double vat;
  final double payable;
  final String cusName;
  final String cusEmail;
  final String cusPhone;
  final String shipAddress;
  final String shipCity;
  final String shipCountry;
  final String deliveryStatus;
  final String? status; // nullable
  final String? transactionId;
  final String taxRef;
  final String currency;
  final int userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int itemsCount;
  final List<OrderItem> items;

  Order({
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
    required this.deliveryStatus,
    required this.status,
    required this.transactionId,
    required this.taxRef,
    required this.currency,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.itemsCount,
    required this.items,
  });

  String get effectiveStatus =>
      (status?.isNotEmpty == true) ? status! : (deliveryStatus.isNotEmpty ? deliveryStatus : 'Pending');

  factory Order.fromJson(Map<String, dynamic> json) {
    final List rawItems = (json['items'] is List) ? (json['items'] as List) : const [];
    final items = rawItems
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return Order(
      id: _toInt(json['id']),
      total: _toDouble(json['total']),
      vat: _toDouble(json['vat']),
      payable: _toDouble(json['payable']),
      cusName: json['cus_name']?.toString() ?? '',
      cusEmail: json['cus_email']?.toString() ?? '',
      cusPhone: json['cus_phone']?.toString() ?? '',
      shipAddress: json['ship_address']?.toString() ?? '',
      shipCity: json['ship_city']?.toString() ?? '',
      shipCountry: json['ship_country']?.toString() ?? '',
      deliveryStatus: json['delivery_status']?.toString() ?? '',
      status: json['status']?.toString(),
      transactionId: json['transaction_id']?.toString(),
      taxRef: json['tax_ref']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      userId: _toInt(json['user_id']),
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
      itemsCount: (json['items_count'] is int)
          ? (json['items_count'] as int)
          : items.length,
      items: items,
    );
  }
}

/// ===================== ORDER ITEM =====================
class OrderItem {
  final int id;
  final int quantity;
  final String? tranId;
  final double salePrice;
  final int invoiceId;
  final int productId;
  final int vendorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Product product;

  OrderItem({
    required this.id,
    required this.quantity,
    required this.tranId,
    required this.salePrice,
    required this.invoiceId,
    required this.productId,
    required this.vendorId,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: _toInt(json['id']),
    quantity: _toInt(json['quantity']),
    tranId: json['tran_id']?.toString(),
    salePrice: _toDouble(json['sale_price']),
    invoiceId: _toInt(json['invoice_id']),
    productId: _toInt(json['product_id']),
    vendorId: _toInt(json['vendor_id']),
    createdAt: _toDate(json['created_at']),
    updatedAt: _toDate(json['updated_at']),
    product: Product.fromJson(
        (json['product'] as Map<String, dynamic>? ?? const {})),
  );
}

/// ===================== PRODUCT =====================
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