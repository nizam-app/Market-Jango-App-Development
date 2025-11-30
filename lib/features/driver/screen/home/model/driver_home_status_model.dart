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
    return DriverHomeStatsWrapper(
      data: DriverHomeStats.fromJson(
        (json['data'] as Map<String, dynamic>? ?? const {}),
      ),
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
    int _int(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return DriverHomeStats(
      totalActiveOrders: _int(json['total_active_orders']),
      picked: _int(json['picked']),
      // API key typo: "pendings_deliveries"
      pendingsDeliveries: _int(json['pendings_deliveries']),
      deliveredToday: _int(json['delivered_today']),
    );
  }
}
