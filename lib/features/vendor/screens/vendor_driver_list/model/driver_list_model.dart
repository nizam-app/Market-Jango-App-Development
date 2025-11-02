// models/approved_driver.dart
class DriverUser {
  final int id;
  final String name;
  DriverUser({required this.id, required this.name});

  factory DriverUser.fromJson(Map<String, dynamic> j) =>
      DriverUser(id: j['id'] ?? 0, name: j['name']?.toString() ?? '');
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

  factory Driver.fromJson(Map<String, dynamic> j) => Driver(
    id: j['id'] ?? 0,
    userId: j['user_id'] ?? 0,
    createdAt: j['created_at']?.toString() ?? '',
    location: j['location']?.toString() ?? '',
    carName: j['car_name']?.toString() ?? '',
    carModel: j['car_model']?.toString() ?? '',
    user: DriverUser.fromJson(j['user'] ?? const {}),
  );
}

class DriverPage {
  final int currentPage;
  final List<Driver> data;

  DriverPage({required this.currentPage, required this.data});

  factory DriverPage.fromJson(Map<String, dynamic> j) => DriverPage(
    currentPage: j['current_page'] ?? 1,
    data: (j['data'] as List? ?? [])
        .map((e) => Driver.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}