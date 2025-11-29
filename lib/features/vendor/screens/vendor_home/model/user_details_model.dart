class VendorDetailsModel {
  final int id;
  final String name;
  final String image;
  final String? publicId;

  VendorDetailsModel({
    required this.id,
    required this.name,
    required this.image,
    this.publicId,
  });

  factory VendorDetailsModel.fromJson(Map<String, dynamic> json) {
    return VendorDetailsModel(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'] ?? 'https://i.pravatar.cc/150',
      publicId: json['public_id'],
    );
  }
}
