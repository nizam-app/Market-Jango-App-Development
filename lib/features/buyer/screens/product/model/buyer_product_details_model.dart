
import 'package:market_jango/core/models/global_search_model.dart';
import 'package:market_jango/features/buyer/model/new_items_model.dart';

import '../../../model/buyer_top_model.dart';

// lib/core/models/detail_item.dart
class DetailItem {
  final int id;
  final String title;
  final String? subtitle;
  final String imageUrl;          // প্রাইমারি ইমেজ
  final String? price;            // "233.00"
  final List<String> sizes;       // ["L","XL"]
  final List<String> colors;      // ["yellow","blue"]
  final String? vendorName;       // vendor.user?.name
  final String? categoryName;     // category?.name
  final List<String> gallery;     // images[].image_path
  final Object? raw;              // আসল অবজেক্ট, ডিবাগ/ইন্টারঅপের জন্য

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
  });

  String get displayPrice => price ?? '';
}




extension GlobalSearchProductToDetail on GlobalSearchProduct {
  DetailItem toDetail() {
    final primaryImage = (images.isNotEmpty ? images.first.imagePath : image) ?? '';
    final galleryPaths = images.map((e) => e.imagePath).where((e) => e.isNotEmpty).toList();

    return DetailItem(
      id: id,
      title: name,
      subtitle: (description.isNotEmpty) ? description : null,
      imageUrl: primaryImage,
      price: (sellPrice.isNotEmpty ? sellPrice : regularPrice),
      sizes: size,                          // ইতিমধ্যে ["L","XL"] নরমালাইজড
      colors: color,                        // ইতিমধ্যে ["yellow","blue"] নরমালাইজড
      vendorName: vendor?.user?.name,
      categoryName: category?.name,
      gallery: galleryPaths,
      raw: this,
    );
  }
}

extension BuyerNewProductToDetail on NewItemsProduct {
  DetailItem toDetail() {
    // প্রাইমারি ইমেজ: গ্যালারিতে প্রথমটি থাকলে সেটি; নাহলে main image
    final String primaryImage =
    (images.isNotEmpty && images.first.imagePath.isNotEmpty)
        ? images.first.imagePath
        : (image.isNotEmpty ? image : '');

    // গ্যালারি: খালি/ভুল স্ট্রিং বাদ দিন
    final List<String> galleryPaths = images
        .map((e) => e.imagePath)
        .where((p) => p.isNotEmpty)
        .toList();

    return DetailItem(
      id: id,
      title: name,
      subtitle: description.isNotEmpty ? description : null,
      imageUrl: primaryImage,
      price: (sellPrice.isNotEmpty ? sellPrice : regularPrice),
      sizes: size,                 // ইতিমধ্যে নরমালাইজড ["L","XL"]
      colors: color,               // ইতিমধ্যে নরমালাইজড ["yellow","blue"]
      vendorName: vendor.user.name,            
      categoryName: category.name, // category সবসময় থাকে আপনার বেসে
      gallery: galleryPaths,
      raw: this,
    );
  }
}
extension BuyerTopProductToDetail on Product {
  DetailItem toDetail() {
    // প্রাইমারি ইমেজ: গ্যালারির প্রথমটা থাকলে সেটি, না থাকলে main image
    final String primaryImage =
    (image.isNotEmpty && images.first.imagePath.isNotEmpty)
        ? images.first.imagePath
        : (image.isNotEmpty ? image : '');

    // গ্যালারি: খালি বা null বাদ দিয়ে পরিষ্কার লিস্ট বানাও
    final List<String> galleryPaths = images
        .map((e) => e.imagePath)
        .where((p) => p.isNotEmpty)
        .toList();

    return DetailItem(
      id: id,
      title: name,
      subtitle: null, // তোমার JSON এ description নাই, future এ যোগ করলে এখানে বসাও
      imageUrl: primaryImage,
      price: (sellPrice.isNotEmpty ? sellPrice : regularPrice),
      sizes: const [], // তোমার product model এ size ফিল্ড নাই — future এ থাকলে map করে দিও
      colors: const [], // color ফিল্ড নাই — future use এর জন্য placeholder
      vendorName: vendor.user.name,
      categoryName: category.name,
      gallery: galleryPaths,
      raw: this,
    );
  }
}