class UserModel {
  final int id;
  final String name;
  final String image;
  final String email;
  final String phone;
  final String userType;
  final String language;
  final String status;
  final String phoneVerifiedAt;
  final VendorModel? vendor;
  final BuyerModel? buyer;
  final DriverModel? driver;
  final TransportModel? transport;

  UserModel({
    required this.id,
    required this.name,
    required this.image,
    required this.email,
    required this.phone,
    required this.userType,
    required this.language,
    required this.status,
    required this.phoneVerifiedAt,
    this.vendor,
    this.buyer,
    this.driver,
    this.transport,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['user_type'] ?? '',
      language: json['language'] ?? '',
      status: json['status'] ?? '',
      phoneVerifiedAt: json['phone_verified_at'] ?? '',
      vendor: json['vendor'] != null ? VendorModel.fromJson(json['vendor']) : null,
      buyer: json['buyer'] != null ? BuyerModel.fromJson(json['buyer']) : null,
      driver: json['driver'] != null ? DriverModel.fromJson(json['driver']) : null,
      transport: json['transport'] != null ? TransportModel.fromJson(json['transport']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'email': email,
      'phone': phone,
      'user_type': userType,
      'language': language,
      'status': status,
      'phone_verified_at': phoneVerifiedAt,
      'vendor': vendor?.toJson(),
      'buyer': buyer?.toJson(),
      'driver': driver?.toJson(),
      'transport': transport?.toJson(),
    };
  }
}

class VendorModel {
  final int id;
  final String? businessName;
  final String? businessType;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? phone;
  final String? email;
  final String? description;
  final String? location;
  final int userId;
  final String createdAt;
  final String updatedAt;

  VendorModel({
    required this.id,
    this.businessName,
    this.businessType,
    this.address,
    this.city,
    this.state,
    this.country,
    this.phone,
    this.email,
    this.description,
    this.location,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] ?? 0,
      businessName: json['business_name'],
      businessType: json['business_type'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      phone: json['phone'],
      email: json['email'],
      description: json['description'],
      location: json['location'],
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'business_type': businessType,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'phone': phone,
      'email': email,
      'description': description,
      'location': location,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class BuyerModel {
  final int id;
  final String? gender;
  final int? age;
  final String? address;
  final String? state;
  final String? postcode;
  final String? country;
  final String? fax;
  final String? shipName;
  final String? shipAddress;
  final String? shipCity;
  final String? shipState;
  final String? shipCountry;
  final String? shipPhone;
  final String? description;
  final String? location;
  final int userId;
  final String createdAt;
  final String updatedAt;

  BuyerModel({
    required this.id,
    this.gender,
    this.age,
    this.address,
    this.state,
    this.postcode,
    this.country,
    this.fax,
    this.shipName,
    this.shipAddress,
    this.shipCity,
    this.shipState,
    this.shipCountry,
    this.shipPhone,
    this.description,
    this.location,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BuyerModel.fromJson(Map<String, dynamic> json) {
    return BuyerModel(
      id: json['id'] ?? 0,
      gender: json['gender'],
      age: json['age'],
      address: json['address'],
      state: json['state'],
      postcode: json['postcode'],
      country: json['country'],
      fax: json['fax'],
      shipName: json['ship_name'],
      shipAddress: json['ship_address'],
      shipCity: json['ship_city'],
      shipState: json['ship_state'],
      shipCountry: json['ship_country'],
      shipPhone: json['ship_phone'],
      description: json['description'],
      location: json['location'],
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gender': gender,
      'age': age,
      'address': address,
      'state': state,
      'postcode': postcode,
      'country': country,
      'fax': fax,
      'ship_name': shipName,
      'ship_address': shipAddress,
      'ship_city': shipCity,
      'ship_state': shipState,
      'ship_country': shipCountry,
      'ship_phone': shipPhone,
      'description': description,
      'location': location,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class DriverModel {
  final int id;
  final String? licenseNumber;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? phone;
  final String? email;
  final String? description;
  final String? location;
  final int userId;
  final String createdAt;
  final String updatedAt;

  DriverModel({
    required this.id,
    this.licenseNumber,
    this.vehicleType,
    this.vehicleNumber,
    this.address,
    this.city,
    this.state,
    this.country,
    this.phone,
    this.email,
    this.description,
    this.location,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? 0,
      licenseNumber: json['license_number'],
      vehicleType: json['vehicle_type'],
      vehicleNumber: json['vehicle_number'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      phone: json['phone'],
      email: json['email'],
      description: json['description'],
      location: json['location'],
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'license_number': licenseNumber,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'phone': phone,
      'email': email,
      'description': description,
      'location': location,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class TransportModel {
  final int id;
  final String? companyName;
  final String? transportType;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? phone;
  final String? email;
  final String? description;
  final String? location;
  final int userId;
  final String createdAt;
  final String updatedAt;

  TransportModel({
    required this.id,
    this.companyName,
    this.transportType,
    this.address,
    this.city,
    this.state,
    this.country,
    this.phone,
    this.email,
    this.description,
    this.location,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransportModel.fromJson(Map<String, dynamic> json) {
    return TransportModel(
      id: json['id'] ?? 0,
      companyName: json['company_name'],
      transportType: json['transport_type'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      phone: json['phone'],
      email: json['email'],
      description: json['description'],
      location: json['location'],
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': companyName,
      'transport_type': transportType,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'phone': phone,
      'email': email,
      'description': description,
      'location': location,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class UserApiResponse {
  final String status;
  final String message;
  final UserModel data;

  UserApiResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserApiResponse.fromJson(Map<String, dynamic> json) {
    return UserApiResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: UserModel.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}
