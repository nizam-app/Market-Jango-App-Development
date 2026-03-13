/// Models for GET /api/vendor/route-points response (see API_VENDOR_ROUTE_POINTS.md).

int _toInt(dynamic v) =>
    v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);

double _toDouble(dynamic v) => v == null
    ? 0.0
    : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);

bool _toBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is int) return v == 1;
  if (v is String) return v.toLowerCase() == 'true' || v == '1';
  return false;
}

/// Pagination from data.pagination
class RoutePointsPagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  RoutePointsPagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  factory RoutePointsPagination.fromJson(Map<String, dynamic> j) {
    return RoutePointsPagination(
      total: _toInt(j['total']),
      perPage: _toInt(j['per_page']),
      currentPage: _toInt(j['current_page']),
      lastPage: _toInt(j['last_page']),
    );
  }

  factory RoutePointsPagination.empty() => RoutePointsPagination(
        total: 0,
        perPage: 20,
        currentPage: 1,
        lastPage: 1,
      );
}

/// One weight range item
class WeightRange {
  final int id;
  final double minWeight;
  final double maxWeight;
  final double perKgCharge;
  final double? minCharge;
  final double? maxCharge;
  final bool enabled;

  WeightRange({
    required this.id,
    required this.minWeight,
    required this.maxWeight,
    required this.perKgCharge,
    this.minCharge,
    this.maxCharge,
    required this.enabled,
  });

  factory WeightRange.fromJson(Map<String, dynamic> j) => WeightRange(
        id: _toInt(j['id']),
        minWeight: _toDouble(j['min_weight']),
        maxWeight: _toDouble(j['max_weight']),
        perKgCharge: _toDouble(j['per_kg_charge']),
        minCharge: j['min_charge'] != null ? _toDouble(j['min_charge']) : null,
        maxCharge: j['max_charge'] != null ? _toDouble(j['max_charge']) : null,
        enabled: _toBool(j['enabled']),
      );
}

/// One distance range item
class DistanceRange {
  final int id;
  final double minDistanceKm;
  final double maxDistanceKm;
  final double perKmCharge;
  final double? minCharge;
  final double? maxCharge;
  final bool enabled;

  DistanceRange({
    required this.id,
    required this.minDistanceKm,
    required this.maxDistanceKm,
    required this.perKmCharge,
    this.minCharge,
    this.maxCharge,
    required this.enabled,
  });

  factory DistanceRange.fromJson(Map<String, dynamic> j) => DistanceRange(
        id: _toInt(j['id']),
        minDistanceKm: _toDouble(j['min_distance_km']),
        maxDistanceKm: _toDouble(j['max_distance_km']),
        perKmCharge: _toDouble(j['per_km_charge']),
        minCharge: j['min_charge'] != null ? _toDouble(j['min_charge']) : null,
        maxCharge: j['max_charge'] != null ? _toDouble(j['max_charge']) : null,
        enabled: _toBool(j['enabled']),
      );
}

/// One cube range item
class CubeRange {
  final int id;
  final double minCube;
  final double maxCube;
  final double perCubeCharge;
  final double? minCharge;
  final double? maxCharge;
  final bool enabled;

  CubeRange({
    required this.id,
    required this.minCube,
    required this.maxCube,
    required this.perCubeCharge,
    this.minCharge,
    this.maxCharge,
    required this.enabled,
  });

  factory CubeRange.fromJson(Map<String, dynamic> j) => CubeRange(
        id: _toInt(j['id']),
        minCube: _toDouble(j['min_cube']),
        maxCube: _toDouble(j['max_cube']),
        perCubeCharge: _toDouble(j['per_cube_charge']),
        minCharge: j['min_charge'] != null ? _toDouble(j['min_charge']) : null,
        maxCharge: j['max_charge'] != null ? _toDouble(j['max_charge']) : null,
        enabled: _toBool(j['enabled']),
      );
}

