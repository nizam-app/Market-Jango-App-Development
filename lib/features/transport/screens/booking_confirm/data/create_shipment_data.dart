import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/transport_api.dart';

/// Request body for POST $baseUrl/shipments (create shipment draft).
class CreateShipmentRequest {
  final int driverId;
  final String? transportType;
  final String? originAddress;
  final String? destinationAddress;
  final double? originLatitude;
  final double? originLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final String? pickupInstructions;
  final String? pickupContactPhone;
  final double? declaredValue;
  final String? declaredValueCurrency;
  final String? messageToDriver;
  final List<ShipmentPackageInput> packages;

  CreateShipmentRequest({
    required this.driverId,
    this.transportType,
    this.originAddress,
    this.destinationAddress,
    this.originLatitude,
    this.originLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.pickupInstructions,
    this.pickupContactPhone,
    this.declaredValue,
    this.declaredValueCurrency,
    this.messageToDriver,
    required this.packages,
  });

  Map<String, dynamic> toJson() => {
    'driver_id': driverId,
    if (transportType != null && transportType!.isNotEmpty)
      'transport_type': transportType,
    if (originAddress != null && originAddress!.trim().isNotEmpty)
      'origin_address': originAddress!.trim(),
    if (destinationAddress != null && destinationAddress!.trim().isNotEmpty)
      'destination_address': destinationAddress!.trim(),
    if (originLatitude != null) 'origin_latitude': originLatitude,
    if (originLongitude != null) 'origin_longitude': originLongitude,
    if (destinationLatitude != null)
      'destination_latitude': destinationLatitude,
    if (destinationLongitude != null)
      'destination_longitude': destinationLongitude,
    if (pickupInstructions != null && pickupInstructions!.isNotEmpty)
      'pickup_instructions': pickupInstructions,
    if (pickupContactPhone != null && pickupContactPhone!.isNotEmpty)
      'pickup_contact_phone': pickupContactPhone,
    if (declaredValue != null) 'declared_value': declaredValue,
    if (declaredValueCurrency != null)
      'declared_value_currency': declaredValueCurrency,
    if (messageToDriver != null && messageToDriver!.isNotEmpty)
      'message_to_driver': messageToDriver,
    'packages': packages.map((e) => e.toJson()).toList(),
  };
}

class ShipmentPackageInput {
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;
  final double? weightKg;
  final int quantity;

  ShipmentPackageInput({
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    this.weightKg,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    if (lengthCm != null) 'length_cm': lengthCm,
    if (widthCm != null) 'width_cm': widthCm,
    if (heightCm != null) 'height_cm': heightCm,
    if (weightKg != null) 'weight_kg': weightKg,
    'quantity': quantity,
  };
}

/// Response from POST /shipments (create shipment).
class CreateShipmentResult {
  final Map<String, dynamic>? shipment;
  final int totalPieces;
  final double totalWeightKg;

  CreateShipmentResult({
    this.shipment,
    required this.totalPieces,
    required this.totalWeightKg,
  });
}

/// Calls POST $baseUrl/shipments. Throws on non-success.
Future<CreateShipmentResult> createShipment({
  required String token,
  required CreateShipmentRequest request,
}) async {
  final uri = Uri.parse(TransportAPIController.createShipment);
  final res = await http.post(
    uri,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'token': token,
    },
    body: jsonEncode(request.toJson()),
  );

  final json = jsonDecode(res.body) as Map<String, dynamic>;
  if (json['status'] != 'success') {
    throw Exception(json['message']?.toString() ?? 'Failed to create shipment');
  }

  final data = json['data'] as Map<String, dynamic>? ?? {};
  return CreateShipmentResult(
    shipment: data['shipment'] as Map<String, dynamic>?,
    totalPieces: (data['total_pieces'] as num?)?.toInt() ?? 0,
    totalWeightKg: (data['total_weight_kg'] as num?)?.toDouble() ?? 0,
  );
}

/// Response from POST /shipments/{id}/initiate-payment (payment_url for WebView).
class InitiateShipmentPaymentResult {
  final String paymentUrl;
  final String? txRef;
  final int? shipmentId;

  InitiateShipmentPaymentResult({
    required this.paymentUrl,
    this.txRef,
    this.shipmentId,
  });
}

/// Calls POST $baseUrl/shipments/{id}/initiate-payment (doc §3.5).
/// Body: {}. Returns payment_url; open in WebView. Do not call /pay when using this flow.
Future<InitiateShipmentPaymentResult> initiateShipmentPayment({
  required String token,
  required int shipmentId,
}) async {
  final uri = Uri.parse(TransportAPIController.initiateShipmentPayment(shipmentId));
  final res = await http.post(
    uri,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'token': token,
    },
    body: jsonEncode(<String, dynamic>{}),
  );

  final json = jsonDecode(res.body) as Map<String, dynamic>;
  if (json['status'] != 'success') {
    throw Exception(json['message']?.toString() ?? 'Failed to initiate payment');
  }

  final data = json['data'] as Map<String, dynamic>? ?? {};
  final paymentUrl = data['payment_url']?.toString();
  if (paymentUrl == null || paymentUrl.isEmpty) {
    throw Exception('Missing payment_url in response');
  }

  return InitiateShipmentPaymentResult(
    paymentUrl: paymentUrl,
    txRef: data['tx_ref']?.toString(),
    shipmentId: (data['shipment_id'] as num?)?.toInt(),
  );
}

