// transport_orders_model.dart
class TransportOrdersResponse {
  final String status;
  final String message;
  final TransportOrdersPage data;

  TransportOrdersResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TransportOrdersResponse.fromJson(Map<String, dynamic> json) {
    return TransportOrdersResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: TransportOrdersPage.fromJson(json['data'] ?? <String, dynamic>{}),
    );
  }
}

class TransportOrdersPage {
  final int currentPage;
  final List<TransportOrder> data;
  final int lastPage;
  final String path;
  final int perPage;
  final int? to;
  final int total;

  TransportOrdersPage({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory TransportOrdersPage.fromJson(Map<String, dynamic> json) {
    return TransportOrdersPage(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List? ?? [])
          .map((e) => TransportOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastPage: json['last_page'] ?? 1,
      path: json['path'] ?? '',
      perPage: (json['per_page'] is int)
          ? json['per_page']
          : int.tryParse('${json['per_page']}') ?? 10,
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }
}

class TransportOrder {
  final int id;
  final String total;
  final String vat;
  final String payable;
  final String cusName;
  final String cusEmail;
  final String cusPhone;
  final String? shipAddress;
  final String? shipCity;
  final String? shipCountry;
  final String pickupAddress;
  final String dropOfAddress;
  final String distance;
  final String deliveryStatus;
  final String? status;
  final String? transactionId;
  final String taxRef;
  final String currency;
  final int userId;
  final String createdAt;
  final String updatedAt;
  final int itemsCount;
  final List<TransportOrderItem> items;

  TransportOrder({
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
    required this.itemsCount,
    required this.items,
  });

  factory TransportOrder.fromJson(Map<String, dynamic> json) {
    return TransportOrder(
      id: json['id'] ?? 0,
      total: '${json['total'] ?? ''}',
      vat: '${json['vat'] ?? ''}',
      payable: '${json['payable'] ?? ''}',
      cusName: json['cus_name'] ?? '',
      cusEmail: json['cus_email'] ?? '',
      cusPhone: json['cus_phone'] ?? '',
      shipAddress: json['ship_address'],
      shipCity: json['ship_city'],
      shipCountry: json['ship_country'],
      pickupAddress: json['pickup_address'] ?? '',
      dropOfAddress: json['drop_of_address'] ?? '',
      distance: '${json['distance'] ?? ''}',
      deliveryStatus: json['delivery_status'] ?? '',
      status: json['status'],
      transactionId: json['transaction_id'],
      taxRef: json['tax_ref'] ?? '',
      currency: json['currency'] ?? '',
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      itemsCount: json['items_count'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => TransportOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TransportOrderItem {
  final int id;
  final int? quantity;
  final String tranId;
  final num salePrice;
  final int invoiceId;
  final int? productId;
  final int? vendorId;
  final int? driverId;
  final String createdAt;
  final String updatedAt;
  final DriverBrief? driver;

  TransportOrderItem({
    required this.id,
    required this.quantity,
    required this.tranId,
    required this.salePrice,
    required this.invoiceId,
    required this.productId,
    required this.vendorId,
    required this.driverId,
    required this.createdAt,
    required this.updatedAt,
    required this.driver,
  });

  factory TransportOrderItem.fromJson(Map<String, dynamic> json) {
    return TransportOrderItem(
      id: json['id'] ?? 0,
      quantity: json['quantity'],
      tranId: json['tran_id'] ?? '',
      salePrice: json['sale_price'] ?? 0,
      invoiceId: json['invoice_id'] ?? 0,
      productId: json['product_id'],
      vendorId: json['vendor_id'],
      driverId: json['driver_id'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      driver: (json['driver'] != null)
          ? DriverBrief.fromJson(json['driver'])
          : null,
    );
  }
}

class DriverBrief {
  final int id;
  final String carName;
  final String carModel;
  final String location;
  final String price;
  final num rating;
  final int userId;
  final int routeId;
  final String createdAt;
  final String updatedAt;

  DriverBrief({
    required this.id,
    required this.carName,
    required this.carModel,
    required this.location,
    required this.price,
    required this.rating,
    required this.userId,
    required this.routeId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverBrief.fromJson(Map<String, dynamic> json) {
    return DriverBrief(
      id: json['id'] ?? 0,
      carName: json['car_name'] ?? '',
      carModel: json['car_model'] ?? '',
      location: json['location'] ?? '',
      price: '${json['price'] ?? ''}',
      rating: json['rating'] ?? 0,
      userId: json['user_id'] ?? 0,
      routeId: json['route_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}