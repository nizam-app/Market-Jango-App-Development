/// Single item from GET api/affiliate/vendor-links/{vendorId}
class VendorAffiliateLinkModel {
  final int id;
  final String? name;
  final String? description;
  final String? destinationUrl;
  final int? customRate;
  final int? cookieDurationDays;
  final String? attributionModel;
  final String status;
  final String? expiresAt;
  final String? createdAt;

  const VendorAffiliateLinkModel({
    required this.id,
    this.name,
    this.description,
    this.destinationUrl,
    this.customRate,
    this.cookieDurationDays,
    this.attributionModel,
    this.status = 'active',
    this.expiresAt,
    this.createdAt,
  });

  String get displayName => name?.trim().isNotEmpty == true ? name! : 'Link #$id';

  factory VendorAffiliateLinkModel.fromJson(Map<String, dynamic> json) {
    int? toIntN(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return VendorAffiliateLinkModel(
      id: toIntN(json['id']) ?? 0,
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      destinationUrl: json['destination_url']?.toString(),
      customRate: toIntN(json['custom_rate']),
      cookieDurationDays: toIntN(json['cookie_duration_days']),
      attributionModel: json['attribution_model']?.toString(),
      status: json['status']?.toString() ?? 'active',
      expiresAt: json['expires_at']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
