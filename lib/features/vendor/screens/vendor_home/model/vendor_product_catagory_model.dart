// category_model.dart
class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], name: json['name'] ?? '');
  }
}

class PaginatedCategories {
  final int currentPage;
  final int lastPage;
  final List<Category> categories;

  PaginatedCategories({
    required this.currentPage,
    required this.lastPage,
    required this.categories,
  });

  factory PaginatedCategories.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return PaginatedCategories(
      currentPage: data['current_page'],
      lastPage: data['last_page'],
      categories: (data['data'] as List)
          .map((e) => Category.fromJson(e))
          .toList(),
    );
  }
}
