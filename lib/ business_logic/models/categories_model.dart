class CategoryModel {
  final String title;
  final List<String> images;

  CategoryModel({
    required this.title,
    required this.images,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      title: json['title'],
      images: List<String>.from(json['images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'images': images,
    };
  }
}
