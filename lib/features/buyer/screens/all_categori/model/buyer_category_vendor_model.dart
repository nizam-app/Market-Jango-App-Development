class VendorMini {
  final int id;
  final String businessName;
  final String country;
  final String address;
  final String businessType;
  final int userId;

  VendorMini({
    required this.id,
    required this.businessName,
    required this.country,
    required this.address,
    required this.businessType,
    required this.userId,
  });

  factory VendorMini.fromJson(Map<String, dynamic> j) => VendorMini(
    id: j['id'] as int,
    businessName: (j['business_name'] ?? '').toString(),
    country: (j['country'] ?? '').toString(),
    address: (j['address'] ?? '').toString(),
    businessType: (j['business_type'] ?? '').toString(),
    userId: j['user_id'] as int,
  );
}