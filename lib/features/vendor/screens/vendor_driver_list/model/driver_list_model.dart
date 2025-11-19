// driver_pagination_model.dart

/// Root response: status + message + paginated drivers data
class ApprovedDriversResponse {
  final String status;
  final String message;
  final PaginatedDrivers data;

  ApprovedDriversResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ApprovedDriversResponse.fromJson(Map<String, dynamic> json) {
    return ApprovedDriversResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: PaginatedDrivers.fromJson(
        (json['data'] as Map<String, dynamic>? ?? {}),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.toJson(),
  };
}

/// Inner pagination object: current_page, links, path, etc.
class PaginatedDrivers {
  final int currentPage;
  final List<Driver> drivers;

  final String? firstPageUrl;
  final int? from;
  final int lastPage;
  final String? lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String? path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  PaginatedDrivers({
    required this.currentPage,
    required this.drivers,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory PaginatedDrivers.fromJson(Map<String, dynamic> json) {
    return PaginatedDrivers(
      currentPage: json['current_page'] as int? ?? 1,
      drivers: (json['data'] as List<dynamic>?)
          ?.map((e) => Driver.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      firstPageUrl: json['first_page_url']?.toString(),
      from: (json['from'] as num?)?.toInt(),
      lastPage: json['last_page'] as int? ?? 1,
      lastPageUrl: json['last_page_url']?.toString(),
      links: (json['links'] as List<dynamic>?)
          ?.map((e) => PaginationLink.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      nextPageUrl: json['next_page_url']?.toString(),
      path: json['path']?.toString(),
      perPage: json['per_page'] is String
          ? int.tryParse(json['per_page']) ?? 10
          : (json['per_page'] as num?)?.toInt() ??
          10, // safety for string/int mix
      prevPageUrl: json['prev_page_url']?.toString(),
      to: (json['to'] as num?)?.toInt(),
      total: json['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'data': drivers.map((e) => e.toJson()).toList(),
    'first_page_url': firstPageUrl,
    'from': from,
    'last_page': lastPage,
    'last_page_url': lastPageUrl,
    'links': links.map((e) => e.toJson()).toList(),
    'next_page_url': nextPageUrl,
    'path': path,
    'per_page': perPage,
    'prev_page_url': prevPageUrl,
    'to': to,
    'total': total,
  };
}

/// Each link object under "links"
class PaginationLink {
  final String? url;
  final String label;
  final int? page;
  final bool active;

  PaginationLink({
    required this.url,
    required this.label,
    required this.page,
    required this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url']?.toString(),
      label: json['label']?.toString() ?? '',
      // "page" can be null or int
      page: json['page'] == null ? null : (json['page'] as num).toInt(),
      active: json['active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'label': label,
    'page': page,
    'active': active,
  };
}

/// Driver item: full info + user + images
class Driver {
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

  final DriverUser user;
  final List<DriverImage> images;

  Driver({
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
    required this.images,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as int? ?? 0,
      carName: json['car_name']?.toString() ?? '',
      carModel: json['car_model']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      rating: json['rating'] as int? ?? 0,
      description: json['description']?.toString() ?? '',
      userId: json['user_id'] as int? ?? 0,
      routeId: json['route_id'] as int? ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      user: DriverUser.fromJson(
        (json['user'] as Map<String, dynamic>? ?? {}),
      ),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => DriverImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'car_name': carName,
    'car_model': carModel,
    'location': location,
    'price': price,
    'rating': rating,
    'description': description,
    'user_id': userId,
    'route_id': routeId,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'user': user.toJson(),
    'images': images.map((e) => e.toJson()).toList(),
  };
}

/// Driver user details: sob field nia
class DriverUser {
  final int id;
  final String userType;
  final String name;
  final String email;
  final String phone;

  final String? otp;
  final String? phoneVerifiedAt;
  final String language;
  final String image;
  final String? publicId;
  final String status;
  final int? isActive;
  final String? expiresAt;
  final String createdAt;
  final String updatedAt;

  DriverUser({
    required this.id,
    required this.userType,
    required this.name,
    required this.email,
    required this.phone,
    required this.otp,
    required this.phoneVerifiedAt,
    required this.language,
    required this.image,
    required this.publicId,
    required this.status,
    required this.isActive,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverUser.fromJson(Map<String, dynamic> json) {
    return DriverUser(
      id: json['id'] as int? ?? 0,
      userType: json['user_type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      otp: json['otp']?.toString(),
      phoneVerifiedAt: json['phone_verified_at']?.toString(),
      language: json['language']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      publicId: json['public_id']?.toString(),
      status: json['status']?.toString() ?? '',
      isActive: json['is_active'] == null
          ? null
          : (json['is_active'] as num).toInt(),
      expiresAt: json['expires_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_type': userType,
    'name': name,
    'email': email,
    'phone': phone,
    'otp': otp,
    'phone_verified_at': phoneVerifiedAt,
    'language': language,
    'image': image,
    'public_id': publicId,
    'status': status,
    'is_active': isActive,
    'expires_at': expiresAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

/// Image list (currently [] in JSON, but future-proof)
class DriverImage {
  final int? id;
  final int? driverId;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  DriverImage({
    required this.id,
    required this.driverId,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverImage.fromJson(Map<String, dynamic> json) {
    return DriverImage(
      id: json['id'] as int?,
      driverId: json['driver_id'] as int?,
      image: json['image']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'driver_id': driverId,
    'image': image,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}