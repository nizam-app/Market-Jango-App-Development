/// Single product visibility rule (country/state/town).
class VisibilityModel {
  final int id;
  final int productId;
  final String? country;
  final String? state;
  final String? town;
  final bool isActive;
  final VisibilityProductInfo? product;

  const VisibilityModel({
    required this.id,
    required this.productId,
    this.country,
    this.state,
    this.town,
    this.isActive = true,
    this.product,
  });

  String get locationDisplay {
    final parts = [
      if (country != null && country!.isNotEmpty) country,
      if (state != null && state!.isNotEmpty) state,
      if (town != null && town!.isNotEmpty) town,
    ];
    if (parts.isEmpty) return 'Global';
    return parts.join(', ');
  }

  factory VisibilityModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, {int def = 0}) {
      if (v == null) return def;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? def;
    }

    return VisibilityModel(
      id: toInt(json['id']),
      productId: toInt(json['product_id']),
      country: json['country']?.toString(),
      state: json['state']?.toString(),
      town: json['town']?.toString(),
      isActive: json['is_active'] == true,
      product: json['product'] != null
          ? VisibilityProductInfo.fromJson(
              json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toSetBody() => {
        'product_id': productId,
        if (country != null && country!.isNotEmpty) 'country': country,
        if (state != null && state!.isNotEmpty) 'state': state,
        if (town != null && town!.isNotEmpty) 'town': town,
        'is_active': isActive,
      };

  Map<String, dynamic> toUpdateBody() => {
        if (country != null) 'country': country,
        if (state != null) 'state': state,
        if (town != null) 'town': town,
        'is_active': isActive,
      };
}

class VisibilityProductInfo {
  final int id;
  final String name;
  final int? vendorId;

  const VisibilityProductInfo({
    required this.id,
    required this.name,
    this.vendorId,
  });

  factory VisibilityProductInfo.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, {int def = 0}) {
      if (v == null) return def;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? def;
    }

    return VisibilityProductInfo(
      id: toInt(json['id']),
      name: json['name']?.toString() ?? '',
      vendorId: json['vendor_id'] != null ? toInt(json['vendor_id']) : null,
    );
  }
}

/// Response from GET /api/vendor-dashboard/visibility
class VisibilityDashboardModel {
  final VisibilitySummary summary;
  final VisibilityUsage usage;
  final List<VisibilityByProduct> byProduct;
  final List<VisibilityModel> allVisibilities;

  const VisibilityDashboardModel({
    required this.summary,
    required this.usage,
    required this.byProduct,
    required this.allVisibilities,
  });

  factory VisibilityDashboardModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, {int def = 0}) {
      if (v == null) return def;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? def;
    }

    final summaryMap = json['summary'] as Map<String, dynamic>?;
    final usageMap = json['usage'] as Map<String, dynamic>?;
    final byProductList = json['by_product'] as List<dynamic>? ?? [];
    final allList = json['all_visibilities'] as List<dynamic>? ?? [];

    return VisibilityDashboardModel(
      summary: summaryMap != null
          ? VisibilitySummary(
              totalVisibilities: toInt(summaryMap['total_visibilities']),
              uniqueLocations: toInt(summaryMap['unique_locations']),
            )
          : const VisibilitySummary(totalVisibilities: 0, uniqueLocations: 0),
      usage: usageMap != null
          ? VisibilityUsage(
              locationsUsed: toInt(usageMap['locations_used']),
              locationsLimit: toInt(usageMap['locations_limit']),
              canAddMore: usageMap['can_add_more'] == true,
            )
          : const VisibilityUsage(
              locationsUsed: 0, locationsLimit: 0, canAddMore: false),
      byProduct: byProductList
          .whereType<Map<String, dynamic>>()
          .map(VisibilityByProduct.fromJson)
          .toList(),
      allVisibilities: allList
          .whereType<Map<String, dynamic>>()
          .map(VisibilityModel.fromJson)
          .toList(),
    );
  }
}

class VisibilitySummary {
  final int totalVisibilities;
  final int uniqueLocations;

  const VisibilitySummary({
    required this.totalVisibilities,
    required this.uniqueLocations,
  });
}

class VisibilityUsage {
  final int locationsUsed;
  final int locationsLimit;
  final bool canAddMore;

  const VisibilityUsage({
    required this.locationsUsed,
    required this.locationsLimit,
    required this.canAddMore,
  });
}

class VisibilityByProduct {
  final int productId;
  final String productName;
  final int count;
  final List<VisibilityModel> visibilities;

  const VisibilityByProduct({
    required this.productId,
    required this.productName,
    required this.count,
    required this.visibilities,
  });

  factory VisibilityByProduct.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, {int def = 0}) {
      if (v == null) return def;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? def;
    }

    final visList = json['visibilities'] as List<dynamic>? ?? [];
    return VisibilityByProduct(
      productId: toInt(json['product_id']),
      productName: json['product_name']?.toString() ?? '',
      count: toInt(json['count']),
      visibilities: visList
          .whereType<Map<String, dynamic>>()
          .map(VisibilityModel.fromJson)
          .toList(),
    );
  }
}
