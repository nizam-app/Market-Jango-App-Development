import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final createProductProvider =
StateNotifierProvider<CreateProductNotifier, AsyncValue<String>>(
      (ref) => CreateProductNotifier(),
);

class CreateProductNotifier extends StateNotifier<AsyncValue<String>> {
  CreateProductNotifier() : super(const AsyncData(''));
  Future<File> _compress(File input,
      {int maxW = 1280, int maxH = 1280, int quality = 72}) async {
    final tempDir = await getTemporaryDirectory();
    final outPath = p.join(
      tempDir.path,
      '${DateTime.now().millisecondsSinceEpoch}_${p.basenameWithoutExtension(input.path)}.jpg',
    );

    final bytes = await FlutterImageCompress.compressWithFile(
      input.path,
      minWidth: maxW,
      minHeight: maxH,
      quality: quality,                 // 0..100
      format: CompressFormat.jpeg,      // PNG→JPEG
    );

    final out = File(outPath);
    await out.writeAsBytes(bytes ?? []);
    return out;
  }

  Future<void> createProduct({
    required String name,
    required String description,
    required String regularPrice,
    required String sellPrice,
    required int categoryId,
    required List<String> color,
    required List<String> size,
    required File image,
    required List<File> files,
  }) async {
    try {
      state = const AsyncLoading(); // how loading state
      SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
      final token = await _sharedPreferences.getString('auth_token');
      // 🔻 compress (cover + gallery)
      final cover = await _compress(image);
      final gallery = <File>[];
      for (final f in files) {
        gallery.add(await _compress(f));
      }


      final uri = Uri.parse(VendorAPIController.product_create);
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        if (token != null) 'token': '$token',
      });

      
      // Text fields
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['regular_price'] = regularPrice;
      request.fields['sell_price'] = sellPrice;
      request.fields['category_id'] = categoryId.toString();
      request.fields['color'] = color.join(','); // multiple color
      request.fields['size'] = size.join(',');   // multiple size

      // 🖼️ Main Image
      request.files.add(await http.MultipartFile.fromPath('image', cover.path, filename: 'cover.jpg'));
      for (int i = 0; i < gallery.length; i++) {
        final f = gallery[i];
        request.files.add(await http.MultipartFile.fromPath('files[]', f.path, filename: 'g_$i.jpg'));
      }

      final streamed = await request.send().timeout(const Duration(seconds: 60));
      final resp = await http.Response.fromStream(streamed);

      Logger().i('STATUS: ${resp.statusCode}');
      Logger().i('BODY  : ${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final map = jsonDecode(resp.body);
        final msg = (map is Map && map['message'] != null)
            ? map['message'].toString()
            : 'Product created successfully';
        state = AsyncData('✅ $msg');
        return;
      }

      if (resp.statusCode == 413) {
        state = AsyncError(
          '❌ Payload too large (413): ছবি/ফাইল ছোট করে আবার পাঠাও, বা কম সংখ্যক ছবি দাও।',
          StackTrace.current,
        );
        return;
      }

      state = AsyncError(
        '❌ Failed: ${resp.statusCode} ${resp.reasonPhrase}\n${resp.body}',
        StackTrace.current,
      );
    } catch (e, st) {
      state = AsyncError('❌ Exception: $e', st);
    }
  }
}