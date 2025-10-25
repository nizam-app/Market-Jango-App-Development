class VendorModel {
  final String country;
  final String businessName;
  final String businessType;
  final String address;
  final int id;
  final int userId;

  VendorModel({
    required this.country,
    required this.businessName,
    required this.businessType,
    required this.address,
    required this.id,
    required this.userId,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) => VendorModel(
    country: json['country'] ?? '',
    businessName: json['business_name'] ?? '',
    businessType: json['business_type'] ?? '',
    address: json['address'] ?? '',
    id: json['id'] ?? 0,
    userId: int.tryParse(json['user_id'].toString()) ?? 0,
  );
}
