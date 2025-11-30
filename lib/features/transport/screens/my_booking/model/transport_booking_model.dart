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
/// API structure:
/// {
///   "status": "success",
///   "message": "...",
///   "data": {
///     "data": [ { row }, { row }, ... ],
///     "current_page": ?,   // optional
///     "last_page": ?,      // optional
///     "total": ?           // optional
///   }
/// }

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
    final rawList = j['data'] as List? ?? [];
    final list = rawList
        .map((e) => TransportOrder.fromJson(e as Map<String, dynamic>))
        .toList();

    final cpRaw = j['current_page'];
    final lpRaw = j['last_page'];
    final totalRaw = j['total'];

    return TransportOrdersPage(
      currentPage: cpRaw == null ? 1 : _toInt(cpRaw),
      lastPage: lpRaw == null ? 1 : _toInt(lpRaw),
      total: totalRaw == null ? list.length : _toInt(totalRaw),
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

/// ================= INVOICE / ORDER (UI wrapper) =================
/// Ekta row structure:
/// {
///   "id": ...
///   "cus_name": ...
///   ... item fields ...
///   "invoice": { ... },
///   "driver": { ... }
/// }

class TransportOrder {
  final int id;
  final String cusPhone;
  final String cusEmail;
  final String cusName;

  final double total;
  final double vat;
  final double payable;

  final String paymentMethod;
  final String status; // invoice status: Pending / Successful / Cancelled
  final String transactionId;
  final String taxRef;
  final String currency;
  final int userId;

  /// iso string
  final String createdAt;
  final String updatedAt;

  final int itemsCount;
  final List<TransportOrderItem> items;

  /// convenience field for UI
  final String pickupAddress; // row / item theke
  final String dropOfAddress; // row / item theke

  /// 🚚 UI combined status (Pending / On the way / Completed)
  /// ❗ Cancelled / Canceled / Rejected / Not Deliver -> ekhaneo "On the way"
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
    // ek row theke real item (row = ekta item)
    final item = TransportOrderItem.fromJson(j);

    // nested invoice
    final inv = j['invoice'] as Map<String, dynamic>?;

    final invoiceStatus = (inv?['status'] ?? '').toString();
    final itemStatus = item.status;

    final deliveryStatus = _combineDeliveryStatus(invoiceStatus, itemStatus);

    final pickupAddress = (item.pickupAddress ?? j['pickup_address'] ?? '')
        .toString();
    final dropOfAddress = (item.shipAddress).toString();

    return TransportOrder(
      id: _toInt(inv?['id'] ?? j['id']),
      cusPhone: (inv?['cus_phone'] ?? j['cus_phone'] ?? '').toString(),
      cusEmail: (inv?['cus_email'] ?? j['cus_email'] ?? '').toString(),
      cusName: (inv?['cus_name'] ?? j['cus_name'] ?? '').toString(),
      total: _toDouble(inv?['total']),
      vat: _toDouble(inv?['vat']),
      payable: _toDouble(inv?['payable']),
      paymentMethod: (inv?['payment_method'] ?? j['payment_method'] ?? '')
          .toString(),
      status: invoiceStatus,
      transactionId: (inv?['transaction_id'] ?? j['transaction_id'] ?? '')
          .toString(),
      taxRef: (inv?['tax_ref'] ?? j['tax_ref'] ?? '').toString(),
      currency: (inv?['currency'] ?? j['currency'] ?? '').toString(),
      userId: _toInt(inv?['user_id'] ?? j['user_id']),
      createdAt: (inv?['created_at'] ?? j['created_at'] ?? '').toString(),
      updatedAt: (inv?['updated_at'] ?? j['updated_at'] ?? '').toString(),
      itemsCount: 1,
      items: [item],
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
  final String status; // AssignedOrder, Pending, Cancelled, Not Deliver...

  final double distance;
  final String? paymentMethod; // item level
  final double? salePrice;
  final double deliveryCharge;
  final String? paymentProofId;
  final double? totalPay;

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
    required this.paymentMethod,
    required this.salePrice,
    required this.deliveryCharge,
    required this.paymentProofId,
    required this.totalPay,
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
      paymentMethod: j['payment_method']?.toString(),
      salePrice: j['sale_price'] == null ? null : _toDouble(j['sale_price']),
      deliveryCharge: _toDouble(j['delivery_charge']),
      paymentProofId: j['payment_proof_id']?.toString(),
      totalPay: j['total_pay'] == null ? null : _toDouble(j['total_pay']),
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

  final TransportDriverUser? user;

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
    required this.user,
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
      user: j['user'] == null
          ? null
          : TransportDriverUser.fromJson(j['user'] as Map<String, dynamic>),
    );
  }
}

