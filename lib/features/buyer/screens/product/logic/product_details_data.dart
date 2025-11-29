
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/buyer/screens/product/model/product_all_details_model.dart';

class ProductDetailApi {
  static Future<DetailItem> fetchById(Ref ref, int id) async {
    final token = await ref.read(authTokenProvider.future);
    final uri = Uri.parse(BuyerAPIController.product_detail(id));

    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'token': token,
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Fetch failed: ${res.statusCode} ${res.reasonPhrase}');
    }

    final Map<String, dynamic> map = jsonDecode(res.body);
    final data = map['data'] as Map<String, dynamic>?;   
    if (data == null) {
      throw Exception('No data field in response');
    }

    return DetailItem.fromJson(data);
  }
}


final productDetailsProvider =
FutureProvider.family<DetailItem, int>((ref, id) => ProductDetailApi.fetchById(ref, id));