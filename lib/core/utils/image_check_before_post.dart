import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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