import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:market_jango/core/constants/api_control/chat_api.dart';
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/screen/buyer_massage/model/vendor_product_response_model.dart';

class OfferProductRepository {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Fetch vendor products with pagination and search
  Future<VendorProductResponse> fetchVendorProducts({
    required int page,
    String? search,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    // Build URL with query parameters
    final uri = Uri.parse(VendorAPIController.vendor_product).replace(
      queryParameters: {
        'page': page.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    final response = await http.get(uri, headers: {'token': token});

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'];
      
      if (data == null) {
        return VendorProductResponse(
          products: [],
          currentPage: 1,
          lastPage: 1,
          total: 0,
        );
      }

      // Check if data has products structure
      final productBlock = data['products'];
      if (productBlock != null) {
        return VendorProductResponse.fromJson(productBlock);
      }
      
      // Fallback: try to parse directly
      return VendorProductResponse.fromJson(data);
    } else {
      throw Exception('Failed to fetch products: ${response.statusCode}');
    }
  }

  /// Accept an offer and add it to cart
  Future<void> acceptOffer(int offerId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final uri = Uri.parse(ChatAPIController.acceptOffer(offerId));
    final response = await http.post(
      uri,
      headers: {
        'token': token,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to accept offer: ${response.statusCode}');
    }
  }
}

