import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/new_items_model.dart';

class BuyerNewItemsRepository {
  final String baseUrl;
  final String token;

  BuyerNewItemsRepository({
    required this.baseUrl,
    required this.token,
  });

  Future<BuyerNewItemsModel> fetchBuyerNewItems({int page = 1}) async {
    final url = Uri.parse('$baseUrl');

    final response = await http.get(
      url,
      headers: {

        'token':  token,        }
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return BuyerNewItemsModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load new items. Status: ${response.statusCode}');
    }
  }
}