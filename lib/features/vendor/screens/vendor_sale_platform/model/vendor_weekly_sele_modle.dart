// vendor_weekly_sell_model.dart
import 'dart:convert';

VendorWeeklySellResponse vendorWeeklySellResponseFromJson(String s) =>
    VendorWeeklySellResponse.fromJson(jsonDecode(s) as Map<String, dynamic>);

class VendorWeeklySellResponse {
  final String status;
  final String? message;
  final WeeklySellData data;

  VendorWeeklySellResponse({
    required this.status,
    this.message,
    required this.data,
  });

  factory VendorWeeklySellResponse.fromJson(Map<String, dynamic> json) {
    // API: { status, message, data: { data: { days, current_period, previous_period } } }
    final outerData = json['data'] as Map<String, dynamic>? ?? {};
    final innerData = outerData['data'] as Map<String, dynamic>? ?? {};

    return VendorWeeklySellResponse(
      status: (json['status'] ?? '').toString(),
      message: json['message']?.toString(),
      data: WeeklySellData.fromJson(innerData),
    );
  }
}

class WeeklySellData {
  final List<String> days;
  final List<double> currentPeriod;
  final List<double> previousPeriod;

  WeeklySellData({
    required this.days,
    required this.currentPeriod,
    required this.previousPeriod,
  });

  factory WeeklySellData.fromJson(Map<String, dynamic> j) {
    return WeeklySellData(
      days: ((j['days'] as List?) ?? []).map((e) => e.toString()).toList(),
      currentPeriod: _toDoubleList(j['current_period'] as List?),
      previousPeriod: _toDoubleList(j['previous_period'] as List?),
    );
  }
}

List<double> _toDoubleList(List? list) {
  return (list ?? [])
      .map<double>(
        (e) => e is num ? e.toDouble() : double.tryParse(e.toString()) ?? 0.0,
      )
      .toList();
}
