// profile_model.dart

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
class VendorInfo {
  final int id;
  final String country;
  final String address;
  final String businessName;
  final String businessType;
  final int userId;
  final String createdAt;
  final String updatedAt;

  VendorInfo({
    required this.id,
    required this.country,
    required this.address,
    required this.businessName,
    required this.businessType,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
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