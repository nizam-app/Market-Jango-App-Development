import 'global_api.dart';

class VendorAPIController {
  static String _base_api = "$api/api";
  static String vendor_product = "$_base_api/vendor/product";
  static String product_update (int id) => "$_base_api/product/update/$id";
  static String product_attribute_vendor =
      "$_base_api/product-attribute/vendor";
  static String vendor_category = "$_base_api/vendor/category";
  static String vendor_category_product_filter = "$_base_api/vendor/category/product";
  static String product_create = "$_base_api/product/create";
  static String category_create = "$_base_api/category/create";
  static String productImageDelete(int id) => '$_base_api/vendor/image/destroy/$id';
  static String search_by_vendor(query) => '$_base_api/vendor/search-by-vendor?query=$query';
  static String user_update = '$_base_api/user/update';
  static String approved_driver = '$_base_api/approved-driver';
  // static String product_attribute_vendor = '$_base_api/product-attribute/vendor';

  static String vendorCompleteOrder({int page = 1}) =>
  "$_base_api/vendor/all/order?page=$page";

}