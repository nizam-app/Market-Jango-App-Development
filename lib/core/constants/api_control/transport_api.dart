import 'global_api.dart';

class TransportAPIController {
  static String _base_api = "$api/api";
  static String approved_driver = "$_base_api/approved-driver";
  static String all_order_transport = "$_base_api/all-order/transport";
  static String transport_invoice_create(int driverId) =>
      "$_base_api/transport/invoice/create/$driverId";
}
