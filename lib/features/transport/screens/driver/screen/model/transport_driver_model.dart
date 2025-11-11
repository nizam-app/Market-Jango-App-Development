// approved_driver_model.dart
class ApprovedDriverResponse {
  final String status;
  final String message;
  final DriverPage data;

  ApprovedDriverResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ApprovedDriverResponse.fromJson(Map<String, dynamic> json) {
    return ApprovedDriverResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: DriverPage.fromJson(json['data'] ?? <String, dynamic>{}),
    );
  }
}

class DriverPage {
  final int currentPage;
  final List<Driver> data;
  final String? firstPageUrl;
  final int? from;
  final int lastPage;
  final String? lastPageUrl;
  final List<PageLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  DriverPage({
    required this.currentPage,
    required this.data,
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

  factory DriverPage.fromJson(Map<String, dynamic> json) {
    return DriverPage(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List? ?? [])
          .map((e) => Driver.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'],
      links: (json['links'] as List? ?? [])
          .map((e) => PageLink.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: (json['per_page'] is int)
          ? json['per_page']
          : int.tryParse('${json['per_page']}') ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }
}

class PageLink {
  final String? url;
  final String label;
  final int? page;
  final bool active;

  PageLink({
    required this.url,
    required this.label,
    required this.page,
    required this.active,
  });

  factory PageLink.fromJson(Map<String, dynamic> json) {
    // Some backends include "page" separately; if missing, try to parse from url.
    final pageVal = json['page'] is int ? json['page'] as int? : null;
    return PageLink(
      url: json['url'],
      label: json['label'] ?? '',
      page: pageVal,
      active: json['active'] ?? false,
    );
  }
}

class Driver {
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
  final DriverUser user;
  final List<dynamic> images; // structure not defined => keep dynamic

  Driver({
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
    required this.user,
    required this.images,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
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
      user: DriverUser.fromJson(json['user'] ?? <String, dynamic>{}),
      images: (json['images'] as List? ?? []),
    );
  }
}

class DriverUser {
  final int id;
  final String userType;
  final String name;
  final String email;
  final String phone;
  final String? image;
  final String? status;
  final int? isActive;
  final String? language;
  final String? phoneVerifiedAt;
  final String? publicId;
  final String createdAt;
  final String updatedAt;

  DriverUser({
    required this.id,
    required this.userType,
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
    required this.status,
    required this.isActive,
    required this.language,
    required this.phoneVerifiedAt,
    required this.publicId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverUser.fromJson(Map<String, dynamic> json) {
    return DriverUser(
      id: json['id'] ?? 0,
      userType: json['user_type'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'],
      status: json['status'],
      isActive: json['is_active'],
      language: json['language'],
      phoneVerifiedAt: json['phone_verified_at'],
      publicId: json['public_id'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
