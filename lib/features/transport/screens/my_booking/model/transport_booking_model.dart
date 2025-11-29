import 'dart:convert';

/// ================= TOP LEVEL RESPONSE =================

TransportOrdersResponse transportOrdersResponseFromJson(String source) =>
    TransportOrdersResponse.fromJson(
      jsonDecode(source) as Map<String, dynamic>,
    );

class TransportOrdersResponse {
  final String status;
  final String message;
  final TransportOrdersPage data;

  TransportOrdersResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TransportOrdersResponse.fromJson(Map<String, dynamic> j) {
    final rawData = j['data'];

    return TransportOrdersResponse(
      status: (j['status'] ?? '').toString(),
      message: (j['message'] ?? '').toString(),
      data: rawData is Map<String, dynamic>
          ? TransportOrdersPage.fromJson(rawData)
          : TransportOrdersPage.empty(),
    );
  }
}

/// ================= PAGE (pagination wrapper) =================

class TransportOrdersPage {
  final int currentPage;
  final int lastPage;
  final int total;
  final List<TransportOrder> data;

  TransportOrdersPage({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.data,
  });

  factory TransportOrdersPage.fromJson(Map<String, dynamic> j) {
    final list = (j['data'] as List? ?? [])
        .map((e) => TransportOrder.fromJson(e as Map<String, dynamic>))
        .toList();

    return TransportOrdersPage(
      currentPage: _toInt(j['current_page']),
      lastPage: _toInt(j['last_page']),
      total: _toInt(j['total']),
      data: list,
    );
  }

  factory TransportOrdersPage.empty() => TransportOrdersPage(
    currentPage: 1,
    lastPage: 1,
    total: 0,
    data: const [],
  );
}

/// ================= INVOICE / ORDER =================

class TransportOrder {
  final int id;
  final String cusPhone;
  final String cusEmail;
  final String cusName;

  final double total;
  final double vat;
  final double payable;

  final String paymentMethod;
  final String status; // invoice status: Pending / successful / Cancelled
  final String transactionId;
  final String taxRef;
  final String currency;
  final int userId;

  /// iso string (UI te String diyei use korcho)
  final String createdAt;
  final String updatedAt;

  final int itemsCount;
  final List<TransportOrderItem> items;

  /// convenience field for UI
  final String pickupAddress; // first item theke
  final String dropOfAddress; // first item ship_address

  /// 🚚 UI combined status (Pending / On the way / Completed)
  /// ❗ Cancelled / Canceled / Rejected -> ekhaneo "On the way"
  final String deliveryStatus;

  TransportOrder({
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
    required this.itemsCount,
    required this.items,
    required this.pickupAddress,
    required this.dropOfAddress,
    required this.deliveryStatus,
  });

  factory TransportOrder.fromJson(Map<String, dynamic> j) {
    final items = (j['items'] as List? ?? [])
        .map((e) => TransportOrderItem.fromJson(e as Map<String, dynamic>))
        .toList();

    final firstItem = items.isNotEmpty ? items.first : null;

    final pickupAddress = (firstItem?.pickupAddress ?? '').toString();
    final dropOfAddress = (firstItem?.shipAddress ?? '').toString();

    final invoiceStatus = (j['status'] ?? '').toString();
    final itemStatus = (firstItem?.status ?? '').toString();

    final deliveryStatus = _combineDeliveryStatus(invoiceStatus, itemStatus);

    return TransportOrder(
      id: _toInt(j['id']),
      cusPhone: (j['cus_phone'] ?? '').toString(),
      cusEmail: (j['cus_email'] ?? '').toString(),
      cusName: (j['cus_name'] ?? '').toString(),
      total: _toDouble(j['total']),
      vat: _toDouble(j['vat']),
      payable: _toDouble(j['payable']),
      paymentMethod: (j['payment_method'] ?? '').toString(),
      status: invoiceStatus,
      transactionId: (j['transaction_id'] ?? '').toString(),
      taxRef: (j['tax_ref'] ?? '').toString(),
      currency: (j['currency'] ?? '').toString(),
      userId: _toInt(j['user_id']),
      createdAt: (j['created_at'] ?? '').toString(),
      updatedAt: (j['updated_at'] ?? '').toString(),
      itemsCount: _toInt(j['items_count']),
      items: items,
      pickupAddress: pickupAddress,
      dropOfAddress: dropOfAddress,
      deliveryStatus: deliveryStatus,
    );
  }
}

/// ================= ORDER ITEM =================

class TransportOrderItem {
  final int id;
  final String cusName;
  final String cusEmail;
  final String cusPhone;

  final String? pickupAddress;
  final String? currentAddress;
  final String? note;
  final String? currentLatitude;
  final String? currentLongitude;