/// One route point from data.items[]
class RoutePointItem {
  final int id;
  final String zoneName;
  final String routeName;
  final String fromPoint;
  final String toPoint;
  final String startPoint;
  final String endPoint;
  final double flatBaseCharge;
  final double flatBasePrice;
  final bool flatEnabled;
  final double price;
  final String currency;
  final String status;
  final int? vendorId;
  final String? weightBaseRange;
  final List<WeightRange> weightRanges;
  final String? distanceBaseRange;
  final List<DistanceRange> distanceRanges;
  final String? cubicBaseRange;
  final List<CubeRange> cubeRanges;
  final String? createdAt;
  final String? updatedAt;
  final bool isSelected;

  RoutePointItem({
    required this.id,
    required this.zoneName,
    required this.routeName,
    required this.fromPoint,
    required this.toPoint,
    required this.startPoint,
    required this.endPoint,
    required this.flatBaseCharge,
    required this.flatBasePrice,
    required this.flatEnabled,
    required this.price,
    required this.currency,
    required this.status,
    this.vendorId,
    this.weightBaseRange,
    required this.weightRanges,
    this.distanceBaseRange,
    required this.distanceRanges,
    this.cubicBaseRange,
    required this.cubeRanges,
    this.createdAt,
    this.updatedAt,
    required this.isSelected,
  });

  factory RoutePointItem.fromJson(Map<String, dynamic> j) {
    return RoutePointItem(
      id: _toInt(j['id']),
      zoneName: j['zone_name']?.toString() ?? '',
      routeName: j['route_name']?.toString() ?? '',
      fromPoint: j['from_point']?.toString() ?? '',
      toPoint: j['to_point']?.toString() ?? '',
      startPoint: j['start_point']?.toString() ?? '',
      endPoint: j['end_point']?.toString() ?? '',
      flatBaseCharge: _toDouble(j['flat_base_charge']),
      flatBasePrice: _toDouble(j['flat_base_price']),
      flatEnabled: _toBool(j['flat_enabled']),
      price: _toDouble(j['price']),
      currency: j['currency']?.toString() ?? '',
      status: j['status']?.toString() ?? '',
      vendorId: j['vendor_id'] != null ? _toInt(j['vendor_id']) : null,
      weightBaseRange: j['weight_base_range']?.toString(),
      weightRanges: (j['weight_ranges'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => WeightRange.fromJson(e))
              .toList() ??
          [],
      distanceBaseRange: j['distance_base_range']?.toString(),
      distanceRanges: (j['distance_ranges'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => DistanceRange.fromJson(e))
              .toList() ??
          [],
      cubicBaseRange: j['cubic_base_range']?.toString(),
      cubeRanges: (j['cube_ranges'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => CubeRange.fromJson(e))
              .toList() ??
          [],
      createdAt: j['created_at']?.toString(),
      updatedAt: j['updated_at']?.toString(),
      isSelected: _toBool(j['is_selected']),
    );
  }

  /// Display: "from → to" or route_name
  String get displayRouteName {
    if (fromPoint.isNotEmpty && toPoint.isNotEmpty) {
      return '$fromPoint to $toPoint';
    }
    return routeName.isNotEmpty ? routeName : 'Route #$id';
  }
}

/// Full list response: data.items + data.pagination (pass API response["data"] to fromJson).
class RoutePointsResponse {
  final List<RoutePointItem> items;
  final RoutePointsPagination pagination;

  RoutePointsResponse({
    required this.items,
    required this.pagination,
  });

  factory RoutePointsResponse.fromJson(Map<String, dynamic> j) {
    final itemsList = j['items'] as List<dynamic>? ?? [];
    final items = itemsList
        .whereType<Map<String, dynamic>>()
        .map((e) => RoutePointItem.fromJson(e))
        .toList();
    final pagMap = j['pagination'];
    final pagination = pagMap is Map<String, dynamic>
        ? RoutePointsPagination.fromJson(pagMap)
        : RoutePointsPagination.empty();
    return RoutePointsResponse(items: items, pagination: pagination);
  }
}