/// Calls POST $baseUrl/shipments/{id}/pay (doc §3.5b). Use for mark-as-paid only (e.g. cash); optional body: { "transaction_id": "..." }.
Future<void> payShipment({
  required String token,
  required int shipmentId,
  String? transactionId,
}) async {
  final uri = Uri.parse(TransportAPIController.payShipment(shipmentId));
  final body = transactionId != null
      ? {'transaction_id': transactionId}
      : <String, dynamic>{};
  final res = await http.post(
    uri,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'token': token,
    },
    body: jsonEncode(body),
  );

  final json = jsonDecode(res.body) as Map<String, dynamic>;
  if (json['status'] != 'success') {
    throw Exception(json['message']?.toString() ?? 'Failed to pay shipment');
  }
}

// ---------- List my shipments (doc §3.6) & single details (doc §3.7) ----------

/// One item from GET $baseUrl/shipments list. deliveryStatus maps to tabs: "On the way" | "Completed".
class ShipmentListItem {
  final int id;
  final String? originAddress;
  final String? destinationAddress;
  final String? status;
  final String? paymentStatus;
  final num? estimatedPrice;
  final num? finalPrice;
  final int totalPieces;
  final double totalWeightKg;
  final Map<String, dynamic>? driver;
  final String? createdAt;

  ShipmentListItem({
    required this.id,
    this.originAddress,
    this.destinationAddress,
    this.status,
    this.paymentStatus,
    this.estimatedPrice,
    this.finalPrice,
    this.totalPieces = 0,
    this.totalWeightKg = 0,
    this.driver,
    this.createdAt,
  });

  /// For My bookings tabs: "Completed" | "On the way"
  String get deliveryStatus {
    final s = (status ?? '').toLowerCase();
    final ps = (paymentStatus ?? '').toLowerCase();
    // If backend didn't send any status or payment_status, don't invent "On the way"
    if (s.isEmpty && ps.isEmpty) {
      return '';
    }
    if (s.contains('complete') || s.contains('delivered') || ps == 'paid') {
      return 'Completed';
    }
    return 'On the way';
  }

  static ShipmentListItem fromJson(Map<String, dynamic> j) {
    final driver = j['driver'];
    return ShipmentListItem(
      id: (j['id'] as num?)?.toInt() ?? 0,
      originAddress: j['origin_address']?.toString(),
      destinationAddress: j['destination_address']?.toString(),
      status: j['status']?.toString(),
      paymentStatus: j['payment_status']?.toString(),
      estimatedPrice: j['estimated_price'] as num?,
      finalPrice: j['final_price'] as num?,
      totalPieces: (j['total_pieces'] as num?)?.toInt() ?? 0,
      totalWeightKg: (j['total_weight_kg'] as num?)?.toDouble() ?? 0,
      driver: driver is Map<String, dynamic> ? driver : null,
      createdAt: j['created_at']?.toString(),
    );
  }
}

/// Result of GET $baseUrl/shipments (doc §3.6).
class ShipmentListResult {
  final List<ShipmentListItem> items;
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  ShipmentListResult({
    required this.items,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });
}

/// GET $baseUrl/shipments?per_page=15&page=1 (doc §3.6).
Future<ShipmentListResult> getMyShipments({
  required String token,
  int page = 1,
  int perPage = 15,
}) async {
  final uri = Uri.parse(TransportAPIController.createShipment).replace(
    queryParameters: {'page': page.toString(), 'per_page': perPage.toString()},
  );
  final res = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
      if (token.isNotEmpty) 'token': token,
    },
  );
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  if (json['status'] != 'success') {
    throw Exception(json['message']?.toString() ?? 'Failed to load shipments');
  }
  final data = json['data'] as Map<String, dynamic>? ?? {};
  final rawItems = data['items'] as List<dynamic>? ?? [];
  final items = rawItems
      .map((e) => ShipmentListItem.fromJson(e as Map<String, dynamic>))
      .toList();
  final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
  return ShipmentListResult(
    items: items,
    total: (pagination['total'] as num?)?.toInt() ?? 0,
    perPage: (pagination['per_page'] as num?)?.toInt() ?? perPage,
    currentPage: (pagination['current_page'] as num?)?.toInt() ?? page,
    lastPage: (pagination['last_page'] as num?)?.toInt() ?? 1,
  );
}

/// GET $baseUrl/shipments/{id} (doc §3.7). Returns data with shipment, total_pieces, total_weight_kg.
Future<Map<String, dynamic>> getShipmentDetails({
  required String token,
  required int shipmentId,
}) async {
  final uri = Uri.parse(TransportAPIController.shipmentById(shipmentId));
  final res = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
      if (token.isNotEmpty) 'token': token,
    },
  );
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  if (json['status'] != 'success') {
    throw Exception(json['message']?.toString() ?? 'Failed to load shipment');
  }
  return json['data'] as Map<String, dynamic>? ?? {};
}
