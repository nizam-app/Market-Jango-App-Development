import 'dart:convert';

class VendorSearchResponse {
  final String? status;
  final VendorPageData data;

  VendorSearchResponse({this.status, required this.data});

  factory VendorSearchResponse.empty() =>
      VendorSearchResponse(status: 'success', data: VendorPageData.empty());

  factory VendorSearchResponse.fromJson(Map<String, dynamic> json) {
    return VendorSearchResponse(
      status: json['status']?.toString(),
      data: VendorPageData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  static VendorSearchResponse fromJsonString(String body) =>
      VendorSearchResponse.fromJson(jsonDecode(body) as Map<String, dynamic>);
}

class VendorPageData {
  final int currentPage;
  final List<VendorUser> users;
  final int lastPage;

  VendorPageData({
    required this.currentPage,
    required this.users,
    required this.lastPage,
  });

  factory VendorPageData.empty() =>
      VendorPageData(currentPage: 1, users: const [], lastPage: 1);

  factory VendorPageData.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(VendorUser.fromJson)
        .toList();
    return VendorPageData(
      currentPage: _toInt(json['current_page']),
      users: list,
      lastPage: _toInt(json['last_page']),
    );
  }

  /// SearchBar-এর জন্য ফ্ল্যাট সাজেশন আইটেম
  List<VendorSuggestion> get suggestions =>
      users.map(VendorSuggestion.fromUser).toList();
}

class VendorUser {
  final int id; // user id
  final String userType; // "vendor"
  final String name; // account name
  final String email;
  final String phone;
  final String? image; // avatar url (nullable)
  final String status; // "Approved"
  final VendorBrief vendor; // nested "vendor" block

  VendorUser({
    required this.id,
    required this.userType,
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
    required this.status,
    required this.vendor,
  });

  factory VendorUser.fromJson(Map<String, dynamic> json) => VendorUser(
    id: _toInt(json['id']),
    userType: json['user_type']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    image: json['image']?.toString(),
    status: json['status']?.toString() ?? '',
    vendor: VendorBrief.fromJson(
      (json['vendor'] as Map<String, dynamic>? ?? const {}),
    ),
  );
}

class VendorBrief {
  final int id; // vendor_id
  final String businessName;
  final String businessType;
  final String country;
  final String address;

  VendorBrief({
    required this.id,
    required this.businessName,
    required this.businessType,
    required this.country,
    required this.address,
  });

  factory VendorBrief.fromJson(Map<String, dynamic> json) => VendorBrief(
    id: _toInt(json['id']),
    businessName: json['business_name']?.toString() ?? '',
    businessType: json['business_type']?.toString() ?? '',
    country: json['country']?.toString() ?? '',
    address: json['address']?.toString() ?? '',
  );
}

/// SearchBar suggestion item (UI-তে এটা ব্যবহার করবে)
class VendorSuggestion {
  final int vendorId;
  final String businessName;
  final String ownerName; // user.name
  final String? imageUrl; // user.image

  VendorSuggestion({
    required this.vendorId,
    required this.businessName,
    required this.ownerName,
    required this.imageUrl,
  });

  factory VendorSuggestion.fromUser(VendorUser u) => VendorSuggestion(
    vendorId: u.vendor.id,
    businessName: u.vendor.businessName,
    ownerName: u.name,
    imageUrl: u.image,
  );
}

/// helpers
int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}
