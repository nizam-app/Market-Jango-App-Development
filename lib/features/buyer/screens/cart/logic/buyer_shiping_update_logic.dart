// user_update_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

final userUpdateServiceProvider = Provider<UserUpdateService>(
  (ref) => UserUpdateService(ref),
);

class ShippingUpdatePayload {
  final String shipAddress;
  final String shipCity;
  final String? postcode;

  final String? shipState;
  final String? shipCountry;

  final String? shipName;
  final String? shipEmail;
  final String? shipPhone;

  final File? imageFile; // optional

  ShippingUpdatePayload({
    required this.shipAddress,
    required this.shipCity,
    this.postcode,
    this.shipState,
    this.shipCountry,
    this.shipName,
    this.shipEmail,
    this.shipPhone,
    this.imageFile,
  });
}

class UserUpdateService {
  final Ref ref;
  UserUpdateService(this.ref);

  /// ✅ সাধারণ-উদ্দেশ্য ফাংশন: যেসব ফিল্ড দেবেন, কেবল সেগুলোই যাবে (multipart, image optional)
  static const Set<String> _allowedKeys = {
    'ship_address', 'ship_city', 'postcode', 'ship_state', 'ship_country',
    'ship_name', 'ship_email', 'ship_phone',
    // চাইলে প্রোফাইলের জেনেরিক ফিল্ডও
    'address', 'state', 'country', 'location', 'name', 'email', 'phone',
  };

  Future<void> updateUserFields({
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) {
      throw Exception('Token not found');
    }

    // কেবল valid + non-empty keys পাঠাবো
    final clean = <String, String>{};
    fields.forEach((k, v) {
      final key = k.trim();
      final val = v.trim();
      if (val.isNotEmpty && _allowedKeys.contains(key)) {
        clean[key] = val;
      }
    });

    if (clean.isEmpty && imageFile == null) {
      throw Exception('No valid fields to update');
    }

    final uri = Uri.parse(BuyerAPIController.user_update);
    final req = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['token'] = token
      ..fields.addAll(clean);

    if (imageFile != null) {
      req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    final res = await req.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode != 200) {
      throw Exception('Update failed: ${res.statusCode}');
    }
    final map = jsonDecode(body) as Map<String, dynamic>;
    if ('${map['status']}' != 'success') {
      throw Exception(map['message']?.toString() ?? 'Update failed');
    }
  }

  /// (আপনার আগে থাকা) শুধুই শিপিং-পেলোডে কাজ করা ফাংশন
  Future<void> updateShippingAddress(ShippingUpdatePayload p) async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) {
      throw Exception('Token not found');
    }

    final uri = Uri.parse(BuyerAPIController.user_update);
    final req = http.MultipartRequest('POST', uri);
    req.headers['Accept'] = 'application/json';
    req.headers['token'] = token;

    req.fields['ship_address'] = p.shipAddress;
    req.fields['ship_city'] = p.shipCity;

    void addIf(String key, String? v) {
      if (v != null && v.trim().isNotEmpty) req.fields[key] = v.trim();
    }

    addIf('postcode', p.postcode);
    addIf('ship_state', p.shipState);
    addIf('ship_country', p.shipCountry);

    addIf('ship_name', p.shipName);
    addIf('ship_email', p.shipEmail);
    addIf('ship_phone', p.shipPhone);

    if (p.imageFile != null) {
      req.files.add(
        await http.MultipartFile.fromPath('image', p.imageFile!.path),
      );
    }

    final res = await req.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode != 200) {
      throw Exception('Update failed: ${res.statusCode}');
    }
    final map = jsonDecode(body) as Map<String, dynamic>;
    if ('${map['status']}' != 'success') {
      throw Exception(map['message']?.toString() ?? 'Update failed');
    }
  }
}

final cartUpdatingIdsProvider = StateProvider<Set<int>>((ref) => <int>{});
