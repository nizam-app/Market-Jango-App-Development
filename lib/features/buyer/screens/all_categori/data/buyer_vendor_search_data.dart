import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/buyer/screens/all_categori/model/buyer_vendor_search_model.dart';

final vendorSearchProvider = FutureProvider.autoDispose
    .family<VendorSearchResponse, String>((ref, name) async {
      if (name.trim().isEmpty) return VendorSearchResponse.empty();

      final token = await ref.read(authTokenProvider.future);
      if (token == null) throw Exception('Token not found');

      final url = BuyerAPIController.vendor_search(name);

      final resp = await http.get(Uri.parse(url), headers: {'token': token});
      if (resp.statusCode != 200) {
        throw Exception(
          'Vendor search failed: ${resp.statusCode} ${resp.body}',
        );
      }
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      return VendorSearchResponse.fromJson(body);
    });
