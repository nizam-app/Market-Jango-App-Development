import 'global_api.dart';

class VendorAPIController {
  static final String _base_api = "$api/api";
  static String vendor_product = "$_base_api/vendor/product";
  static String product_update(int id) => "$_base_api/product/update/$id";
  static String product_attribute_vendor =
      "$_base_api/product-attribute/vendor";
  static String vendor_category = "$_base_api/vendor-dashboard/categories";
  static String vendor_category_product_filter =
      "$_base_api/vendor/category/product";
  static String product_create = "$_base_api/product/create";
  static String category_create = "$_base_api/category/create";
  static String productImageDelete(int id) =>
      '$_base_api/vendor/image/destroy/$id';
  static String search_by_vendor(query) =>
      '$_base_api/vendor/search-by-vendor?query=$query';
  static String user_update = '$_base_api/user/update';
  static String approved_driver = '$_base_api/approved-driver';
  // static String product_attribute_vendor = '$_base_api/product-attribute/vendor';

  static String vendorCompleteOrder({int page = 1}) =>
      "$_base_api/vendor/all/order?page=$page";
  static String product_attribute_vendor_show =
      '$_base_api/product-attribute/vendor/show';
  static String attribute_value_create = '$_base_api/attribute-value/create';
  static String attribute_value_update = '$_base_api/attribute-value/update';
  static String attribute_value_destroy = '$_base_api/attribute-value/destroy';
  static String product_attribute_create = '$_base_api/product-attribute/create';
  static String product_attribute_update(int id) => '$_base_api/product-attribute/update/$id';
  static String product_attribute_destroy(int id) => '$_base_api/product-attribute/destroy/$id';
  static String product_destroy = '$_base_api/product/destroy';
  // static String vendor_order_driver = '$_base_api/vendor/pending/order';
  static String vendor_order_driver = '$_base_api/vendor/all/order';
  static String vendorInvoiceCreate(int driverId, int orderItemId) =>
      '$_base_api/vendor/invoice/create/$driverId/$orderItemId';

  static String vendor_income_update(day) =>
      '$_base_api/vendor/income/update?days=$day';
  static String weekly_sell = '$_base_api/vendor/weekly-sell';
  static String sell_top_product = '$_base_api/vendor/sell-top-product';

  /// Product Visibility (Vendor)
  static String productVisibilitySet = '$_base_api/product-visibility/set';
  static String productVisibilityProduct(int productId) =>
      '$_base_api/product-visibility/product/$productId';
  static String productVisibilityVendor = '$_base_api/product-visibility/vendor';
  static String productVisibilityUpdate(int id) =>
      '$_base_api/product-visibility/$id';
  static String productVisibilityDelete(int id) =>
      '$_base_api/product-visibility/$id';
  static String vendorDashboardVisibility =
      '$_base_api/vendor-dashboard/visibility';
}
