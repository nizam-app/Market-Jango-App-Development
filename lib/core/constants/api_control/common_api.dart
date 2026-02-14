import 'global_api.dart';

class CommonAPIController {
  static String _base_api = "$api/api";
  static String translations = "$_base_api/translations";

  /// Subscription (Vendor & Driver)
  static String subscriptionPlans = "$_base_api/subscription/plans";
  static String subscriptionCurrent = "$_base_api/subscription/current";
  static String subscriptionSubscribe = "$_base_api/subscription/subscribe";
}
