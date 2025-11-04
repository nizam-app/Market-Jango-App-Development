// driver_pagination_model.dart

class PaginatedDrivers {
  final int currentPage;
  final int lastPage;
  final int total;
  final List<Driver> drivers;

  PaginatedDrivers({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.drivers,
  });

  factory PaginatedDrivers.fromJson(Map<String, dynamic> json) {
    return PaginatedDrivers(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
      drivers: (json['data'] as List<dynamic>?)
          ?.map((e) => Driver.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class Driver {
  final int id;
  final int userId;
  final String createdAt;
  final String location;
  final String carName;
  final String carModel;
  final DriverUser user;

  Driver({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.location,
    required this.carName,
    required this.carModel,
    required this.user,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      location: json['location'] ?? '',
      carName: json['car_name'] ?? '',
      carModel: json['car_model'] ?? '',
      user: DriverUser.fromJson(json['user'] ?? {}),
    );
  }
}

class DriverUser {
  final int id;
  final String name;

  DriverUser({
    required this.id,
    required this.name,
  });

  factory DriverUser.fromJson(Map<String, dynamic> json) {
    return DriverUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}