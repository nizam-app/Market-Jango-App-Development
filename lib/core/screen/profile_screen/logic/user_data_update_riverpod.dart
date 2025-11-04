// lib/features/account/logic/update_user_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/utils/image_check_before_post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:market_jango/core/constants/api_control/vendor_api.dart'; // <- এখানে user_update URL রাখুন

/// Usage: ref.watch(updateUserProvider) for loading/error
final updateUserProvider =
StateNotifierProvider<UpdateUserNotifier, AsyncValue<void>>(
      (ref) => UpdateUserNotifier(),
);

class UpdateUserNotifier extends StateNotifier<AsyncValue<void>> {
  UpdateUserNotifier() : super(const AsyncData(null));

  /// returns true on success
  Future<bool> updateUser({
    String? name,
    String? gender,
    String? age,
    String? description,
    String? country,
    String? address,
    String? shipCity,
    File? image, // optional
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

      addField('name', name);
      addField('gender', gender);
      addField('age', age);
      addField('description', description);
      addField('country', country);
      addField('address', address);
      addField('ship_city', shipCity);



      File? coverCompressed;
      if (image != null) {
        coverCompressed = await ImageManager.compressFile(image);
        req.files.add(await http.MultipartFile.fromPath('image', coverCompressed.path));
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