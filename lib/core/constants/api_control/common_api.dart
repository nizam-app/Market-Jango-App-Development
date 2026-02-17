import 'global_api.dart';

class CommonAPIController {
  static final String _base_api = "$api/api";
  static String translations = "$_base_api/translations";

  /// Subscription (Vendor & Driver)
  static String subscriptionPlans = "$_base_api/subscription/plans";
  static String subscriptionCurrent = "$_base_api/subscription/current";
  static String subscriptionSubscribe = "$_base_api/subscription/subscribe";
  static String subscriptionInitiatePayment =
      "$_base_api/subscription/initiate-payment";
  static String subscriptionConfirmPayment =
      "$_base_api/subscription/confirm-payment";

  /// Affiliate (Vendor & Driver)
  static String affiliateGenerate = '$_base_api/affiliate/generate';
  static String affiliateLinks = '$_base_api/affiliate/links';
  static String affiliateLink(int id) => '$_base_api/affiliate/link/$id';
  static String affiliateClick(String linkCode) =>
      '$_base_api/affiliate/click/$linkCode';
  static String affiliateConversion(String linkCode) =>
      '$_base_api/affiliate/conversion/$linkCode';
  static String affiliateStatistics = '$_base_api/affiliate/statistics';

  /// Ranking (Buyer, Vendor, Driver)
  static String rankingVendors = '$_base_api/ranking/vendors';
  static String rankingDrivers = '$_base_api/ranking/drivers';
  static String rankingMe = '$_base_api/ranking/me';
}
