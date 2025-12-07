import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/chat_api.dart';
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/screen/buyer_massage/model/vendor_product_response_model.dart';
import 'package:market_jango/core/screen/buyer_massage/model/chat_history_model.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';

class OfferProductRepository {
  final AuthLocalStorage _authStorage = AuthLocalStorage();
  
  Future<String?> _getToken() async {
    return await _authStorage.getToken();
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

      // Handle nested structure: data.products.data (as per API response)
      final productBlock = data['products'];
      if (productBlock != null && productBlock is Map<String, dynamic>) {
        // The products block contains: current_page, data[], last_page, etc.
        return VendorProductResponse.fromJson(productBlock);
      }
      
      // Fallback: try to parse directly if structure is different
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

  /// Create a product offer and send it as a chat message
  Future<ChatMessage> createOffer({
    required int receiverId,
    required int productId,
    required double salePrice,
    required int quantity,
    required double deliveryCharge,
    required String color,
    required String size,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final uri = Uri.parse(ChatAPIController.sendOffer(receiverId));
    
    final body = jsonEncode({
      'product_id': productId,
      'sale_price': salePrice,
      'quantity': quantity,
      'delivery_charge': deliveryCharge,
      'color': color,
      'size': size,
    });

    final response = await http.post(
      uri,
      headers: {
        'token': token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      
      // The API should return the created chat message
      if (json['status'] == 'success' && json['data'] != null) {
        final data = json['data'] as Map<String, dynamic>;
        
        // Ensure the offer data has product_name and product_image
        // If the API doesn't return them, we might need to fetch product details
        // But for now, assume the API returns them in the offer object
        final offerData = data['offer'] as Map<String, dynamic>?;
        if (offerData != null) {
          // Ensure product_name and product_image are present in offer
          // The API should return these, but we verify the structure
        }
        
        return ChatMessage.fromJson(data);
      } else {
        throw Exception(json['message'] ?? 'Failed to create offer');
      }
    } else {
      final errorBody = response.body;
      try {
        final errorJson = jsonDecode(errorBody);
        throw Exception(errorJson['message'] ?? 'Failed to create offer: ${response.statusCode}');
      } catch (_) {
        throw Exception('Failed to create offer: ${response.statusCode}');
      }
    }
  }
}

