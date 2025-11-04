class CartResponse {
  final String status;
  final String message;
  final List<CartItem> data;

  CartResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CartItem.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class CartItem {
  final int quantity;
  final String deliveryCharge;
  final String color;
  final String size;
  final String price;
  final int productId;
  final int buyerId;
  final int vendorId;
  final String status;
  final Product product;
  final Vendor vendor;
  final Buyer buyer;

  CartItem({
    required this.quantity,
    required this.deliveryCharge,
    required this.color,
    required this.size,
    required this.price,
    required this.productId,
    required this.buyerId,
    required this.vendorId,
    required this.status,
    required this.product,
    required this.vendor,
    required this.buyer,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      quantity: json['quantity'] ?? 0,
      deliveryCharge: json['delivery_charge'] ?? '',
      color: json['color'] ?? '',
      size: json['size'] ?? '',
      price: json['price'] ?? '',
      productId: json['product_id'] ?? 0,
      buyerId: json['buyer_id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      status: json['status'] ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      vendor: Vendor.fromJson(json['vendor'] ?? {}),
      buyer: Buyer.fromJson(json['buyer'] ?? {}),
    );
  }
}

class Product {
  final int id;
  final String name;
  final String description;
  final String regularPrice;
  final String sellPrice;
  final int discount;
  final String? publicId;
  final int star;
  final String image;
  final List<String> color;
  final List<String> size;
  final String remark;
  final int isActive;
  final int vendorId;
  final int categoryId;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.regularPrice,
    required this.sellPrice,
    required this.discount,
    required this.publicId,
    required this.star,
    required this.image,
    required this.color,
    required this.size,
    required this.remark,
    required this.isActive,
    required this.vendorId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> parseDynamicList(dynamic data) {
      if (data == null) return [];
      if (data is List) {
        return data.expand((e) => e.toString().split(',')).map((e) => e.trim()).toList();
      }
      if (data is String) {
        return data.replaceAll('"', '').split(',').map((e) => e.trim()).toList();
      }
      return [];
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      regularPrice: json['regular_price'] ?? '',
      sellPrice: json['sell_price'] ?? '',
      discount: json['discount'] ?? 0,
      publicId: json['public_id'],
      star: json['star'] ?? 0,
      image: json['image'] ?? '',
      color: parseDynamicList(json['color']),
      size: parseDynamicList(json['size']),
      remark: json['remark'] ?? '',
      isActive: json['is_active'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class Vendor {
  final int id;
  final String country;
  final String address;
  final String businessName;
  final String businessType;
  final int userId;
  final String createdAt;
  final String updatedAt;

  Vendor({
    required this.id,
    required this.country,
    required this.address,
    required this.businessName,
    required this.businessType,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] ?? 0,
      country: json['country'] ?? '',
      address: json['address'] ?? '',
      businessName: json['business_name'] ?? '',
      businessType: json['business_type'] ?? '',
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class Buyer {
  final int id;
  final String gender;
  final String? age;
  final String address;
  final String? country;
  final String? shipCity;
  final String? description;
  final int userId;

  Buyer({
    required this.id,
    required this.gender,
    required this.age,
    required this.address,
    required this.country,
    required this.shipCity,
    required this.description,
    required this.userId,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      id: json['id'] ?? 0,
      gender: json['gender'] ?? '',
      age: json['age'],
      address: json['address'] ?? '',
      country: json['country'],
      shipCity: json['ship_city'],
      description: json['description'],
      userId: json['user_id'] ?? 0,
    );
  }
}