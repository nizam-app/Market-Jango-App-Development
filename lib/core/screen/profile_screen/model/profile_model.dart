// profile_response_model.dart (chaile same file e rakhte paro)

// Top level: status, message, data{ user, images, review_count }
class UserProfileResponse {
  final String status;
  final String message;
  final UserProfileData data;

  UserProfileResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: UserProfileData.fromJson(
        (json['data'] as Map<String, dynamic>? ?? const {}),
      ),
    );
  }
}

class UserProfileData {
  final UserModel user;
  final List<UserImage> images;
  final int reviewCount;

  UserProfileData({
    required this.user,
    required this.images,
    required this.reviewCount,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      user: UserModel.fromJson(
        (json['user'] as Map<String, dynamic>? ?? const {}),
      ),
      images: (json['images'] as List? ?? [])
          .where((e) => e is Map<String, dynamic>)
          .map((e) => UserImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviewCount: json['review_count'] is int
          ? json['review_count'] as int
          : int.tryParse(json['review_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class UserModel {
  // ==== your existing required fields (unchanged) ====
  final int id;
  final String name;
  final String image;
  final String email;
  final String phone;
  final String userType;
  final String status;

  // ==== extra meta (optional) ====
  final String? otp;
  final String? phoneVerifiedAt;
  final String? language;
  final String? publicId;
  final int? isActive;
  final String? expiresAt;
  final String? createdAt;
  final String? updatedAt;

  // ==== role specific (optional) ====
  final VendorInfo? vendor;
  final BuyerInfo? buyer;
  final DriverInfo? driver;
  final TransportInfo? transport;

  // ==== images (optional) ====
  final List<UserImage> userImages;

  UserModel({
    // required (keep same)
    required this.id,
    required this.name,
    required this.image,
    required this.email,
    required this.phone,
    required this.userType,
    required this.status,
    // optional
    this.otp,
    this.phoneVerifiedAt,
    this.language,
    this.publicId,
    this.isActive,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.vendor,
    this.buyer,
    this.driver,
    this.transport,
    this.userImages = const <UserImage>[],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // safe image fallback (same logic you used)
    final img = json['image'];
    final safeImage = (img is String && img.isNotEmpty)
        ? img
        : 'https://empy.com/images/no-image.png';

    return UserModel(
      // ==== base (unchanged) ====
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: safeImage,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['user_type'] ?? '',
      status: json['status'] ?? '',

      // ==== extra meta ====
      otp: json['otp']?.toString(),
      phoneVerifiedAt: json['phone_verified_at']?.toString(),
      language: json['language']?.toString(),
      publicId: json['public_id']?.toString(),
      isActive: json['is_active'] is int ? json['is_active'] as int : null,
      expiresAt: json['expires_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),

      // ==== nested roles (nullable) ====
      vendor: (json['vendor'] != null)
          ? VendorInfo.fromJson(json['vendor'])
          : null,
      buyer: (json['buyer'] != null) ? BuyerInfo.fromJson(json['buyer']) : null,
      driver: (json['driver'] != null)
          ? DriverInfo.fromJson(json['driver'])
          : null,
      transport: (json['transport'] != null)
          ? TransportInfo.fromJson(json['transport'])
          : null,

      // ==== user_images list ====
      userImages: (json['user_images'] as List? ?? [])
          .where((e) => e is Map<String, dynamic>)
          .map((e) => UserImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ---------------- Vendor ----------------
// ---------------- Vendor ----------------
class VendorInfo {
  final int id;
  final String country;
  final String address;
  final String businessName;
  final String businessType;
  final int userId;
  final String createdAt;
  final String updatedAt;

  // 🔹 extra fields from JSON (optional)
  final String? openTime;
  final String? closeTime;
  final String? latitude;
  final String? longitude;
  final double? avgRating;

  // 🔹 vendor.reviews[]
  final List<VendorReviewProfile> reviews;

  VendorInfo({
    required this.id,
    required this.country,
    required this.address,
    required this.businessName,
    required this.businessType,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.openTime,
    this.closeTime,
    this.latitude,
    this.longitude,
    this.avgRating,
    this.reviews = const <VendorReviewProfile>[],
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) => VendorInfo(
    id: json['id'] ?? 0,
    country: json['country'] ?? '',
    address: json['address'] ?? '',
    businessName: json['business_name'] ?? '',
    businessType: json['business_type'] ?? '',
    userId: json['user_id'] ?? 0,
    createdAt: json['created_at']?.toString() ?? '',
    updatedAt: json['updated_at']?.toString() ?? '',

    // extra
    openTime: json['open_time']?.toString(),
    closeTime: json['close_time']?.toString(),
    latitude: json['latitude']?.toString(),
    longitude: json['longitude']?.toString(),
    avgRating: json['avg_rating']?.toDouble(),

    // reviews list
    reviews: (json['reviews'] as List? ?? [])
        .where((e) => e is Map<String, dynamic>)
        .map((e) => VendorReviewProfile.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

// ---------------- Buyer ----------------
class BuyerInfo {
  final int id;
  final String gender;
  final String age;
  final String address;
  final String state;
  final String postcode;
  final String country;
  final String shipName;
  final String shipEmail;
  final String shipAddress;
  final String shipLocation;
  final String latitude;
  final String longitude;

  final String shipCity;
  final String shipState;
  final String shipCountry;
  final String shipPhone;
  final String description;
  final String location;
  final int userId;
  final String createdAt;
  final String updatedAt;

  BuyerInfo({
    required this.id,
    required this.gender,
    required this.age,
    required this.address,
    required this.state,
    required this.postcode,
    required this.country,
    required this.shipName,
    required this.shipEmail,
    required this.shipAddress,
    required this.shipCity,
    required this.shipState,
    required this.shipCountry,
    required this.shipPhone,
    required this.description,
    required this.location,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.shipLocation,
    required this.latitude,
    required this.longitude,
  });

  factory BuyerInfo.fromJson(Map<String, dynamic> json) => BuyerInfo(
    id: json['id'] ?? 0,
    gender: json['gender'] ?? '',
    age: json['age']?.toString() ?? '',
    address: json['address'] ?? '',
    state: json['state'] ?? '',
    postcode: json['postcode'] ?? '',
    country: json['country'] ?? '',
    shipName: json['ship_name'] ?? '',
    shipEmail: json['ship_email'] ?? '',
    shipAddress: json['ship_address'] ?? '',
    shipCity: json['ship_city'] ?? '',
    shipState: json['ship_state'] ?? '',
    shipCountry: json['ship_country'] ?? '',
    shipPhone: json['ship_phone'] ?? '',
    description: json['description'] ?? '',
    location: json['location'] ?? '',
    userId: json['user_id'] ?? 0,
    createdAt: json['created_at']?.toString() ?? '',
    updatedAt: json['updated_at']?.toString() ?? '',
    shipLocation: json['ship_location'] ?? '',
    latitude: json['ship_latitude'] ?? "",
    longitude: json['ship_longitude'] ?? "",
  );
}

// ---------------- Driver ----------------
class DriverInfo {
  final int id;
  final String carName;
  final String carModel;
  final String location;
  final String price;
  final num rating;
  final String description;
  final int userId;
  final int routeId;
  final String createdAt;
  final String updatedAt;

  DriverInfo({
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
    required this.description,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) => DriverInfo(
    id: json['id'] ?? 0,
    carName: json['car_name'] ?? '',
    carModel: json['car_model'] ?? '',
    location: json['location'] ?? '',
    price: '${json['price'] ?? ''}',
    rating: json['rating'] ?? 0,
    userId: json['user_id'] ?? 0,
    routeId: json['route_id'] ?? 0,
    createdAt: json['created_at']?.toString() ?? '',
    updatedAt: json['updated_at']?.toString() ?? '',
    description: json['description'] ?? '',
  );
}

// ---------------- Transport ----------------
class TransportInfo {
  final int id;
  final int userId;
  final String createdAt;
  final String updatedAt;

  TransportInfo({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransportInfo.fromJson(Map<String, dynamic> json) => TransportInfo(
    id: json['id'] ?? 0,
    userId: json['user_id'] ?? 0,
    createdAt: json['created_at']?.toString() ?? '',
    updatedAt: json['updated_at']?.toString() ?? '',
  );
}

// ---------------- User Image ----------------
class UserImage {
  final int id;
  final String imagePath;
  final int userId;
  final String publicId;
  final String userType;
  final String fileType;
  final String createdAt;
  final String updatedAt;

  UserImage({
    required this.id,
    required this.imagePath,
    required this.userId,
    required this.publicId,
    required this.userType,
    required this.fileType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserImage.fromJson(Map<String, dynamic> json) => UserImage(
    id: json['id'] ?? 0,
    imagePath: json['image_path'] ?? '',
    userId: json['user_id'] ?? 0,
    publicId: json['public_id'] ?? '',
    userType: json['user_type'] ?? '',
    fileType: json['file_type'] ?? '',
    createdAt: json['created_at']?.toString() ?? '',
    updatedAt: json['updated_at']?.toString() ?? '',
  );
}

class VendorReviewProfile {
  final int id;
  final String review;
  final double rating;
  final int userId;
  final int vendorId;
  final int productId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VendorReviewProfile({
    required this.id,
    required this.review,
    required this.rating,
    required this.userId,
    required this.vendorId,
    required this.productId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorReviewProfile.fromJson(Map<String, dynamic> json) {
    double _parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    DateTime? _parseDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());

    int _parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return VendorReviewProfile(
      id: _parseInt(json['id']),
      review: json['review']?.toString() ?? '',
      rating: _parseDouble(json['rating']),
      userId: _parseInt(json['user_id']),
      vendorId: _parseInt(json['vendor_id']),
      productId: _parseInt(json['product_id']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }
}
