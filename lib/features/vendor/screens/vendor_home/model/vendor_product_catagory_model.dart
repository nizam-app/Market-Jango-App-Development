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
    int _toInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is num) return value.toInt();
      return defaultValue;
    }

    return VendorCategoryModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      vendorId: _toInt(json['vendor_id']),
    );
  }
}
