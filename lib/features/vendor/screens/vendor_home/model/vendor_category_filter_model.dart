// import 'dart:convert';
//
// ProductResponse productResponseFromJson(String str) =>
//     ProductResponse.fromJson(json.decode(str));
//
// String productResponseToJson(ProductResponse data) =>
//     json.encode(data.toJson());
//
// class ProductResponse {
//   final String? status;
//   final String? message;
//   final ProductData? data;
//
//   ProductResponse({
//     this.status,
//     this.message,
//     this.data,
//   });
//
//   factory ProductResponse.fromJson(Map<String, dynamic> json) =>
//       ProductResponse(
//         status: json["status"],
//         message: json["message"],
//         data: json["data"] != null
//             ? ProductData.fromJson(json["data"])
//             : null,
//       );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "message": message,
//     "data": data?.toJson(),
//   };
// }
//
// class ProductData {
//   final int? currentPage;
//   final List<Product>? products;
//   final int? lastPage;
//   final int? total;
//   final String? nextPageUrl;
//   final String? prevPageUrl;
//
//   ProductData({
//     this.currentPage,
//     this.products,
//     this.lastPage,
//     this.total,
//     this.nextPageUrl,
//     this.prevPageUrl,
//   });
//
//   factory ProductData.fromJson(Map<String, dynamic> json) => ProductData(
//     currentPage: json["current_page"],
//     products: json["data"] == null
//         ? []
//         : List<Product>.from(
//         json["data"].map((x) => Product.fromJson(x))),
//     lastPage: json["last_page"],
//     total: json["total"],
//     nextPageUrl: json["next_page_url"],
//     prevPageUrl: json["prev_page_url"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "current_page": currentPage,
//     "data": products == null
//         ? []
//         : List<dynamic>.from(products!.map((x) => x.toJson())),
//     "last_page": lastPage,
//     "total": total,
//     "next_page_url": nextPageUrl,
//     "prev_page_url": prevPageUrl,
//   };
// }
//
// class Product {
//   final int? id;
//   final String? name;
//   final String? description;
//   final String? regularPrice;
//   final String? sellPrice;
//   final String? image;
//   final int? vendorId;
//   final int? categoryId;
//   final List<String>? color;
//   final List<String>? size;
//   final Category? category;
//   final List<String>? images;
//
//   Product({
//     this.id,
//     this.name,
//     this.description,
//     this.regularPrice,
//     this.sellPrice,
//     this.image,
//     this.vendorId,
//     this.categoryId,
//     this.color,
//     this.size,
//     this.category,
//     this.images,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) => Product(
//     id: json["id"],
//     name: json["name"],
//     description: json["description"],
//     regularPrice: json["regular_price"],
//     sellPrice: json["sell_price"],
//     image: json["image"],
//     vendorId: json["vendor_id"],
//     categoryId: json["category_id"],
//     color: json["color"] == null
//         ? []
//         : List<String>.from(json["color"].map((x) => x)),
//     size: json["size"] == null
//         ? []
//         : List<String>.from(json["size"].map((x) => x)),
//     category: json["category"] != null
//         ? Category.fromJson(json["category"])
//         : null,
//     images: json["images"] == null
//         ? []
//         : List<String>.from(json["images"].map((x) => x)),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "name": name,
//     "description": description,
//     "regular_price": regularPrice,
//     "sell_price": sellPrice,
//     "image": image,
//     "vendor_id": vendorId,
//     "category_id": categoryId,
//     "color": color == null
//         ? []
//         : List<dynamic>.from(color!.map((x) => x)),
//     "size": size == null
//         ? []
//         : List<dynamic>.from(size!.map((x) => x)),
//     "category": category?.toJson(),
//     "images": images == null
//         ? []
//         : List<dynamic>.from(images!.map((x) => x)),
//   };
// }
//
// class Category {
//   final int? id;
//   final String? name;
//   final String? description;
//
//   Category({
//     this.id,
//     this.name,
//     this.description,
//   });
//
//   factory Category.fromJson(Map<String, dynamic> json) => Category(
//     id: json["id"],
//     name: json["name"],
//     description: json["description"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "name": name,
//     "description": description,
//   };
// }