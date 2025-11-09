//
// import 'package:intl/intl.dart';
// import 'package:market_jango/core/models/global_search_model.dart' as gs;
// import 'package:market_jango/features/buyer/model/new_items_model.dart' as ni;
// import '../../../model/buyer_top_model.dart' as tp;
// class DetailItem {
//   final int id;
//   final String title;
//   final String? subtitle;
//   final String imageUrl;
//   final String? price;
//   final List<String> sizes;
//   final List<String> colors;
//   final String? vendorName;
//   final String? categoryName;
//   final List<String> gallery;
//   final Object? raw;
//   final DetailVendor? vendor;
//
//   // extra product meta (optional)
//   final int? discount;
//   final int? star;
//   final String? remark;
//   final int? isActive;
//   final String? publicId;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//
//   const DetailItem({
//     required this.id,
//     required this.title,
//     required this.imageUrl,
//     this.subtitle,
//     this.price,
//     this.sizes = const [],
//     this.colors = const [],
//     this.vendorName,
//     this.categoryName,
//     this.gallery = const [],
//     this.raw,
//     this.vendor,
//     this.discount,
//     this.star,
//     this.remark,
//     this.isActive,
//     this.publicId,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   String get displayPrice => price ?? '';
//
//   String formatDate(DateTime? dt, {String pattern = 'dd MMM yyyy'}) {
//     if (dt == null) return '__';
//     return DateFormat(pattern).format(dt.toLocal());
//   }
//
//   String get createdAtText => formatDate(createdAt);
//   String get updatedAtText => formatDate(updatedAt);
// }
//
// /// ----------------------
// /// Vendor (flattened for UI)
// /// ----------------------
// class DetailVendor {
//   final int id;
//   final String? businessName;
//   final String? businessType;
//   final String? country;
//   final String? address;
//   final int? userId;
//
//   // nested user
//   final String? userName;
//   final String? userEmail;
//   final String? userPhone;
//   final String? userImage;
//
//   const DetailVendor({
//     required this.id,
//     this.businessName,
//     this.businessType,
//     this.country,
//     this.address,
//     this.userId,
//     this.userName,
//     this.userEmail,
//     this.userPhone,
//     this.userImage,
//   });
//
//   /// universal: accepts a typed model OR a Map
//   factory DetailVendor.fromAny(dynamic vendor) {
//     final v = _asMap(vendor);
//     final u = _asMap(v['user']);
//
//     int? _i(dynamic x) => (x is int) ? x : (x is String ? int.tryParse(x) : null);
//     String? _s(dynamic x) => (x == null) ? null : (x.toString().trim().isEmpty ? null : x.toString());
//
//     return DetailVendor(
//       id: _i(v['id']) ?? 0,
//       businessName: _s(v['business_name']),
//       businessType: _s(v['business_type']),
//       country: _s(v['country']),
//       address: _s(v['address']),
//       // 🔧 আগে ছিল: userId: _i(v['user_id']),
//       userId: _i(v['user_id']) ?? _i(u['id']), // <-- fallback to nested user.id
//       userName: _s(u['name']),
//       userEmail: _s(u['email']),
//       userPhone: _s(u['phone']),
//       userImage: _s(u['image']),
//     );
//   }
//
// }
//
// /// ----------------------
// /// Helpers
// /// ----------------------
// Map<String, dynamic> _asMap(dynamic src) {
//   if (src == null) return <String, dynamic>{};
//   if (src is Map) return Map<String, dynamic>.from(src as Map);
//   try {
//     final m = (src as dynamic).toJson();
//     if (m is Map) return Map<String, dynamic>.from(m as Map);
//   } catch (_) {}
//   return <String, dynamic>{};
// }
//
// int? _asInt(dynamic x) {
//   if (x == null) return null;
//   if (x is int) return x;
//   if (x is String) return int.tryParse(x);
//   return null;
// }
//
// String? _asStr(dynamic x) {
//   if (x == null) return null;
//   final s = x.toString();
//   return s.isEmpty ? null : s;
// }
//
// DateTime? _parseDate(String? s) {
//   if (s == null || s.isEmpty) return null;
//   return DateTime.tryParse(s);
// }
//
// /// ----------------------
// /// Mappers
// /// ----------------------
//
// /// Global search → DetailItem
// extension GlobalSearchProductToDetail on gs.GlobalSearchProduct {
//   DetailItem toDetail() {
//     final String primaryImage = (images.isNotEmpty ? images.first.imagePath : (image ?? ''));
//
//     final galleryPaths = images
//         .map((e) => e.imagePath)
//         .where((e) => e.isNotEmpty)
//         .toList();
//
//     final dv = vendor == null ? null : DetailVendor.fromAny(vendor);
//
//     return DetailItem(
//       id: id,
//       title: name,
//       subtitle: (description.isNotEmpty) ? description : null,
//       imageUrl: primaryImage,
//       price: (sellPrice.isNotEmpty ? sellPrice : regularPrice),
//       sizes: size,
//       colors: color,
//       vendorName: dv?.userName,
//       categoryName: category?.name,
//       gallery: galleryPaths,
//       raw: this,
//       vendor: dv,
//       // search payload সাধারণত created/updated দেয় না
//       createdAt: null,
//       updatedAt: null,
//     );
//   }
// }
//
// /// Top products → DetailItem
// extension BuyerTopProductToDetail on tp.TopProduct {
//   DetailItem toDetail() {
//     final String primaryImage = (images.isNotEmpty && images.first.imagePath.isNotEmpty)
//         ? images.first.imagePath
//         : (image.isNotEmpty ? image : '');
//
//     final galleryPaths = images
//         .map((e) => e.imagePath)
//         .where((p) => p.isNotEmpty)
//         .toList();
//
//     // safely read extra meta via toJson/map
//     final map = _asMap(this);
//     final dv = DetailVendor.fromAny(vendor);
//
//     return DetailItem(
//       id: id,
//       title: name,
//       subtitle: (description?.isNotEmpty ?? false) ? description : null,
//       imageUrl: primaryImage,
//       price: (sellPrice.isNotEmpty ? sellPrice : regularPrice),
//       sizes: (size ?? const []),
//       colors: (color ?? const []),
//       vendorName: dv.userName,
//       categoryName: category.name,
//       gallery: galleryPaths,
//       raw: this,
//       vendor: dv,
//       // meta
//       discount: _asInt(map['discount']),
//       star: _asInt(map['star']),
//       remark: _asStr(map['remark']),
//       isActive: _asInt(map['is_active']),
//       publicId: _asStr(map['public_id']),
//       createdAt: _parseDate(_asStr(map['created_at'])),
//       updatedAt: _parseDate(_asStr(map['updated_at'])),
//     );
//   }
// }
//
// /// New items → DetailItem
// extension NewItemsProductToDetail on ni.NewItemsProduct {
//   DetailItem toDetailItem() {
//     final effectivePrice = (sellPrice.isNotEmpty ? sellPrice : regularPrice);
//
//     final gallery = images
//         .map((e) => e.imagePath)
//         .where((p) => p.isNotEmpty)
//         .toList();
//
//     final map = _asMap(this);
//     final dv = DetailVendor.fromAny(vendor);
//
//     return DetailItem(
//       id: id,
//       title: name,
//       subtitle: (description.isNotEmpty) ? description : null,
//       imageUrl: image,
//       price: effectivePrice.isEmpty ? null : effectivePrice,
//       sizes: size,
//       colors: color,
//       vendorName: dv.userName,
//       categoryName: category.name,
//       gallery: gallery,
//       raw: this,
//       vendor: dv,
//       discount: _asInt(map['discount']),
//       star: _asInt(map['star']),
//       remark: _asStr(map['remark']),
//       isActive: _asInt(map['is_active']),
//       publicId: _asStr(map['public_id']),
//       createdAt: _parseDate(_asStr(map['created_at'])),
//       updatedAt: _parseDate(_asStr(map['updated_at'])),
//     );
//   }
// }