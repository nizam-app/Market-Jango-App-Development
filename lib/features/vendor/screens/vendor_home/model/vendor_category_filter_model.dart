class ProductResponse {
  final String status;
  final String message;
  final ProductData data;

  ProductResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      status: json['status'],
      message: json['message'],
      data: ProductData.fromJson(json['data']),
    );
  }
}

class ProductData {
  final int currentPage;
  final List<Product> data;
  final String? firstPageUrl;
  final int from;
  final int lastPage;
  final String? lastPageUrl;
  final List<PageLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  ProductData({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    required this.from,
    required this.lastPage,
    this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      currentPage: json['current_page'],
      data: List<Product>.from(json['data'].map((x) => Product.fromJson(x))),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      links: List<PageLink>.from(
        json['links'].map((x) => PageLink.fromJson(x)),
      ),
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class Product {
  final int id;
  final String name;
  final String description;
  final String regularPrice;
  final String sellPrice;
  final String image;
  final int vendorId;
  final int categoryId;
  final List<String> color;
  final List<String> size;
  final Category category;
  final List<dynamic> images;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.regularPrice,
    required this.sellPrice,
    required this.image,
    required this.vendorId,
    required this.categoryId,
    required this.color,
    required this.size,
    required this.category,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      regularPrice: json['regular_price'],
      sellPrice: json['sell_price'],
      image: json['image'],
      vendorId: json['vendor_id'],
      categoryId: json['category_id'],
      color: List<String>.from(json['color']),
      size: List<String>.from(json['size']),
      category: Category.fromJson(json['category']),
      images: List<dynamic>.from(json['images']),
    );
  }
}

class Category {
  final int id;
  final String name;
  final String description;

  Category({required this.id, required this.name, required this.description});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class PageLink {
  final String? url;
  final String label;
  final int? page;
  final bool active;

  PageLink({this.url, required this.label, this.page, required this.active});

  factory PageLink.fromJson(Map<String, dynamic> json) {
    return PageLink(
      url: json['url'],
      label: json['label'],
      page: json['page'],
      active: json['active'],
    );
  }
}
