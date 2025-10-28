import 'global_api.dart';

class VendorAPIController {
  static String _base_api = "$api/api";
  static String vendor_product = "$_base_api/vendor/product";
  static String product_update = "$_base_api/product/update";
  static String product_attribute_vendor =
      "$_base_api/product-attribute/vendor";
  static String vendor_category = "$_base_api/vendor/category";
  static String vendor_category_product_filter =
      "$_base_api/vendor/category/product";
}