import 'package:market_jango/core/models/global_search_model.dart';
import 'package:market_jango/features/buyer/model/new_items_model.dart';

import '../../../model/buyer_top_model.dart';

class DetailItem {
  final int id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? price; // "233.00"
  final List<String> sizes; // ["L","XL"]
  final List<String> colors; // ["yellow","blue"]
  final String? vendorName; // convenience
  final String? categoryName;
  final List<String> gallery;
  final Object? raw;
  final DetailVendor? vendor; // full vendor block

  const DetailItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.subtitle,
    this.price,
    this.sizes = const [],
    this.colors = const [],
    this.vendorName,
    this.categoryName,
    this.gallery = const [],
    this.raw,
    this.vendor,
  });

  String get displayPrice => price ?? '';
}

class DetailVendor {
  final int id;
  final String? businessName;
  final String? businessType;
  final String? country;
  final String? address;
  final int? userId;

  // nested user
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? userImage;

  const DetailVendor({
    required this.id,
    this.businessName,
    this.businessType,
    this.country,
    this.address,
    this.userId,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.userImage,
  });

  /// product['vendor'] (Map) থেকে
  factory DetailVendor.fromMap(Map<String, dynamic> v) {
    final Map<String, dynamic> u = (v['user'] is Map)
        ? Map<String, dynamic>.from(v['user'])
        : const {};
    int _toInt(dynamic x) => int.tryParse('${x ?? 0}') ?? 0;

    return DetailVendor(
      id: _toInt(v['id']),
      businessName: v['business_name']?.toString(),
      businessType: v['business_type']?.toString(),
      country: v['country']?.toString(),
      address: v['address']?.toString(),
      userId: _toInt(v['user_id']),
      userName: u['name']?.toString(),
      userEmail: u['email']?.toString(),
      userPhone: u['phone']?.toString(),
      userImage: u['image']?.toString(),
    );
  }

  /// টাইপড মডেল (e.g. TopProduct.vendor) থাকলে
  factory DetailVendor.fromTyped(dynamic v) {
    try {
      final user = v?.user;
      return DetailVendor(
        id: v?.id ?? 0,
        businessName: v?.businessName,
        businessType: v?.businessType,
        country: v?.country,
        address: v?.address,
        userId: v?.userId,
        userName: user?.name,
        userEmail: user?.email,
        userPhone: user?.phone,
        userImage: user?.image,
      );
    } catch (_) {
      return const DetailVendor(id: 0);
    }
  }
}

extension GlobalSearchProductToDetail on GlobalSearchProduct {
  DetailItem toDetail() {
    final String primaryImage =
        (images.isNotEmpty ? images.first.imagePath : (image ?? '')) ?? '';
    final galleryPaths = images
        .map((e) => e.imagePath)
        .where((e) => e.isNotEmpty)
        .toList();

    final dv = (vendor == null) ? null : DetailVendor.fromTyped(vendor);

    return DetailItem(
      id: id,
      title: name,
      subtitle: (description.isNotEmpty) ? description : null,
      imageUrl: primaryImage,
      price: (sellPrice.isNotEmpty ? sellPrice : regularPrice),
      sizes: size, // already normalized ["L","XL"]
      colors: color, // already normalized ["yellow","blue"]
      vendorName: dv?.userName, // <- safe
      categoryName: category?.name,
      gallery: galleryPaths,
      raw: this,
      vendor: dv,
    );
  }
}

extension BuyerNewProductToDetail on TopProduct {
  DetailItem toDetail() {
    final String primaryImage =
        (images.isNotEmpty && images.first.imagePath.isNotEmpty)
        ? images.first.imagePath
        : (image.isNotEmpty ? image : '');

    final List<String> galleryPaths = images
        .map((e) => e.imagePath)
        .where((p) => p.isNotEmpty)
        .toList();

    final dv = (vendor == null) ? null : DetailVendor.fromTyped(vendor);

    return DetailItem(
      id: id,
      title: name,
      subtitle: (description?.isNotEmpty ?? false)
          ? description
          : null, // <- safe
      imageUrl: primaryImage,
      price: (sellPrice.isNotEmpty ? sellPrice : regularPrice),
      sizes: size ?? const [],
      colors: color ?? const [],
      vendorName: dv?.userName, // <- safe
      categoryName: category.name,
      gallery: galleryPaths,
      raw: this,
      vendor: dv,
    );
  }
}

extension ProductToDetailItem on NewItemsProduct {
  DetailItem toDetailItem() {
    final effectivePrice = (sellPrice.isNotEmpty ? sellPrice : regularPrice);
    final dv = DetailVendor.fromTyped(vendor);

    return DetailItem(
      id: id,
      title: name,
      subtitle: null,
      imageUrl: image,
      price: effectivePrice.isEmpty ? null : effectivePrice,
      sizes: const [],
      colors: const [],
      vendorName: dv.userName, // <- safe
      categoryName: category.name,
      gallery: images
          .map((e) => e.imagePath)
          .where((p) => p.isNotEmpty)
          .toList(),
      raw: this,
      vendor: dv,
    );
  }
}
