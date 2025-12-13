// lib/features/vendor/screens/product_edit/logic/update_product_provider.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';
import 'package:market_jango/core/utils/image_check_before_post.dart';
import 'package:path/path.dart' as p;

final updateProductProvider =
    StateNotifierProvider<UpdateProductNotifier, AsyncValue<void>>(
      (ref) => UpdateProductNotifier(ref),
    );

class UpdateProductNotifier extends StateNotifier<AsyncValue<void>> {
  UpdateProductNotifier(this.ref) : super(const AsyncData(null));
  final Ref ref;

  Future<bool> updateProduct({
    required int id,
    String? name,
    String? description,

    // ✅ API expects these:
    String? regularPrice, // regular_price
    String? sellPrice, // sell_price

    int? categoryId,
    Map<String, List<String>>? attributes, // JSON string in form-data
    String? stock, // if API supports
    File? image, // main image
    List<File>? newFiles, // files[]
  }) async {
    try {
      state = const AsyncLoading();

      final token = await AuthLocalStorage().getToken();
      final uri = Uri.parse(VendorAPIController.product_update(id));

      final req = http.MultipartRequest('POST', uri);

      if (token != null && token.isNotEmpty) {
        req.headers['token'] = token;
      }
      req.headers['Accept'] = 'application/json';

      void addField(String key, String? value) {
        if (value != null && value.trim().isNotEmpty) {
          req.fields[key] = value.trim();
        }
      }

      addField('name', name);
      addField('description', description);

      // ✅ FIXED: match API keys
      addField('regular_price', regularPrice);
      addField('sell_price', sellPrice);

      if (categoryId != null) req.fields['category_id'] = '$categoryId';
      addField('stock', stock);

      if (attributes != null && attributes.isNotEmpty) {
        req.fields['attributes'] = jsonEncode(attributes);
      }

      if (image != null) {
        final coverCompressed = await ImageManager.compressFile(image);
        req.files.add(
          await http.MultipartFile.fromPath(
            'image',
            coverCompressed.path,
            filename: p.basename(coverCompressed.path),
          ),
        );
      }

      final toCompress = newFiles ?? const <File>[];
      if (toCompress.isNotEmpty) {
        final galleryCompressed = await ImageManager.compressAll(toCompress);
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
      final body = await res.stream.bytesToString(); // ✅ helpful debug

      if (res.statusCode >= 200 && res.statusCode < 300) {
        state = const AsyncData(null);
        return true;
      } else {
        state = AsyncError(
          'Failed: ${res.statusCode} $body',
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
