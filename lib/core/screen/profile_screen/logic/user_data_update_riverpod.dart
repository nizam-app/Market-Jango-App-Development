// lib/features/account/logic/update_user_provider.dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/image_check_before_post.dart';
import 'package:shared_preferences/shared_preferences.dart';

final updateUserProvider =
    StateNotifierProvider<UpdateUserNotifier, AsyncValue<void>>(
      (ref) => UpdateUserNotifier(),
    );

class UpdateUserNotifier extends StateNotifier<AsyncValue<void>> {
  UpdateUserNotifier() : super(const AsyncData(null));

  /// userType = "buyer" | "vendor" | "transport"
  Future<bool> updateUser({
    required String userType,

    // common
    String? name,
    File? image,
    double? latitude,
    double? longitude,

    // buyer only
    String? gender,
    String? age,
    String? description,
    String? country,
    String? shipLocation,
    String? shipCity,

    // vendor only
    // String? language,
    String? businessName,
    // String? businessType,
    String? address,

    // transport only (address ই reuse করব)
  }) async {
    try {
      state = const AsyncLoading();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final uri = Uri.parse(VendorAPIController.user_update);
      final req = http.MultipartRequest('POST', uri);

      if (token != null) req.headers['token'] = token;

      void addField(String key, String? v) {
        if (v != null && v.trim().isNotEmpty) {
          req.fields[key] = v.trim();
        }
      }

      void addDouble(String key, double? v) {
        if (v != null) {
          req.fields[key] = v.toString();
        }
      }

      // ----- common -----
      addField('name', name);

      // ----- buyer payload (IMAGE-1 er sathe match kore) -----
      if (userType == 'buyer') {
        addField('gender', gender);
        addField('age', age);
        addField('description', description);
        addField('country', country);
        addField('ship_location', shipLocation);
        addField('ship_city', shipCity);
        addDouble('ship_latitude', latitude);
        addDouble('ship_longitude', longitude);
      }
      // ----- vendor payload (screenshot-1 moto) -----
      else if (userType == 'vendor') {
        // addField('language', language);
        addField('country', country);
        addField('address', address);
        addField('business_name', businessName);
        // addField('business_type', businessType);
        addDouble('latitude', latitude); // NOTE: এখানে ship_ নেই
        addDouble('longitude', longitude);
      }
      // ----- transport payload (screenshot-2 moto) -----
      else if (userType == 'transport') {
        addField('address', address);
        addDouble('latitude', latitude);
        addDouble('longitude', longitude);
      }

      // ----- image -----
      if (image != null) {
        final coverCompressed = await ImageManager.compressFile(image);
        req.files.add(
          await http.MultipartFile.fromPath('image', coverCompressed.path),
        );
      }

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        state = const AsyncData(null);
        return true;
      } else {
        state = AsyncError(
          'Failed: ${res.statusCode} ${res.reasonPhrase}\n${res.body}',
          StackTrace.current,
        );
        return false;
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
