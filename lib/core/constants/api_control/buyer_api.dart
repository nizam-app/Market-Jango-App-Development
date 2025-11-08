import 'global_api.dart';

class BuyerAPIController {
  static String _base_api = "$api/api";
  static String buyer_product = "$_base_api/product";
  static String banner = "$_base_api/banner";
  static String cart = "$_base_api/cart";
  static String cart_create = "$_base_api/cart/create";
  static String category = "$_base_api/category";
  static String language = "$_base_api/language";
  static String user_update = "$_base_api/user/update";
  static String invoice_createate = "$_base_api/invoice/create";
  static String just_for_you = "$_base_api/admin-selects/just-for-you";
  static String top_products = "$_base_api/admin-selects/top-products";
  static String new_items = "$_base_api/admin-selects/new-items";
  static String buyer_search_product(name) =>
      "$_base_api/search/product?name=$name";
}
