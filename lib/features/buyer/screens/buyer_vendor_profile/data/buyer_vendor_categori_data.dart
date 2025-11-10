// providers/vendor_category_products_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/model/buyer_vendor_category_model.dart';


final vendorCatArgsProvider = Provider.family<_VArgs, int>((ref, vendorId) {
  return _VArgs(vendorId: vendorId);
});

class _VArgs {
  final int vendorId;
  const _VArgs({required this.vendorId});
}

final vendorCategoryProductsProvider = AutoDisposeAsyncNotifierProviderFamily<
    VendorCategoryProductsNotifier,
    VendorCategoryProductsResponse?,
    int>(VendorCategoryProductsNotifier.new);

class VendorCategoryProductsNotifier
    extends AutoDisposeFamilyAsyncNotifier<VendorCategoryProductsResponse?, int> {
  int _page = 1;

  @override
  Future<VendorCategoryProductsResponse?> build(int vendorId) async {
    _page = 1;
    return _fetch(vendorId, _page);
  }

  Future<void> changePage(int page) async {
    if (page < 1) return;
    _page = page;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(arg, _page));
  }

  int get currentPage =>
      state.value?.data.categories.currentPage ?? 1;
  int get lastPage =>
      state.value?.data.categories.lastPage ?? 1;

  Future<VendorCategoryProductsResponse> _fetch(int vendorId, int page) async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null) {
      throw Exception('Auth token not found');
    }
    final url = BuyerAPIController.categoryVendorProducts(vendorId, page: page);
    final res = await http.get(Uri.parse(url), headers: {'token': token});
    if (res.statusCode != 200) {
      throw Exception('Failed: ${res.statusCode} ${res.body}');
    }
    return vendorCategoryProductsResponseFromJson(res.body);
  }
}