import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';          // 👈 add
import 'package:path/path.dart' as p;                   // 👈 add

import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

class VendorCategory {
  final int id;
  final String name;
  final String description;
  final String status;
  final int vendorId;

  VendorCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.vendorId,
  });

  factory VendorCategory.fromJson(Map<String, dynamic> j) {
    return VendorCategory(
      id: _toInt(j['id']),
      name: (j['name'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      status: (j['status'] ?? '').toString(),
      vendorId: _toInt(j['vendor_id']),
    );
  }
}

class CategoryCreateResponse {
  final String status;
  final String message;
  final VendorCategory data;

  CategoryCreateResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CategoryCreateResponse.fromJson(Map<String, dynamic> j) {
    return CategoryCreateResponse(
      status: (j['status'] ?? '').toString(),
      message: (j['message'] ?? '').toString(),
      data: VendorCategory.fromJson(j['data'] as Map<String, dynamic>),
    );
  }
}

/// name, description, status, images[]
Future<VendorCategory> createCategoryApi({
  required WidgetRef ref,
  required String name,
  required String description,
  required bool isActive,
  required List<XFile> images,
}) async {
  final token = await ref.read(authTokenProvider.future);
  if (token == null) throw Exception('Token not found');

  final uri = Uri.parse(VendorAPIController.category_create);
  final req = http.MultipartRequest('POST', uri)
    ..headers['Accept'] = 'application/json'
    ..headers['token'] = token
    ..fields['name'] = name
    ..fields['description'] = description
    ..fields['status'] = isActive ? 'Active' : 'Inactive';

  // ---------- MULTIPLE FILES AS images[] ----------
  for (final img in images) {
    req.files.add(
      await http.MultipartFile.fromPath(
        'images[]',      // Laravel এ array => images.0, images.1 ...
        img.path,
      ),
    );
  }

  final streamed = await req.send();
  final res = await http.Response.fromStream(streamed);

  // debug করতে চাইলে
  // debugPrint('status: ${res.statusCode}');
  // debugPrint('body: ${res.body}');

  if (res.statusCode != 200 && res.statusCode != 201) {
    throw Exception('Create failed: ${res.statusCode} ${res.body}');
  }

  final decoded = jsonDecode(res.body) as Map<String, dynamic>;
  final apiRes = CategoryCreateResponse.fromJson(decoded);

  if (apiRes.status.toLowerCase() != 'success') {
    throw Exception(apiRes.message);
  }

  return apiRes.data;
}

int _toInt(dynamic v) =>
    v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);