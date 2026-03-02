import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/common_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/affiliate/model/affiliate_model.dart';

// ---------------------------------------------------------------------------
// Get all affiliate links: GET /api/affiliate/links
// ---------------------------------------------------------------------------

final affiliateLinksProvider =
    AsyncNotifierProvider<AffiliateLinksNotifier, List<AffiliateLinkModel>>(
      AffiliateLinksNotifier.new,
    );

class AffiliateLinksNotifier extends AsyncNotifier<List<AffiliateLinkModel>> {
  @override
  Future<List<AffiliateLinkModel>> build() async => _fetch();

  Future<List<AffiliateLinkModel>> _fetch() async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) throw Exception('Not logged in');

    final uri = Uri.parse(CommonAPIController.affiliateLinks);
    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'token': token},
    );

    if (res.statusCode != 200) {
      final map = jsonDecode(res.body) as Map<String, dynamic>?;
      final msg = map?['message']?.toString() ?? 'Failed to load links';
      throw Exception(msg);
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final data = map['data'];
    if (data is! List) return [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(AffiliateLinkModel.fromJson)
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }
}

// ---------------------------------------------------------------------------
// Get statistics: GET /api/affiliate/statistics
// ---------------------------------------------------------------------------

final affiliateStatisticsProvider =
    AsyncNotifierProvider<
      AffiliateStatisticsNotifier,
      AffiliateStatisticsModel?
    >(AffiliateStatisticsNotifier.new);

class AffiliateStatisticsNotifier
    extends AsyncNotifier<AffiliateStatisticsModel?> {
  @override
  Future<AffiliateStatisticsModel?> build() async => _fetch();

  Future<AffiliateStatisticsModel?> _fetch() async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) throw Exception('Not logged in');

    final uri = Uri.parse(CommonAPIController.affiliateStatistics);
    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'token': token},
    );

    if (res.statusCode != 200) {
      final map = jsonDecode(res.body) as Map<String, dynamic>?;
      final msg = map?['message']?.toString() ?? 'Failed to load statistics';
      throw Exception(msg);
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>?;
    if (data == null) return null;

    return AffiliateStatisticsModel.fromJson(data);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }
}

// ---------------------------------------------------------------------------
// GET influencer referral links: /api/vendor-dashboard/influencer-referral-links
// ---------------------------------------------------------------------------

final influencerReferralLinksProvider =
    AsyncNotifierProvider<InfluencerReferralLinksNotifier, List<InfluencerReferralLinkModel>>(
      InfluencerReferralLinksNotifier.new,
    );

class InfluencerReferralLinksNotifier extends AsyncNotifier<List<InfluencerReferralLinkModel>> {
  @override
  Future<List<InfluencerReferralLinkModel>> build() async => _fetch();

  Future<List<InfluencerReferralLinkModel>> _fetch() async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) throw Exception('Not logged in');

    final uri = Uri.parse(CommonAPIController.influencerReferralLinks);
    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'token': token},
    );

    if (res.statusCode != 200) {
      final map = jsonDecode(res.body) as Map<String, dynamic>?;
      final msg = map?['message']?.toString() ?? 'Failed to load influencer links';
      throw Exception(msg);
    }

    final body = jsonDecode(res.body);
    List<dynamic> list = [];
    if (body is List) {
      list = body;
    } else if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic> && data['items'] is List) {
        list = data['items'] as List;
      }
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map(InfluencerReferralLinkModel.fromJson)
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }
}

// ---------------------------------------------------------------------------
// Get link details: GET /api/affiliate/link/{id}
// ---------------------------------------------------------------------------

