// lib/features/vendor/screens/product_edit/logic/update_product_provider.dart
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:market_jango/core/constants/api_control/vendor_api.dart';

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
    String? currentPrice,  // API: current_price
    int? categoryId,
    List<String>? colors,  // API: color[]
    List<String>? sizes,   // API: size[]
    File? image,           // API: image (main)
    List<File>? newFiles,  // API: files[] (gallery additions)
  }) async {
    try {
      state = const AsyncLoading();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final uri = Uri.parse(
        VendorAPIController.product_update(id),
      );

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
        req.files.add(await http.MultipartFile.fromPath('image', coverCompressed.path));
      }

      List<File> galleryCompressed = [];
      final toCompress = newFiles ?? const <File>[];

      if (toCompress.isNotEmpty) {
        galleryCompressed = await ImageManager.compressAll(toCompress);
        for (final f in galleryCompressed) {
          // 🔧 filename পাঠানো খুব গুরুত্বপূর্ণ
          req.files.add(await http.MultipartFile.fromPath(
            'files[]',          
            f.path,
            filename: p.basename(f.path),

          ));
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





class ImageManager {
  /// Single file compress (jpeg out). Falls back to original on failure.
  static Future<File> compressFile(
      File file, {
        int quality = 70,
        int minWidth = 1280,
        int minHeight = 1280,
      }) async {
    try {
      // ছোট হলে compress না করলেও চলে (যেমন <300KB)
      final size = await file.length();
      if (size < 300 * 1024) return file;

      final tmpDir = await getTemporaryDirectory();
      final targetPath = p.join(
        tmpDir.path,
        'cmp_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        // HEIC/PNG এলেও আউটপুট JPEG করব — সার্ভার ফ্রেন্ডলি
        format: CompressFormat.jpeg,
      );

      return result != null ? File(result.path) : file;
    } catch (_) {
      return file;
    }
  }

  /// Multiple files compress
  static Future<List<File>> compressAll(
      List<File> files, {
        int quality = 70,
        int minWidth = 1280,
        int minHeight = 1280,
      }) async {
    final out = <File>[];
    for (final f in files) {
      out.add(await compressFile(
        f,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
      ));
    }
    return out;
  }

  /// Optional: temp ফাইল পরিষ্কার করা
  static Future<void> safeDeleteTempFiles(Iterable<File> files) async {
    for (final f in files) {
      try {
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }
}