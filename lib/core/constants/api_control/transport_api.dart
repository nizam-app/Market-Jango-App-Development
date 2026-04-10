import 'global_api.dart';

class TransportAPIController {
  static final String _base_api = "$api/api";
  static String approved_driver = "$_base_api/approved-driver";
  static String all_order_transport = "$_base_api/all-order/transport";
  static String transport_invoice_create(int driverId) =>
      "$_base_api/transport/invoice/create/$driverId";

  /// Shipments: GET list of transport types (motorcycle, car, air, water)
  static String get transportTypes => "$_base_api/shipments/transport-types";

  /// Shipments: GET search transporters; query: transport_type, origin_address, destination_address
  static String get searchTransporters => "$_base_api/shipments/search-transporters";

  /// POST create shipment (draft) with packages
  static String get createShipment => "$_base_api/shipments";

  /// GET single shipment details
  static String shipmentById(int id) => "$_base_api/shipments/$id";

  /// POST pay for shipment
  static String payShipment(int id) => "$_base_api/shipments/$id/pay";

  /// POST initiate payment (returns payment_url for gateway/WebView)
  static String initiateShipmentPayment(int id) =>
      "$_base_api/shipments/$id/initiate-payment";

  // --- Transport wallet (doc/details.md) — `/api/transport/wallet/...` ---
  static String get transportWallet => '$_base_api/transport/wallet';

  static String transportWalletTransactions({
    int page = 1,
    int perPage = 20,
    String? fromDate,
    String? toDate,
    String? type,
    String? status,
  }) {
    final q = <String, String>{'page': '$page', 'per_page': '$perPage'};
    if (fromDate != null && fromDate.isNotEmpty) q['from_date'] = fromDate;
    if (toDate != null && toDate.isNotEmpty) q['to_date'] = toDate;
    if (type != null && type.trim().isNotEmpty) q['type'] = type.trim();
    if (status != null && status.trim().isNotEmpty) {
      q['status'] = status.trim();
    }
    return Uri.parse('$_base_api/transport/wallet/transactions')
        .replace(queryParameters: q)
        .toString();
  }

  static String get transportWalletTopup => '$_base_api/transport/wallet/topup';
  static String get transportWalletPayout => '$_base_api/transport/wallet/payout';

  /// Payout list: backend uses 15 per page by default; `page` is supported.
  static String transportWalletPayouts({int page = 1, String? status}) {
    final q = <String, String>{'page': '$page'};
    if (status != null && status.trim().isNotEmpty) {
      q['status'] = status.trim();
    }
    return Uri.parse('$_base_api/transport/wallet/payouts')
        .replace(queryParameters: q)
        .toString();
  }
}
