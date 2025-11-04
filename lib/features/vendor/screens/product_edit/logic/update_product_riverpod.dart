// lib/features/vendor/screens/product_edit/logic/update_product_provider.dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/image_check_before_post.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

final updateProductProvider =
    StateNotifierProvider<UpdateProductNotifier, AsyncValue<void>>(
      (ref) => UpdateProductNotifier(ref),
    );

class UpdateProductNotifier extends StateNotifier<AsyncValue<void>> {
  UpdateProductNotifier(this.ref) : super(const AsyncData(null));
  final Ref ref;

  /// returns true on success
  Future<bool> updateProduct({
    required int id,
    String? name,
    String? description,
    String? previousPrice,
    String? currentPrice, // API: current_price
    int? categoryId,
    List<String>? colors, // API: color[]
    List<String>? sizes, // API: size[]
    File? image, // API: image (main)
    List<File>? newFiles, // API: files[] (gallery additions)
  }) async {
    try {
      state = const AsyncLoading();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final uri = Uri.parse(VendorAPIController.product_update(id));

      final req = http.MultipartRequest('POST', uri);
      if (token != null) req.headers['token'] = token;

      // Helper to add only non-empty
      void addField(String key, String? value) {
        if (value != null && value.trim().isNotEmpty) {
          req.fields[key] = value.trim();
        }
      }

      addField('name', name);
      addField('description', description);
      addField('previous_price', previousPrice);
      addField('current_price', currentPrice);
      if (categoryId != null) req.fields['category_id'] = '$categoryId';

      // Arrays – server expects color[] / size[]; join with commas
      if (colors != null && colors.isNotEmpty) {
        req.fields['color[]'] = colors.join(',');
      }
      if (sizes != null && sizes.isNotEmpty) {
        req.fields['size[]'] = sizes.join(',');
      }

      File? coverCompressed;
      if (image != null) {
        // image nullable, so guard করে নিলাম
        coverCompressed = await ImageManager.compressFile(image);
        req.files.add(
          await http.MultipartFile.fromPath('image', coverCompressed.path),
        );
      }

      List<File> galleryCompressed = [];
      final toCompress = newFiles ?? const <File>[];

      if (toCompress.isNotEmpty) {
        galleryCompressed = await ImageManager.compressAll(toCompress);
        for (final f in galleryCompressed) {
          req.files.add(
            await http.MultipartFile.fromPath(
              'files[]',
              f.path,
              filename: p.basename(f.path),
            ),
          );
        }
      }

      final res = await req.send();

      if (res.statusCode == 200) {
        state = const AsyncData(null);
        // চাইলে এখানে রিফ্রেশ করুন:
        // ref.invalidate(productDetailProvider(id));
        return true;
      } else {
        state = AsyncError(
          'Failed: ${res.statusCode} ${res.reasonPhrase}',
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