  final String shipAddress;
  final String shipLatitude;
  final String shipLongitude;

  final int? quantity;
  final String tranId;
  final String status; // AssignedOrder, Pending, Cancelled...

  final double distance;
  final double? salePrice;
  final double deliveryCharge;

  final int invoiceId;
  final int? productId;
  final int? vendorId;
  final int userId;
  final int? driverId;

  final String createdAt;
  final String updatedAt;

  final TransportOrderDriver? driver;

  TransportOrderItem({
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
    required this.driver,
  });

  factory TransportOrderItem.fromJson(Map<String, dynamic> j) {
    return TransportOrderItem(
      id: _toInt(j['id']),
      cusName: (j['cus_name'] ?? '').toString(),
      cusEmail: (j['cus_email'] ?? '').toString(),
      cusPhone: (j['cus_phone'] ?? '').toString(),
      pickupAddress: j['pickup_address']?.toString(),
      currentAddress: j['current_address']?.toString(),
      note: j['note']?.toString(),
      currentLatitude: j['current_latitude']?.toString(),
      currentLongitude: j['current_longitude']?.toString(),
      shipAddress: (j['ship_address'] ?? '').toString(),
      shipLatitude: (j['ship_latitude'] ?? '').toString(),
      shipLongitude: (j['ship_longitude'] ?? '').toString(),
      quantity: j['quantity'] == null ? null : _toInt(j['quantity']),
      tranId: (j['tran_id'] ?? '').toString(),
      status: (j['status'] ?? '').toString(),
      distance: _toDouble(j['distance']),
      salePrice: j['sale_price'] == null ? null : _toDouble(j['sale_price']),
      deliveryCharge: _toDouble(j['delivery_charge']),
      invoiceId: _toInt(j['invoice_id']),
      productId: j['product_id'] == null ? null : _toInt(j['product_id']),
      vendorId: j['vendor_id'] == null ? null : _toInt(j['vendor_id']),
      userId: _toInt(j['user_id']),
      driverId: j['driver_id'] == null ? null : _toInt(j['driver_id']),
      createdAt: (j['created_at'] ?? '').toString(),
      updatedAt: (j['updated_at'] ?? '').toString(),
      driver: j['driver'] == null
          ? null
          : TransportOrderDriver.fromJson(j['driver'] as Map<String, dynamic>),
    );
  }
}

/// ================= DRIVER =================

class TransportOrderDriver {
  final int id;
  final String carName;
  final String carModel;
  final String location;
  final double price;
  final double rating;
  final String description;
  final int userId;
  final int routeId;
  final String createdAt;
  final String updatedAt;

  TransportOrderDriver({
    required this.id,
    required this.carName,
    required this.carModel,
    required this.location,
    required this.price,
    required this.rating,
    required this.description,
    required this.userId,
    required this.routeId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransportOrderDriver.fromJson(Map<String, dynamic> j) {
    return TransportOrderDriver(
      id: _toInt(j['id']),
      carName: (j['car_name'] ?? '').toString(),
      carModel: (j['car_model'] ?? '').toString(),
      location: (j['location'] ?? '').toString(),
      price: _toDouble(j['price']),
      rating: _toDouble(j['rating']),
      description: (j['description'] ?? '').toString(),
      userId: _toInt(j['user_id']),
      routeId: _toInt(j['route_id']),
      createdAt: (j['created_at'] ?? '').toString(),
      updatedAt: (j['updated_at'] ?? '').toString(),
    );
  }
}

/// ================= STATUS COMBINE LOGIC =================
/// ekhane amra invoice.status + item.status diye ekta
/// high level "deliveryStatus" banacchi.
///
/// OUTPUT:
///  - "Completed"
///  - "On the way"
///
/// 🔥 IMPORTANT:
///   Cancelled / Canceled / Rejected -> "On the way"
///   mane Cancelled kono jaygay dekhabo na, sob On the way hisabe show hobe.

String _combineDeliveryStatus(String invoiceStatus, String itemStatus) {
  final inv = invoiceStatus.toLowerCase().trim();
  final itm = itemStatus.toLowerCase().trim();
  final s = '$inv|$itm';

  if (s.contains('complete') ||
      s.contains('deliver') ||
      s.contains('success')) {
    return 'Completed';
  }

  // ❗ Cancelled, Canceled, Rejected -> On the way
  if (s.contains('cancel') || s.contains('reject')) {
    return 'On the way';
  }

  // Pending / AssignedOrder / Ongoing / Processing / others -> On the way
  return 'On the way';
}

/// ================= HELPERS =================

int _toInt(dynamic v) =>
    v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);

double _toDouble(dynamic v) => v == null
    ? 0.0
    : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);
