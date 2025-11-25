// cart_models.dart
import 'dart:convert';

class CartResponse {
  final String status;
  final String message;
  final Map<String, List<CartItem>> groups; // e.g. {"0":[...]}
  final double total;

  CartResponse({
    required this.status,
    required this.message,
    required this.groups,
    required this.total,
  });

  List<CartItem> get items => groups.values.expand((e) => e).toList();

  factory CartResponse.fromRaw(String str) =>
      CartResponse.fromJson(json.decode(str));

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final Map<String, List<CartItem>> parsed = {};
    int total = 0;

    if (data is Map<String, dynamic>) {
      total = int.tryParse('${data['total'] ?? 0}') ?? 0;
      data.forEach((k, v) {
        if (k == 'total') return;
        if (v is List) {
          parsed[k] = v
              .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      });
    } else if (data is List) {
      parsed['0'] = data
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return CartResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      groups: parsed,
      total: total.toDouble(),
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

  final int? id;
  final String createdAt;
  final String updatedAt;

  final CardProduct product;
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
    this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    int _i(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    String _s(dynamic v) => v?.toString() ?? '';

    return CartItem(
      id: json['id'] == null ? null : _i(json['id']),
      quantity: _i(json['quantity']),
      deliveryCharge: _s(json['delivery_charge']),
      color: _s(json['color']),
      size: _s(json['size']),
      price: _s(json['price']),
      productId: _i(json['product_id']),
      buyerId: _i(json['buyer_id']),
      vendorId: _i(json['vendor_id']),
      status: _s(json['status']),
      product: CardProduct.fromJson(json['product'] ?? {}),
      vendor: Vendor.fromJson(json['vendor'] ?? {}),
      buyer: Buyer.fromJson(json['buyer'] ?? {}),
      createdAt: _s(json['created_at']),
      updatedAt: _s(json['updated_at']),
    );
  }
}

class CardProduct {
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

  CardProduct({
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

  factory CardProduct.fromJson(Map<String, dynamic> json) {
    List<String> _list(dynamic data) {
      if (data == null) return [];
      if (data is List) {
        return data
            .expand((e) => e.toString().split(','))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      if (data is String) {
        return data
            .replaceAll('"', '')
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [];
    }

    int _i(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    String _s(dynamic v) => v?.toString() ?? '';

    return CardProduct(
      id: _i(json['id']),
      name: _s(json['name']),
      description: _s(json['description']),
      regularPrice: _s(json['regular_price']),
      sellPrice: _s(json['sell_price']),
      discount: _i(json['discount']),
      publicId: json['public_id']?.toString(),
      star: _i(json['star']),
      image: _s(json['image']),
      color: _list(json['color']),
      size: _list(json['size']),
      remark: _s(json['remark']),
      isActive: _i(json['is_active']),
      vendorId: _i(json['vendor_id']),
      categoryId: _i(json['category_id']),
      createdAt: _s(json['created_at']),
      updatedAt: _s(json['updated_at']),
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
    String _s(dynamic v) => v?.toString() ?? '';
    int _i(dynamic v) => v is int ? v : (int.tryParse('$v') ?? 0);

    return Vendor(
      id: _i(json['id']),
      country: _s(json['country']),
      address: _s(json['address']),
      businessName: _s(json['business_name']),
      businessType: _s(json['business_type']),
      userId: _i(json['user_id']),
      createdAt: _s(json['created_at']),
      updatedAt: _s(json['updated_at']),
    );
  }
}

class Buyer {
  final int id;
  final String gender;
  final String? age;

  // billing/basic
  final String address;
  final String? state;
  final String? postcode;
  final String? country;

  // shipping
  final String? shipName;
  final String? shipEmail;
  final String? shipAddress;
  final String? shipCity;
  final String? shipState;
  final String? shipCountry;
  final String? shipPhone;

  // misc
  final String? description;
  final String? location;
  final int userId;
  final String createdAt;
  final String updatedAt;

  Buyer({
    required this.id,
    required this.gender,
    required this.age,
    required this.address,
    required this.state,
    required this.postcode,
    required this.country,
    required this.shipName,
    required this.shipEmail,
    required this.shipAddress,
    required this.shipCity,
    required this.shipState,
    required this.shipCountry,
    required this.shipPhone,
    required this.description,
    required this.location,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) {
    String _s(dynamic v) => v?.toString() ?? '';
    int _i(dynamic v) => v is int ? v : (int.tryParse('$v') ?? 0);

    return Buyer(
      id: _i(json['id']),
      gender: _s(json['gender']) ?? '',
      age: _s(json['age']),
      address: _s(json['address']) ?? '',
      state: _s(json['state']),
      postcode: _s(json['postcode']),
      country: _s(json['country']),

      shipName: _s(json['ship_name']),
      shipEmail: _s(json['ship_email']),
      shipAddress: _s(json['ship_address']),
      shipCity: _s(json['ship_city']),
      shipState: _s(json['ship_state']),
      shipCountry: _s(json['ship_country']),
      shipPhone: _s(json['ship_phone']),

      description: _s(json['description']),
      location: _s(json['location']),
      userId: _i(json['user_id']),
      createdAt: _s(json['created_at']) ?? '',
      updatedAt: _s(json['updated_at']) ?? '',
    );
  }
}