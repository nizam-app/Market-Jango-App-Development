import 'global_api.dart';

class VendorAPIController {
  static final String _base_api = "$api/api";
  static String vendor_product = "$_base_api/vendor/product";
  static String vendor_product_reorder = "$_base_api/vendor/product/reorder";
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

  /// Vendor Route Points (delivery setting) – GET list, POST opt-in, DELETE opt-out
  static String get vendor_route_points => '$_base_api/vendor/route-points';
  static String vendorRoutePoints({String? search, int page = 1}) {
    final buf = StringBuffer('$_base_api/vendor/route-points');
    final params = <String>[];
    if (search != null && search.trim().isNotEmpty) {
      params.add('search=${Uri.encodeComponent(search.trim())}');
    }
    params.add('page=$page');
    return '$buf?${params.join('&')}';
  }
  static String vendorRoutePointsDelete(int id) =>
      '$_base_api/vendor/route-points/$id';

  // --- Order management (see doc/VENDOR_ORDER_MANAGEMENT_AND_BILLING.md) ---

  /// Paginated marketplace line items for this vendor (`invoice_items`).
  static String vendorOrders({
    int page = 1,
    int perPage = 10,
    String? fromDate,
    String? toDate,
    String? orderNumber,
    String? status,
  }) {
    final q = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
    };
    if (fromDate != null && fromDate.isNotEmpty) q['from_date'] = fromDate;
    if (toDate != null && toDate.isNotEmpty) q['to_date'] = toDate;
    if (orderNumber != null && orderNumber.trim().isNotEmpty) {
      q['order_number'] = orderNumber.trim();
    }
    if (status != null && status.trim().isNotEmpty) q['status'] = status.trim();
    return Uri.parse('$_base_api/vendor/orders').replace(queryParameters: q).toString();
  }

  static String vendorOrderDetail(int invoiceItemId) =>
      '$_base_api/vendor/orders/$invoiceItemId';

  static String vendorOrderUpdateStatus(int invoiceItemId) =>
      '$_base_api/vendor/orders/$invoiceItemId/status';

  static String get vendorOrderStatuses => '$_base_api/vendor/orders/statuses';

  /// Manual / walk-in orders (paginated invoices).
  static String vendorManualOrders({
    int page = 1,
    int perPage = 10,
    String? fromDate,
    String? toDate,
    String? orderNumber,
    String? status,
  }) {
    final q = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
    };
    if (fromDate != null && fromDate.isNotEmpty) q['from_date'] = fromDate;
    if (toDate != null && toDate.isNotEmpty) q['to_date'] = toDate;
    if (orderNumber != null && orderNumber.trim().isNotEmpty) {
      q['order_number'] = orderNumber.trim();
    }
    if (status != null && status.trim().isNotEmpty) q['status'] = status.trim();
    return Uri.parse('$_base_api/vendor/manual-orders')
        .replace(queryParameters: q)
        .toString();
  }

  static String vendorManualOrderDetail(int invoiceId) =>
      '$_base_api/vendor/manual-orders/$invoiceId';

  static String get vendorManualOrderCreate => '$_base_api/vendor/manual-orders';

  static String vendorManualOrderAddItem(int invoiceId) =>
      '$_base_api/vendor/manual-orders/$invoiceId/items';

  static String vendorManualOrderDeleteItem(int invoiceId, int itemId) =>
      '$_base_api/vendor/manual-orders/$invoiceId/items/$itemId';

  static String vendorManualOrderDeliver(int invoiceId) =>
      '$_base_api/vendor/manual-orders/$invoiceId/deliver';

  /// Wallet (vendor)
  static String get vendorWallet => '$_base_api/vendor/wallet';

  static String vendorWalletTransactions({
    int page = 1,
    int perPage = 15,
    String? fromDate,
    String? toDate,
    String? type,
    String? status,
  }) {
    final q = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
    };
    if (fromDate != null && fromDate.isNotEmpty) q['from_date'] = fromDate;
    if (toDate != null && toDate.isNotEmpty) q['to_date'] = toDate;
    if (type != null && type.trim().isNotEmpty) q['type'] = type.trim();
    if (status != null && status.trim().isNotEmpty) q['status'] = status.trim();
    return Uri.parse('$_base_api/vendor/wallet/transactions')
        .replace(queryParameters: q)
        .toString();
  }

  static String get vendorWalletPayout => '$_base_api/vendor/wallet/payout';

  /// Paginated payout requests; optional `status` filter.
  static String vendorWalletPayouts({int page = 1, String? status}) {
    final q = <String, String>{'page': '$page'};
    if (status != null && status.trim().isNotEmpty) {
      q['status'] = status.trim();
    }
    return Uri.parse('$_base_api/vendor/wallet/payouts')
        .replace(queryParameters: q)
        .toString();
  }

  /// Refunds list + summary — see doc/VENDOR_WALLET_AND_REFUND_API.md §5.2
  static String vendorRefunds({
    int page = 1,
    String? status,
    String? fromDate,
    String? toDate,
  }) {
    final q = <String, String>{'page': '$page'};
    if (status != null && status.trim().isNotEmpty) q['status'] = status.trim();
    if (fromDate != null && fromDate.isNotEmpty) q['from_date'] = fromDate;
    if (toDate != null && toDate.isNotEmpty) q['to_date'] = toDate;
    return Uri.parse('$_base_api/vendor/refunds')
        .replace(queryParameters: q)
        .toString();
  }

  static String vendorRefundDetail(int id) => '$_base_api/vendor/refunds/$id';

  static String vendorRefundApprove(int id) =>
      '$_base_api/vendor/refunds/$id/approve';

  static String vendorRefundReject(int id) =>
      '$_base_api/vendor/refunds/$id/reject';

  /// `item_id` = invoice line id (same as marketplace order detail).
  static String vendorOrderLineRefund(int invoiceItemId) =>
      '$_base_api/vendor/orders/$invoiceItemId/refund';

  // --- Barcodes (see doc/VENDOR_BARCODE_AND_SCANNER_API.md) ---

  /// Paginated active products with barcode payload (20/page); empty barcodes may be auto-filled.
  static String vendorProductBarcodes({String? search, int page = 1}) {
    final buf = StringBuffer('$_base_api/vendor/products/barcodes');
    final params = <String>[];
    if (search != null && search.trim().isNotEmpty) {
      params.add('search=${Uri.encodeComponent(search.trim())}');
    }
    params.add('page=$page');
    return '$buf?${params.join('&')}';
  }

  /// Scanner lookup — [code] must be path-encoded (slashes, #, spaces, etc.).
  static String vendorProductBarcodeScan(String code) {
    final enc = Uri.encodeComponent(code);
    return '$_base_api/vendor/products/barcode/$enc';
  }

  static String vendorProductBarcodeByProductId(int productId) =>
      '$_base_api/vendor/products/$productId/barcode';

  static String vendorProductBarcodeRegenerate(int productId) =>
      '$_base_api/vendor/products/$productId/barcode/regenerate';

  static String vendorProductBarcodeLabels(int productId) =>
      '$_base_api/vendor/products/$productId/barcode/labels';
}
