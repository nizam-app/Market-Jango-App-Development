import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/model/buyer_vendor_propuler_product_model.dart';

final popularProductsProvider =
    AsyncNotifierProviderFamily<
      PopularProductsNotifier,
      PopularProductsResponse?,
      int
    >(PopularProductsNotifier.new);

class PopularProductsNotifier
    extends FamilyAsyncNotifier<PopularProductsResponse?, int> {
  @override
  Future<PopularProductsResponse?> build(int vendorId) async {
    return _fetch(vendorId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }

  Future<PopularProductsResponse> _fetch(int vendorId) async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null) throw Exception('Token not found');

    // Add this helper in your BuyerAPIController if not present.
    final url = BuyerAPIController.popular_product(vendorId);
    final res = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json', 'token': token},
    );

    if (res.statusCode != 200) {
      throw Exception('Popular fetch failed: ${res.statusCode} ${res.body}');
    }
    return popularProductsResponseFromJson(res.body);
  }
}
