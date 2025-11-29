// file: lib/features/buyer/model/location_category_model.dart

class LocationCategoryResponse {
  final String status;
  final String message;
  final LocationCategoryPage data;

  LocationCategoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LocationCategoryResponse.fromJson(Map<String, dynamic> json) {
    return LocationCategoryResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: LocationCategoryPage.fromJson(json['data'] ?? {}),
    );
  }
}

class LocationCategoryPage {
  final int currentPage;
  final List<LocationCategoryItem> data;

  LocationCategoryPage({
    required this.currentPage,
    required this.data,
  });

  factory LocationCategoryPage.fromJson(Map<String, dynamic> json) {
    return LocationCategoryPage(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => LocationCategoryItem.fromJson(e))
          .toList(),
    );
  }
}

class LocationCategoryItem {
  final int id;
  final String name;
  final String status;

  LocationCategoryItem({
    required this.id,
    required this.name,
    required this.status,
  });

  factory LocationCategoryItem.fromJson(Map<String, dynamic> json) {
    return LocationCategoryItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
    );
  }
}