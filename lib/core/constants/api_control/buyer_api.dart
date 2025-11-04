import 'global_api.dart';

class BuyerAPIController {
  static String _base_api = "$api/api";
  static String buyer_product = "$_base_api/product";
  static String banner = "$_base_api/banner";
  static String cart = "$_base_api/cart";
  static String top_products ="$_base_api/admin-selects/top-products";
  static String buyer_search_product(name) =>
      "$_base_api/search/product?name=$name";
}