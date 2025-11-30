import 'dart:convert';

DriverTrackingResponse driverTrackingResponseFromJson(String s) =>
    DriverTrackingResponse.fromJson(jsonDecode(s) as Map<String, dynamic>);

class DriverTrackingResponse {
  final String status;
  final String message;
  final DriverTrackingData data;

  DriverTrackingResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DriverTrackingResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>?;

    return DriverTrackingResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: DriverTrackingData.fromJson(dataJson ?? <String, dynamic>{}),
    );
  }
}

/// ================== data object (main info) ==================

class DriverTrackingData {
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

  // JSON e je gula ache:
  final String cusName;
  final String cusEmail;
  final String cusPhone;
  final String pickupAddress;
  final String shipAddress;
  final String? currentAddress;
  final String? note;
  final String? currentLatitude;
  final String? currentLongitude;
  final double? shipLatitude;
  final double? shipLongitude;
  final String? distance;
  final String deliveryCharge;
  final int userId;

  final TrackingInvoice? invoice;
  final TrackingUser? user;
  final TrackingDriver? driver;

  DriverTrackingData({
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
    required this.userId,
    required this.invoice,
    required this.user,
    required this.driver,
  });

  factory DriverTrackingData.fromJson(Map<String, dynamic> json) {
    return DriverTrackingData(
      id: _toInt(json['id']),
      quantity: _toInt(json['quantity']),
      tranId: (json['tran_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      salePrice: _toDouble(json['sale_price']),
      invoiceId: _toInt(json['invoice_id']),
      productId: _toInt(json['product_id']),
      vendorId: _toInt(json['vendor_id']),
      driverId: _toInt(json['driver_id']),
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),

      cusName: (json['cus_name'] ?? '').toString(),
      cusEmail: (json['cus_email'] ?? '').toString(),
      cusPhone: (json['cus_phone'] ?? '').toString(),
      pickupAddress: (json['pickup_address'] ?? '').toString(),
      shipAddress: (json['ship_address'] ?? '').toString(),
      currentAddress: json['current_address']?.toString(),
      note: json['note']?.toString(),
      currentLatitude: json['current_latitude']?.toString(),
      currentLongitude: json['current_longitude']?.toString(),
      shipLatitude: _toDoubleOrNull(json['ship_latitude']),
      shipLongitude: _toDoubleOrNull(json['ship_longitude']),
      distance: json['distance']?.toString(),
      deliveryCharge: (json['delivery_charge'] ?? '0').toString(),
      userId: _toInt(json['user_id']),

      invoice: json['invoice'] == null
          ? null
          : TrackingInvoice.fromJson(json['invoice'] as Map<String, dynamic>),

      user: json['user'] == null
          ? null
          : TrackingUser.fromJson(json['user'] as Map<String, dynamic>),

      driver: json['driver'] == null
          ? null
          : TrackingDriver.fromJson(json['driver'] as Map<String, dynamic>),
    );
  }
}

/// ================== invoice object (only existing fields) ==================

class TrackingInvoice {
  final int id;
  final String total;
  final String vat;
  final String payable;
  final String cusName;
  final String cusEmail;
  final String cusPhone;
  final String paymentMethod;
  final String status;
  final String transactionId;
  final String taxRef;
  final String currency;
  final int userId;
  final String createdAt;
  final String updatedAt;

  TrackingInvoice({
    required this.id,
    required this.total,
    required this.vat,
    required this.payable,
    required this.cusName,
    required this.cusEmail,
    required this.cusPhone,
    required this.paymentMethod,
    required this.status,
    required this.transactionId,
    required this.taxRef,
    required this.currency,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrackingInvoice.fromJson(Map<String, dynamic> json) {
    return TrackingInvoice(
      id: json['id'] ?? 0,
      total: json['total']?.toString() ?? '',
      vat: json['vat']?.toString() ?? '',
      payable: json['payable']?.toString() ?? '',
      cusName: json['cus_name']?.toString() ?? '',
      cusEmail: json['cus_email']?.toString() ?? '',
      cusPhone: json['cus_phone']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString() ?? '',
      taxRef: json['tax_ref']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

/// ================== user object ==================

class TrackingUser {
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

  TrackingUser({
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

  factory TrackingUser.fromJson(Map<String, dynamic> json) {
    final ia = json['is_active'];

    return TrackingUser(
      id: json['id'] ?? 0,
      userType: json['user_type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isOnline: json['is_online'] == true || json['is_online'] == 1,
      phone: json['phone']?.toString() ?? '',
      otp: json['otp']?.toString(),
      phoneVerifiedAt: json['phone_verified_at']?.toString(),
      language: json['language']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      publicId: json['public_id']?.toString(),
      inviteToken: json['invite_token']?.toString(),
      status: json['status']?.toString() ?? '',
      isActive: ia == null ? null : (ia == true || ia == 1),
      lastActiveAt: json['last_active_at']?.toString(),
      mustChangePassword: _toInt(json['must_change_password']),
      expiresAt: json['expires_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

/// ================== driver object ==================

class TrackingDriver {
  final int id;
  final String carName;
  final String carModel;
  final String location;
  final String price;
  final int rating;
  final String description;
  final int userId;
  final int routeId;
  final String createdAt;
  final String updatedAt;

  TrackingDriver({
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

  factory TrackingDriver.fromJson(Map<String, dynamic> json) {
    return TrackingDriver(
      id: json['id'] ?? 0,
      carName: json['car_name']?.toString() ?? '',
      carModel: json['car_model']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      rating: _toInt(json['rating']),
      description: json['description']?.toString() ?? '',
      userId: _toInt(json['user_id']),
      routeId: _toInt(json['route_id']),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

/// ================== helpers ==================

int _toInt(dynamic v) =>
    v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);

double _toDouble(dynamic v) => v == null
    ? 0.0
    : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

double? _toDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  return double.tryParse(s);
}
