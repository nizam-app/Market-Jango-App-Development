import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';

class VisibilityVendorsParams {
  final String zone;
  final String? state;
  final String? town;
  final int perPage;

  const VisibilityVendorsParams({
    required this.zone,
    this.state,
    this.town,
    this.perPage = 20,
  });

  bool get isValid => zone.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisibilityVendorsParams &&
          zone == other.zone &&
          state == other.state &&
          town == other.town &&
          perPage == other.perPage;

  @override
  int get hashCode => Object.hash(zone, state, town, perPage);
}

class VisibilityVendorItem {
  final int vendorId;
  final int userId;
  final String name;
  final String? image;
  final String? country;

  const VisibilityVendorItem({
    required this.vendorId,
    required this.userId,
    required this.name,
    this.image,
    this.country,
  });

  factory VisibilityVendorItem.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;
    String asString(dynamic v) => v?.toString() ?? '';

    final vendorId = asInt(json['vendor_id'] ?? json['vendorId'] ?? json['id']);
    final userId = asInt(json['user_id'] ?? json['userId'] ?? json['user']?['id']);

    final name = asString(json['business_name'] ?? json['name'] ?? json['title']);
    final image = json['image']?.toString();
    final country = json['country']?.toString();

    return VisibilityVendorItem(
      vendorId: vendorId,
      userId: userId,
      name: name.isNotEmpty ? name : 'Vendor',
      image: image,
      country: country,
    );
  }
}

final visibilityVendorsProvider = FutureProvider.autoDispose
    .family<List<VisibilityVendorItem>, VisibilityVendorsParams>((ref, params) async {
  if (!params.isValid) return [];

  final authStorage = AuthLocalStorage();
  final t = await authStorage.getToken();

  final url = BuyerAPIController.visibilityVendors(
    zone: params.zone,
    state: params.state,
    town: params.town,
    perPage: params.perPage,
  );

  final res = await http.get(
    Uri.parse(url),
    headers: {
      'Accept': 'application/json',
      if (t != null && t.isNotEmpty) 'token': t,
    },
  );

  final map = jsonDecode(res.body);
  if (res.statusCode != 200) {
    final msg = (map is Map<String, dynamic>)
        ? (map['message']?.toString() ?? 'Failed to load vendors')
        : 'Failed to load vendors';
    throw Exception(msg);
  }

  if (map is! Map<String, dynamic>) return [];
  final data = map['data'];
  if (data is! Map<String, dynamic>) return [];
  final items = data['items'];
  if (items is! List) return [];

  return items
      .whereType<Map<String, dynamic>>()
      .map(VisibilityVendorItem.fromJson)
      .toList();
});

