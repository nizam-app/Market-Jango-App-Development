class SearchResponse {
  final List<SearchProduct> products;

  SearchResponse({required this.products});

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data']?['data'] ?? [];
    return SearchResponse(
      products: List<SearchProduct>.from(
        data.map((x) => SearchProduct.fromJson(x)),
      ),
    );
  }
}

class SearchProduct {
  final int id;
  final String name;
  final String description;
  final String image;
  final String regularPrice;
  final String sellPrice;

  SearchProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.regularPrice,
    required this.sellPrice,
  });

  factory SearchProduct.fromJson(Map<String, dynamic> json) => SearchProduct(
    id: json['id'],
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    image: json['image'] ?? '',
    regularPrice: json['regular_price'] ?? '',
    sellPrice: json['sell_price'] ?? '',
  );
}