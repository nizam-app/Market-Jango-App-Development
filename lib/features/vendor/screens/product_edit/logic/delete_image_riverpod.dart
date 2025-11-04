// lib/features/vendor/screens/product_edit/logic/repo.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:market_jango/core/constants/api_control/vendor_api.dart';

class ProductRepo {
  Future<void> deleteImage(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final uri = Uri.parse(
        VendorAPIController.productImageDelete(id));
    
    final res = await http.post(uri, headers: {
      if (token != null) 'token': token,
      'Accept': 'application/json',
    });

    if (res.statusCode != 200) {
      throw HttpException('Delete failed: ${res.statusCode} ${res.body}');
    }
  }
}



final productRepoProvider = Provider<ProductRepo>((_) => ProductRepo());

final deleteProductImageProvider =
StateNotifierProvider<DeleteProductImageNotifier, AsyncValue<void>>((ref) {
  // autoDispose চাইলে .autoDispose ব্যবহার করুন, কিন্তু অবশ্যই keepAlive কল করবেন
  // final link = ref.keepAlive();
  return DeleteProductImageNotifier(ref);
});

class DeleteProductImageNotifier extends StateNotifier<AsyncValue<void>> {
  DeleteProductImageNotifier(this.ref) : super(const AsyncData(null));
  final Ref ref;

  /// true = success, false = failed
  Future<bool> deleteById(int id) async {
    try {
      state = const AsyncLoading();
      await ref.read(productRepoProvider).deleteImage(id);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      Logger().e('delete image failed', error: e, stackTrace: st);
      state = AsyncError(e, st);
      return false;
    }
  }
}