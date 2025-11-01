import 'global_api.dart';

class BuyerAPIController {
  static String _base_api = "$api/api";
  static String buyer_product = "$_base_api/product";
  static String buyer_search_product(name) => "$_base_api/search/product?name=$name";


}