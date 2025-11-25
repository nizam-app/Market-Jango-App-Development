import 'global_api.dart';

class DriverAPIController {
  static String _base_api = "$api/api";
  static String newOrders({int page = 1}) =>
      '$_base_api/new-order/driver?page=$page';
  static String allOrders({required int page}) =>
      '$_base_api/all-order/driver?page=$page';
  static String invoiceTracking = '$_base_api/driver/invoice/tracking';
}
