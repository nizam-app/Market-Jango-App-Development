import 'global_api.dart';

class DriverAPIController {
  static final String _base_api = "$api/api";
  static String newOrders({int page = 1}) =>
      '$_base_api/new-order/driver?page=$page';
  static String allOrders({required int page}) =>
      '$_base_api/all-order/driver?page=$page';
  static String invoiceTracking = '$_base_api/driver/invoice/tracking';
  static String driver_home_stats = '$_base_api/driver/home-stats';
  static String invoiceUpdateStatus(id) =>
      '$_base_api/driver/invoice/update-status/$id';

  /// Driver wallet — see doc/details.md
  static String get driverWallet => '$_base_api/driver/wallet';

  static String driverWalletTransactions({
    int page = 1,
    int perPage = 20,
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
    if (status != null && status.trim().isNotEmpty) {
      q['status'] = status.trim();
    }
    return Uri.parse('$_base_api/driver/wallet/transactions')
        .replace(queryParameters: q)
        .toString();
  }

  static String get driverWalletPayout => '$_base_api/driver/wallet/payout';

  static String driverWalletPayouts({int page = 1, String? status}) {
    final q = <String, String>{'page': '$page'};
    if (status != null && status.trim().isNotEmpty) {
      q['status'] = status.trim();
    }
    return Uri.parse('$_base_api/driver/wallet/payouts')
        .replace(queryParameters: q)
        .toString();
  }
}
