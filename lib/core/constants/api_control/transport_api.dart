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
}
