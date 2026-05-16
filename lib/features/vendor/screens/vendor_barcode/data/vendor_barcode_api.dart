import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_barcode/model/vendor_barcode_models.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/vendor_order_auth.dart';

Map<String, dynamic> _decodeMap(String body) {
  final decoded = jsonDecode(body);
  if (decoded is Map<String, dynamic>) return decoded;
  throw Exception('Invalid JSON');
}

Map<String, dynamic>? _data(Map<String, dynamic> top) {
  final d = top['data'];
  if (d is Map<String, dynamic>) return d;
  return null;
}

String _message(Map<String, dynamic> top) =>
    top['message']?.toString() ?? 'Request failed';

class VendorBarcodeApi {
  VendorBarcodeApi._();
  static final VendorBarcodeApi instance = VendorBarcodeApi._();

  Future<VendorBarcodeListPage> fetchBarcodeList({
    String? search,
    int page = 1,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorProductBarcodes(search: search, page: page),
    );
    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      try {
        throw Exception(_message(_decodeMap(res.body)));
      } catch (_) {
        throw Exception('HTTP ${res.statusCode}');
      }
    }
    final top = _decodeMap(res.body);
    return VendorBarcodeListPage.fromJson(_data(top));
  }

  /// Returns product for this vendor, or throws (e.g. 404).
  Future<VendorBarcodeProduct> scanBarcode(String code) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorProductBarcodeScan(code));
    final res = await http.get(uri, headers: headers);
    if (res.statusCode == 404) {
      try {
        throw Exception(_message(_decodeMap(res.body)));
      } catch (_) {
        throw Exception('No product found with this barcode');
      }
    }
    if (res.statusCode != 200) {
      try {
        throw Exception(_message(_decodeMap(res.body)));
      } catch (_) {
        throw Exception('HTTP ${res.statusCode}');
      }
    }
    final top = _decodeMap(res.body);
    final d = _data(top) ?? top;
    return VendorBarcodeProduct.fromJson(d);
  }

  Future<VendorBarcodeProduct> fetchProductBarcode(int productId) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorProductBarcodeByProductId(productId),
    );
    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      try {
        throw Exception(_message(_decodeMap(res.body)));
      } catch (_) {
        throw Exception('HTTP ${res.statusCode}');
      }
    }
    final top = _decodeMap(res.body);
    final d = _data(top) ?? top;
    return VendorBarcodeProduct.fromJson(d);
  }

  Future<VendorBarcodeProduct> regenerateBarcode(int productId) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorProductBarcodeRegenerate(productId),
    );
    final res = await http.post(uri, headers: headers);
    if (res.statusCode != 200) {
      try {
        throw Exception(_message(_decodeMap(res.body)));
      } catch (_) {
        throw Exception('HTTP ${res.statusCode}');
      }
    }
    final top = _decodeMap(res.body);
    final d = _data(top) ?? top;
    return VendorBarcodeProduct.fromJson(d);
  }

  Future<VendorBarcodeLabelsResult> fetchLabelPayload({
    required int productId,
    required int labelCount,
  }) async {
    if (labelCount < 1 || labelCount > 500) {
      throw ArgumentError('label_count must be 1–500');
    }
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorProductBarcodeLabels(productId));
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'label_count': labelCount}),
    );
    if (res.statusCode != 200) {
      try {
        throw Exception(_message(_decodeMap(res.body)));
      } catch (_) {
        throw Exception('HTTP ${res.statusCode}');
      }
    }
    final top = _decodeMap(res.body);
    final d = _data(top) ?? top;
    return VendorBarcodeLabelsResult.fromJson(d);
  }
}
