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

  /// Vendor affiliate links (buyer viewing vendor promotions)
  static String affiliateVendorLinks(int vendorId) =>
      '$_base_api/affiliate/vendor-links/$vendorId';

  /// Driver affiliate links (same structure as vendor, for driver profile)
  static String affiliateDriverLinks(int driverId) =>
      '$_base_api/affiliate/driver-links/$driverId';
  static String affiliateGenerateReferralLink =
      '$_base_api/affiliate/generate-referral-link';
  static String affiliateGenerateReferralLinkDriver =
      '$_base_api/affiliate/generate-referral-link-driver';

  /// GET influencer referral links (vendor dashboard)
  static String get influencerReferralLinks =>
      '$_base_api/vendor-dashboard/influencer-referral-links';

  /// POST approve influencer referral link
  static String influencerApproveLink(int id) =>
      '$_base_api/vendor-dashboard/influencer-referral-links/$id/approve';

  /// DELETE influencer referral link
  static String influencerDeleteLink(int id) =>
      '$_base_api/vendor-dashboard/influencer-referral-links/$id';

  /// GET influencer referral links (driver dashboard) – same structure, data.items
  static String get driverDashboardInfluencerReferralLinks =>
      '$_base_api/driver-dashboard/influencer-referral-links';

  /// POST approve influencer referral link (driver)
  static String driverInfluencerApproveLink(int id) =>
      '$_base_api/driver-dashboard/influencer-referral-links/$id/approve';

  /// DELETE influencer referral link (driver)
  static String driverInfluencerDeleteLink(int id) =>
      '$_base_api/driver-dashboard/influencer-referral-links/$id';

  /// Ranking (Buyer, Vendor, Driver)
  static String rankingVendors = '$_base_api/ranking/vendors';
  static String rankingDrivers = '$_base_api/ranking/drivers';
  static String rankingMe = '$_base_api/ranking/me';

  /// GET supported currencies (code, name, symbol)
  static String get currency => '$_base_api/currency';
}
