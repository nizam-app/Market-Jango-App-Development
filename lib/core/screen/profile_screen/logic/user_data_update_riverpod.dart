// lib/features/account/logic/update_user_provider.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';
import 'package:market_jango/core/utils/image_check_before_post.dart';

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
    File? image, // profile image
    File? coverImage, // cover image
    double? latitude,
    double? longitude,
    String? currency,

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
    double? driverPrice,

    // transport only (address ই reuse করব)
  }) async {
    try {
      state = const AsyncLoading();

      final authStorage = AuthLocalStorage();
      final token = await authStorage.getToken();

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
      addField('currency', currency);

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
      } else if (userType == 'driver') {
        addDouble('price', driverPrice);
      }

      // ----- image -----
      if (image != null) {
        final coverCompressed = await ImageManager.compressFile(image);
        req.files.add(
          await http.MultipartFile.fromPath('image', coverCompressed.path),
        );
      }
      
      // ----- cover image -----
      if (coverImage != null) {
        final coverCompressed = await ImageManager.compressFile(coverImage);
        req.files.add(
          await http.MultipartFile.fromPath('cover_image', coverCompressed.path),
        );
      }

      // Debug: Print request details (for troubleshooting)
      print('Update User Request - userType: $userType');
      print('Fields: ${req.fields}');
      print('Files: ${req.files.map((f) => f.field).toList()}');

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);
      
      // Debug: Print response (for troubleshooting)
      print('Update User Response - Status: ${res.statusCode}');
      print('Response Body: ${res.body}');

      if (res.statusCode == 200) {
        // Check response body for status field
        try {
          final bodyMap = jsonDecode(res.body) as Map<String, dynamic>?;
          final status = bodyMap?['status']?.toString().toLowerCase();
          
          if (status == 'success' || status == null) {
            state = const AsyncData(null);
            return true;
          } else {
            final message = bodyMap?['message']?.toString() ?? 'Update failed';
            state = AsyncError(
              message,
              StackTrace.current,
            );
            return false;
          }
        } catch (e) {
          // If JSON parsing fails, assume success if status code is 200
          state = const AsyncData(null);
          return true;
        }
      } else {
        try {
          final bodyMap = jsonDecode(res.body) as Map<String, dynamic>?;
          final message = bodyMap?['message']?.toString() ?? 
              'Failed: ${res.statusCode} ${res.reasonPhrase}';
          state = AsyncError(
            message,
            StackTrace.current,
          );
        } catch (e) {
          state = AsyncError(
            'Failed: ${res.statusCode} ${res.reasonPhrase}\n${res.body}',
            StackTrace.current,
          );
        }
        return false;
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