final affiliateLinkDetailProvider = FutureProvider.autoDispose
    .family<AffiliateLinkDetailModel?, int>((ref, id) async {
      final token = await ref.watch(authTokenProvider.future);
      if (token == null || token.isEmpty) throw Exception('Not logged in');

      final uri = Uri.parse(CommonAPIController.affiliateLink(id));
      final res = await http.get(
        uri,
        headers: {'Accept': 'application/json', 'token': token},
      );

      if (res.statusCode != 200) {
        final map = jsonDecode(res.body) as Map<String, dynamic>?;
        final msg = map?['message']?.toString() ?? 'Failed to load link';
        throw Exception(msg);
      }

      final map = jsonDecode(res.body) as Map<String, dynamic>;
      final data = map['data'] as Map<String, dynamic>?;
      if (data == null) return null;

      return AffiliateLinkDetailModel.fromJson(data);
    });

// ---------------------------------------------------------------------------
// Generate: POST /api/affiliate/generate
// ---------------------------------------------------------------------------

/// Result of creating an affiliate link; includes the link and the full URL to share.
class AffiliateGenerateResult {
  final AffiliateLinkModel link;
  final String fullUrl;

  const AffiliateGenerateResult({required this.link, required this.fullUrl});
}

Future<AffiliateGenerateResult> affiliateGenerate(
  String? token, {
  String? name,
  String? description,
  String? destinationUrl,
  double? customRate,
  int? cookieDurationDays,
  String? attributionModel,
  String? expiresAt,
}) async {
  if (token == null || token.isEmpty) throw Exception('Not logged in');

  final uri = Uri.parse(CommonAPIController.affiliateGenerate);
  final body = <String, dynamic>{};
  if (name != null && name.isNotEmpty) body['name'] = name;
  if (description != null && description.isNotEmpty)
    body['description'] = description;
  if (destinationUrl != null && destinationUrl.isNotEmpty)
    body['destination_url'] = destinationUrl;
  if (customRate != null) body['custom_rate'] = customRate;
  if (cookieDurationDays != null) body['cookie_duration_days'] = cookieDurationDays;
  if (attributionModel != null && attributionModel.isNotEmpty)
    body['attribution_model'] = attributionModel;
  if (expiresAt != null && expiresAt.isNotEmpty) body['expires_at'] = expiresAt;

  final res = await http.post(
    uri,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'token': token,
    },
    body: jsonEncode(body),
  );

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 201 || res.statusCode == 200) {
    final data = map['data'] as Map<String, dynamic>?;
    if (data != null) {
      final link = data['affiliate_link'];
      final fullUrl = data['full_url']?.toString() ?? '';
      if (link is Map<String, dynamic>) {
        return AffiliateGenerateResult(
          link: AffiliateLinkModel.fromJson(link),
          fullUrl: fullUrl.isNotEmpty ? fullUrl : '',
        );
      }
    }
    throw Exception('Invalid response');
  }
  final msg = map['message']?.toString() ?? 'Failed to generate link';
  throw Exception(msg);
}

// ---------------------------------------------------------------------------
// Update: PUT /api/affiliate/link/{id}
// ---------------------------------------------------------------------------

Future<void> affiliateUpdate(
  String? token, {
  required int id,
  String? name,
  String? status,
  String? destinationUrl,
}) async {
  if (token == null || token.isEmpty) throw Exception('Not logged in');

  final uri = Uri.parse(CommonAPIController.affiliateLink(id));
  final body = <String, dynamic>{};
  if (name != null) body['name'] = name;
  if (status != null) body['status'] = status;
  if (destinationUrl != null) body['destination_url'] = destinationUrl;

  final res = await http.put(
    uri,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'token': token,
    },
    body: jsonEncode(body),
  );

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200) return;
  final msg = map['message']?.toString() ?? 'Failed to update link';
  throw Exception(msg);
}

// ---------------------------------------------------------------------------
// Delete: DELETE /api/affiliate/link/{id}
// ---------------------------------------------------------------------------

Future<void> affiliateDelete(String? token, {required int id}) async {
  if (token == null || token.isEmpty) throw Exception('Not logged in');

  final uri = Uri.parse(CommonAPIController.affiliateLink(id));
  final res = await http.delete(
    uri,
    headers: {'Accept': 'application/json', 'token': token},
  );

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200) return;
  final msg = map['message']?.toString() ?? 'Failed to delete link';
  throw Exception(msg);
}
