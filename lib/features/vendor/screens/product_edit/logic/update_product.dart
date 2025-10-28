import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';

final productUpdateProvider = StateNotifierProvider<ProductUpdateNotifier, AsyncValue<void>>((ref) {
  return ProductUpdateNotifier();
});

class ProductUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  ProductUpdateNotifier() : super(const AsyncData(null));

  Future<void> updateProduct({
    required int id,
    required String name,
    required String description,
    required String price,
    required int categoryId,
    required String color,
    required String size,
    File? mainImage,
    List<File>? extraImages,
  }) async {
    try {
      state = const AsyncLoading();

      final uri = Uri.parse("${VendorAPIController.product_update}/$id");
      final request = http.MultipartRequest("POST", uri);

      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['previous_price'] = "100";
      request.fields['current_price'] = price;
      request.fields['category_id'] = categoryId.toString();
      request.fields['color'] = color;
      request.fields['size'] = size;

      if (mainImage != null) {
        request.files.add(await http.MultipartFile.fromPath("image", mainImage.path));
      }

      if (extraImages != null && extraImages.isNotEmpty) {
        for (final file in extraImages) {
          request.files.add(await http.MultipartFile.fromPath("files[]", file.path));
        }
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        state = const AsyncData(null);
      } else {
        state = AsyncError("Failed to update product", StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}