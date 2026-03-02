/// Single affiliate link (list item or detail).
class AffiliateLinkModel {
  final int id;
  final int? userId;
  final String linkCode;
  final String? name;
  final String? description;
  final String? destinationUrl;
  final int clicks;
  final int conversions;
  final String revenue;
  final String conversionRate;
  final String status;
  final String? expiresAt;
  final String? createdAt;
  final int? totalClicks;
  final int? totalConversions;

  const AffiliateLinkModel({
    required this.id,
    this.userId,
    required this.linkCode,
    this.name,
    this.description,
    this.destinationUrl,
    this.clicks = 0,
    this.conversions = 0,
    this.revenue = '0.00',
    this.conversionRate = '0.00',
    this.status = 'active',
    this.expiresAt,
    this.createdAt,
    this.totalClicks,
    this.totalConversions,
  });

  String get displayName => name?.trim().isNotEmpty == true ? name! : 'Link $linkCode';

  factory AffiliateLinkModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, {int def = 0}) {
      if (v == null) return def;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? def;
    }

    return AffiliateLinkModel(
      id: toInt(json['id']),
      userId: json['user_id'] != null ? toInt(json['user_id']) : null,
      linkCode: json['link_code']?.toString() ?? '',
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      destinationUrl: json['destination_url']?.toString(),
      clicks: toInt(json['clicks']),
      conversions: toInt(json['conversions']),
      revenue: json['revenue']?.toString() ?? '0.00',
      conversionRate: json['conversion_rate']?.toString() ?? '0.00',
      status: json['status']?.toString() ?? 'active',
      expiresAt: json['expires_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      totalClicks: json['total_clicks'] != null ? toInt(json['total_clicks']) : null,
      totalConversions: json['total_conversions'] != null ? toInt(json['total_conversions']) : null,
    );
  }

  Map<String, dynamic> toUpdateBody({String? name, String? status, String? destinationUrl}) {
    final m = <String, dynamic>{};
    if (name != null) m['name'] = name;
    if (status != null) m['status'] = status;
    if (destinationUrl != null) m['destination_url'] = destinationUrl;
    return m;
  }
}

/// Response from GET /api/affiliate/statistics
class AffiliateStatisticsModel {
  final int totalLinks;
  final int activeLinks;
  final int totalClicks;
  final int totalConversions;
  final String totalRevenue;
  final double overallConversionRate;
  final int clicksToday;
  final int conversionsToday;
  final List<AffiliateLinkModel> topLinks;

  const AffiliateStatisticsModel({
    required this.totalLinks,
    required this.activeLinks,
    required this.totalClicks,
    required this.totalConversions,
    required this.totalRevenue,
    required this.overallConversionRate,
    required this.clicksToday,
    required this.conversionsToday,
    required this.topLinks,
  });

  factory AffiliateStatisticsModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, {int def = 0}) {
      if (v == null) return def;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? def;
    }

    double toDouble(dynamic v, {double def = 0}) {
      if (v == null) return def;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? def;
    }

    final stats = json['statistics'] as Map<String, dynamic>? ?? {};
    final topList = json['top_links'] as List<dynamic>? ?? [];

    return AffiliateStatisticsModel(
      totalLinks: toInt(stats['total_links']),
      activeLinks: toInt(stats['active_links']),
      totalClicks: toInt(stats['total_clicks']),
      totalConversions: toInt(stats['total_conversions']),
      totalRevenue: stats['total_revenue']?.toString() ?? '0.00',
      overallConversionRate: toDouble(stats['overall_conversion_rate']),
      clicksToday: toInt(stats['clicks_today']),
      conversionsToday: toInt(stats['conversions_today']),
      topLinks: topList
          .whereType<Map<String, dynamic>>()
          .map(AffiliateLinkModel.fromJson)
          .toList(),
    );
  }
}

/// Response from GET /api/affiliate/link/{id} (details + full_url)
class AffiliateLinkDetailModel {
  final AffiliateLinkModel affiliateLink;
  final String fullUrl;
  final AffiliateLinkStatistics? statistics;

  const AffiliateLinkDetailModel({
    required this.affiliateLink,
    required this.fullUrl,
    this.statistics,
  });

  factory AffiliateLinkDetailModel.fromJson(Map<String, dynamic> json) {
    final link = json['affiliate_link'];
    final stats = json['statistics'];

    return AffiliateLinkDetailModel(
      affiliateLink: AffiliateLinkModel.fromJson(
        link is Map<String, dynamic> ? link : <String, dynamic>{},
      ),
      fullUrl: json['full_url']?.toString() ?? '',
      statistics: stats is Map<String, dynamic>
          ? AffiliateLinkStatistics.fromJson(stats)
          : null,
    );
  }
}

class AffiliateLinkStatistics {
  final int totalClicks;
  final int totalConversions;
  final String conversionRate;
  final String totalRevenue;
  final int clicksToday;
  final int conversionsToday;

  const AffiliateLinkStatistics({
    required this.totalClicks,
    required this.totalConversions,
    required this.conversionRate,
    required this.totalRevenue,
    required this.clicksToday,
    required this.conversionsToday,
  });

  factory AffiliateLinkStatistics.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, {int def = 0}) {
      if (v == null) return def;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? def;
    }

    return AffiliateLinkStatistics(
      totalClicks: toInt(json['total_clicks']),
      totalConversions: toInt(json['total_conversions']),
      conversionRate: json['conversion_rate']?.toString() ?? '0.00',
      totalRevenue: json['total_revenue']?.toString() ?? '0.00',
      clicksToday: toInt(json['clicks_today']),
      conversionsToday: toInt(json['conversions_today']),
    );
  }
}

/// Single item from GET /api/vendor-dashboard/influencer-referral-links
class InfluencerReferralLinkModel {
  final int id;
  final String referralLink;
  final String linkCode;
  final String influencerName;
  final String influencerEmail;
  final String? affiliateCode;
  final int clicks;
  final int conversions;
  final num earnings;
  final int totalConversion;
  final num totalEarnings;
  final bool vendorApproved;
  final String status;
  final String createdAt;
  final String? image;

  const InfluencerReferralLinkModel({
    required this.id,
    required this.referralLink,
    required this.linkCode,
    required this.influencerName,
    required this.influencerEmail,
    this.affiliateCode,
    this.clicks = 0,
    this.conversions = 0,
    this.earnings = 0,
    this.totalConversion = 0,
    this.totalEarnings = 0,
    this.vendorApproved = false,
    this.status = 'active',
    required this.createdAt,
    this.image,
  });

  factory InfluencerReferralLinkModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, [int def = 0]) {
      if (v == null) return def;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? def;
    }

    num toNum(dynamic v, [num def = 0]) {
      if (v == null) return def;
      if (v is num) return v;
      return num.tryParse(v.toString()) ?? def;
    }

    return InfluencerReferralLinkModel(
      id: toInt(json['id']),
      referralLink: json['referral_link']?.toString() ?? '',
      linkCode: json['link_code']?.toString() ?? '',
      influencerName: json['influencer_name']?.toString() ?? '',
      influencerEmail: json['influencer_email']?.toString() ?? '',
      affiliateCode: json['affiliate_code']?.toString(),
      clicks: toInt(json['clicks']),
      conversions: toInt(json['conversions']),
      earnings: toNum(json['earnings']),
      totalConversion: toInt(json['total_conversion']),
      totalEarnings: toNum(json['total_earnings']),
      vendorApproved: json['vendor_approved'] == true,
      status: json['status']?.toString() ?? 'active',
      createdAt: json['created_at']?.toString() ?? '',
      image: json['image']?.toString(),
    );
  }
}
