// lib/features/buyer/screens/review/model/vendor_review_model.dart
import 'dart:convert';

class VendorReviewsResponse {
  final String? status;
  final String? message;
  final VendorReviewsPage? data;

  VendorReviewsResponse({this.status, this.message, this.data});

  factory VendorReviewsResponse.fromJson(Map<String, dynamic> json) {
    return VendorReviewsResponse(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? VendorReviewsPage.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  static VendorReviewsResponse fromJsonString(String body) =>
      VendorReviewsResponse.fromJson(jsonDecode(body) as Map<String, dynamic>);
}

class VendorReviewsPage {
  final int currentPage;
  final List<VendorReview> reviews;
  final int lastPage;
  final int perPage;
  final int total;

  VendorReviewsPage({
    required this.currentPage,
    required this.reviews,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory VendorReviewsPage.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?) ?? const [];

    return VendorReviewsPage(
      currentPage: _toInt(json['current_page']) ?? 1,
      lastPage: _toInt(json['last_page']) ?? 1,
      perPage: _toInt(json['per_page']) ?? 0,
      total: _toInt(json['total']) ?? 0,
      reviews: list
          .map((e) => VendorReview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class VendorReview {
  final int id;
  final String review;
  final double rating;
  final int userId;
  final int vendorId;
  final int productId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ReviewProduct? product;
  final ReviewUser? user;

  VendorReview({
    required this.id,
    required this.review,
    required this.rating,
    required this.userId,
    required this.vendorId,
    required this.productId,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
    required this.user,
  });

  factory VendorReview.fromJson(Map<String, dynamic> json) {
    return VendorReview(
      id: _toInt(json['id']) ?? 0,
      review: json['review']?.toString() ?? '',
      rating: (_toDouble(json['rating']) ?? 0),
      userId: _toInt(json['user_id']) ?? 0,
      vendorId: _toInt(json['vendor_id']) ?? 0,
      productId: _toInt(json['product_id']) ?? 0,
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
      product: json['product'] is Map<String, dynamic>
          ? ReviewProduct.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      user: json['user'] is Map<String, dynamic>
          ? ReviewUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  String get userName => user?.name ?? 'Unknown user';
  String? get userImage => user?.image;
  String get productName => product?.name ?? '';
  String? get productImage => product?.image;
}

class ReviewProduct {
  final int id;
  final String name;
  final String image;

  ReviewProduct({required this.id, required this.name, required this.image});

  factory ReviewProduct.fromJson(Map<String, dynamic> json) {
    return ReviewProduct(
      id: _toInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }
}

class ReviewUser {
  final int id;
  final String? userType;
  final String name;
  final String? email;
  final String? image;

  ReviewUser({
    required this.id,
    required this.userType,
    required this.name,
    required this.email,
    required this.image,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: _toInt(json['id']) ?? 0,
      userType: json['user_type']?.toString(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      image: json['image']?.toString(),
    );
  }
}

/* helpers */

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString());
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}
