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
  static String product_detail(int id) => "$_base_api/product/detail/$id";
  static String vendor_list(id) => "$_base_api/vendor/list/$id";
  static String categoryVendorProducts(int vendorId, {int page = 1}) =>
      "$_base_api/category/vendor/product/$vendorId?page=$page";

  // static Uri _u(String path) => Uri.parse(_base_api).resolve(path);
  static String paymen_tresponse = "$_base_api/payment/response";
  static String invoice_tracking(oderId) =>
      "$_base_api/invoice/tracking/$oderId";
  static String all_order = "$_base_api/buyer/all-order";
  static String popular_product(id) => "$_base_api/popular/product/$id";
  static String vendor_first_product = "$_base_api/vendor/first/product";
  static String vendor_search(name) => "$_base_api/vendor/search/?name=$name";
  static String buyer_tracking_details(int id) =>
      "$_base_api/buyer/invoice/tracking/details/$id";

  static String buyer_search_product(name) =>
      "$_base_api/search/product?name=$name";
  static String review_buyer(id) => "$_base_api/review/create/buyer/$id";
  static String review_vendor(id) => "$_base_api/review/vendor/$id";
}

// lib/core/constants/api_control/buyer_api.dart
class BuyerPaymentAPIController {
  static const String invoice_createate =
      'http://103.208.183.253:8000/api/invoice/create';

  // ✅ নতুন: payment verify/callback endpoint (GET)
  static final Uri paymentResponse = Uri.parse(
    'http://103.208.183.253:8000/api/payment/response',
  );
}
