import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final createProductProvider =
StateNotifierProvider<CreateProductNotifier, AsyncValue<String>>(
      (ref) => CreateProductNotifier(),
);

class CreateProductNotifier extends StateNotifier<AsyncValue<String>> {
  CreateProductNotifier() : super(const AsyncData(''));

  Future<void> createProduct({
    required String name,
    required String description,
    required String regularPrice,
    required String sellPrice,
    required int categoryId,
    required String color,
    required String size,
    required File image,
    required List<File> files,
  }) async {
    try {
      state = const AsyncLoading(); // show loading state

      final uri = Uri.parse("https://yourapi.com/api/product/create");
      final request = http.MultipartRequest('POST', uri);

      // Text fields
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['regular_price'] = regularPrice;
      request.fields['sell_price'] = sellPrice;
      request.fields['category_id'] = categoryId.toString();
      request.fields['color'] = color;
      request.fields['size'] = size;

      // 🖼️ Main Image
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      // 🖼️ Multiple Gallery Images
      for (final file in files) {
        request.files.add(await http.MultipartFile.fromPath('files[]', file.path));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        state = const AsyncData("✅ Product created successfully!");
      } else {
        state = AsyncError(
            "❌ Failed: ${response.statusCode} ${response.reasonPhrase}",
            StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncError("❌ Exception: $e", st);
    }
  }
}