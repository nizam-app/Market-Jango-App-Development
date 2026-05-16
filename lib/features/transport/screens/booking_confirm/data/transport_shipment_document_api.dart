import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/transport_api.dart';

/// Laravel may return JSON errors as body; successful PDF starts with `%PDF`.
void _throwIfShipmentDownloadBodyIsJsonError(Uint8List bytes) {
  if (bytes.isEmpty || bytes[0] != 0x7B) return;
  try {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is Map<String, dynamic>) {
      final st = decoded['status']?.toString().toLowerCase();
      final msg = decoded['message']?.toString();
      if (st == 'error' ||
          st == 'fail' ||
          (msg != null && msg.trim().isNotEmpty)) {
        throw Exception(
          msg != null && msg.trim().isNotEmpty ? msg.trim() : 'Download failed',
        );
      }
    }
  } on FormatException {
    // not JSON
  }
}

String _normalizeTokenHeader(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return t;
  if (t.toLowerCase().startsWith('bearer ')) return t;
  return 'Bearer $t';
}

Map<String, String> _shipmentPdfHeaders(String token) {
  return {
    'Accept': 'application/pdf',
    if (token.isNotEmpty) 'token': _normalizeTokenHeader(token),
  };
}

String _httpErrorMessage(http.Response res) {
  final body = res.body;
  if (body.isEmpty) return 'HTTP ${res.statusCode}';
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final msg = decoded['message']?.toString().trim();
      if (msg != null && msg.isNotEmpty) return msg;
    }
  } catch (_) {}
  return 'HTTP ${res.statusCode}';
}

class TransportShipmentPdfBytes {
  const TransportShipmentPdfBytes({required this.bytes, this.contentType});

  final Uint8List bytes;
  final String? contentType;
}

/// `GET /api/shipments/{id}/download-invoice` — PDF on success (`doc/details.md` §2).
Future<TransportShipmentPdfBytes> fetchTransportShipmentInvoiceDocument({
  required String token,
  required int shipmentId,
}) async {
  if (shipmentId <= 0) throw Exception('Invalid shipment id');
  final uri = Uri.parse(TransportAPIController.shipmentDownloadInvoice(shipmentId));
  final res = await http.get(uri, headers: _shipmentPdfHeaders(token));
  if (res.statusCode != 200) {
    throw Exception(_httpErrorMessage(res));
  }
  _throwIfShipmentDownloadBodyIsJsonError(res.bodyBytes);
  return TransportShipmentPdfBytes(
    bytes: res.bodyBytes,
    contentType: res.headers['content-type'],
  );
}

/// `GET /api/shipments/{id}/download-delivery-label` — PDF on success (`doc/details.md` §2).
Future<TransportShipmentPdfBytes> fetchTransportShipmentDeliveryLabelDocument({
  required String token,
  required int shipmentId,
}) async {
  if (shipmentId <= 0) throw Exception('Invalid shipment id');
  final uri = Uri.parse(
    TransportAPIController.shipmentDownloadDeliveryLabel(shipmentId),
  );
  final res = await http.get(uri, headers: _shipmentPdfHeaders(token));
  if (res.statusCode != 200) {
    throw Exception(_httpErrorMessage(res));
  }
  _throwIfShipmentDownloadBodyIsJsonError(res.bodyBytes);
  return TransportShipmentPdfBytes(
    bytes: res.bodyBytes,
    contentType: res.headers['content-type'],
  );
}
