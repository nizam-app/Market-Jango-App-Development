// lib/features/driver/home/model/driver_home_stats_model.dart

class DriverHomeStatsResponse {
  final String status;
  final String message;
  final DriverHomeStatsWrapper data;

  DriverHomeStatsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DriverHomeStatsResponse.fromJson(Map<String, dynamic> json) {
    return DriverHomeStatsResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: DriverHomeStatsWrapper.fromJson(
        (json['data'] as Map<String, dynamic>? ?? const {}),
      ),
    );
  }
}

class DriverHomeStatsWrapper {
  final DriverHomeStats data;

  DriverHomeStatsWrapper({required this.data});

  factory DriverHomeStatsWrapper.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    
    // Handle case where data might be a string (error message) instead of object
    if (dataJson is String) {
      throw Exception('Invalid response: data is a string instead of object: $dataJson');
    }
    
    // Handle null or non-map data
    if (dataJson == null || dataJson is! Map<String, dynamic>) {
      throw Exception(
        'Invalid response: driver home stats data is missing or invalid. '
        'Expected object but got: ${dataJson?.runtimeType ?? 'null'}. '
        'This might happen if driver profile is not fully initialized.',
      );
    }
    
    return DriverHomeStatsWrapper(
      data: DriverHomeStats.fromJson(dataJson),
    );
  }
}

class DriverHomeStats {
  final int totalActiveOrders;
  final int picked;
  final int pendingsDeliveries;
  final int deliveredToday;

  DriverHomeStats({
    required this.totalActiveOrders,
    required this.picked,
    required this.pendingsDeliveries,
    required this.deliveredToday,
  });

  factory DriverHomeStats.fromJson(Map<String, dynamic> json) {
     int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return DriverHomeStats(
      totalActiveOrders: _toInt(json['total_active_orders']),
      picked: _toInt(json['picked']),
      // API key typo: "pendings_deliveries"
      pendingsDeliveries: _toInt(json['pendings_deliveries']),
      deliveredToday: _toInt(json['delivered_today']),
    );
  }
}
