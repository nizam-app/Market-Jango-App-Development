class VendorCategoryModel {
  final int id;
  final String name;
  final String status;
  final int vendorId;

  VendorCategoryModel({
    required this.id,
    required this.name,
    required this.status,
    required this.vendorId,
  });

  factory VendorCategoryModel.fromJson(Map<String, dynamic> json) {
    return VendorCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      vendorId: json['vendor_id'] ?? 0,
    );
  }
}