/// ================= DRIVER.USER =================

class TransportDriverUser {
  final int id;
  final String userType;
  final String name;
  final String email;
  final bool isOnline;
  final String phone;
  final String? otp;
  final String? phoneVerifiedAt;
  final String language;
  final String image;
  final String? publicId;
  final String? inviteToken;
  final String status;
  final bool? isActive;
  final String? lastActiveAt;
  final int mustChangePassword;
  final String? expiresAt;
  final String createdAt;
  final String updatedAt;

  TransportDriverUser({
    required this.id,
    required this.userType,
    required this.name,
    required this.email,
    required this.isOnline,
    required this.phone,
    required this.otp,
    required this.phoneVerifiedAt,
    required this.language,
    required this.image,
    required this.publicId,
    required this.inviteToken,
    required this.status,
    required this.isActive,
    required this.lastActiveAt,
    required this.mustChangePassword,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransportDriverUser.fromJson(Map<String, dynamic> j) {
    return TransportDriverUser(
      id: _toInt(j['id']),
      userType: (j['user_type'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      email: (j['email'] ?? '').toString(),
      isOnline: j['is_online'] == true,
      phone: (j['phone'] ?? '').toString(),
      otp: j['otp']?.toString(),
      phoneVerifiedAt: j['phone_verified_at']?.toString(),
      language: (j['language'] ?? '').toString(),
      image: (j['image'] ?? '').toString(),
      publicId: j['public_id']?.toString(),
      inviteToken: j['invite_token']?.toString(),
      status: (j['status'] ?? '').toString(),
      isActive: j['is_active'] is bool ? j['is_active'] as bool? : null,
      lastActiveAt: j['last_active_at']?.toString(),
      mustChangePassword: _toInt(j['must_change_password']),
      expiresAt: j['expires_at']?.toString(),
      createdAt: (j['created_at'] ?? '').toString(),
      updatedAt: (j['updated_at'] ?? '').toString(),
    );
  }
}

/// ================= STATUS COMBINE LOGIC =================
/// OUTPUT:
///  - "Completed"
///  - "On the way"
///
/// 🔥 IMPORTANT:
///   Cancelled / Canceled / Rejected / Not Deliver -> "On the way"

String _combineDeliveryStatus(String invoiceStatus, String itemStatus) {
  final inv = invoiceStatus.toLowerCase().trim();
  final itm = itemStatus.toLowerCase().trim();
  final s = '$inv|$itm';

  // 1) Not Deliver explicitly -> On the way
  if (s.contains('not deliver')) {
    return 'On the way';
  }

  // 2) Completed / Delivered / Successful
  if (s.contains('complete') ||
      s.contains('delivered') ||
      s.contains('success')) {
    return 'Completed';
  }

  // 3) Cancelled / Canceled / Rejected -> On the way
  if (s.contains('cancel') || s.contains('reject')) {
    return 'On the way';
  }

  // 4) baki shob
  return 'On the way';
}

/// ================= HELPERS =================

int _toInt(dynamic v) =>
    v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);

double _toDouble(dynamic v) => v == null
    ? 0.0
    : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);
