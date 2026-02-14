import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/common_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/subscription/model/current_subscription_model.dart';
import 'package:market_jango/features/subscription/model/subscription_plan_model.dart';

// ---------------------------------------------------------------------------
// Get subscription plans (GET /api/subscription/plans)
// ---------------------------------------------------------------------------

final subscriptionPlansProvider =
    AsyncNotifierProvider<SubscriptionPlansNotifier, List<SubscriptionPlanModel>>(
  SubscriptionPlansNotifier.new,
);

class SubscriptionPlansNotifier
    extends AsyncNotifier<List<SubscriptionPlanModel>> {
  @override
  Future<List<SubscriptionPlanModel>> build() async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) {
      throw Exception('Not logged in');
    }
    final uri = Uri.parse(CommonAPIController.subscriptionPlans);
    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'token': token},
    );
    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load plans: ${res.statusCode} ${res.reasonPhrase}',
      );
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final list = map['data'] as List<dynamic>? ?? [];
    return list
        .map((e) =>
            SubscriptionPlanModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

// ---------------------------------------------------------------------------
// Get current subscription (GET /api/subscription/current)
// ---------------------------------------------------------------------------

class CurrentSubscriptionState {
  final CurrentSubscriptionModel? subscription;
  final SubscriptionUsageModel? usage;
  const CurrentSubscriptionState({this.subscription, this.usage});
}

final currentSubscriptionProvider =
    AsyncNotifierProvider<CurrentSubscriptionNotifier, CurrentSubscriptionState>(
  CurrentSubscriptionNotifier.new,
);

class CurrentSubscriptionNotifier
    extends AsyncNotifier<CurrentSubscriptionState> {
  @override
  Future<CurrentSubscriptionState> build() async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) {
      throw Exception('Not logged in');
    }
    final uri = Uri.parse(CommonAPIController.subscriptionCurrent);
    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'token': token},
    );
    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load current subscription: ${res.statusCode}',
      );
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final data = map['data'];
    if (data == null) {
      return const CurrentSubscriptionState();
    }
    final dataMap = data as Map<String, dynamic>;
    CurrentSubscriptionModel? sub;
    SubscriptionUsageModel? usage;
    if (dataMap['subscription'] != null) {
      sub = CurrentSubscriptionModel.fromJson(
        dataMap['subscription'] as Map<String, dynamic>,
      );
    }
    if (dataMap['usage'] != null) {
      usage = SubscriptionUsageModel.fromJson(
        dataMap['usage'] as Map<String, dynamic>,
      );
    }
    return CurrentSubscriptionState(subscription: sub, usage: usage);
  }
}

// ---------------------------------------------------------------------------
// Subscribe to plan (POST /api/subscription/subscribe)
// ---------------------------------------------------------------------------

/// Subscribe to a plan. Pass [invalidateCurrentSubscription] so the current
/// subscription provider can be refreshed after success (e.g. ref.invalidate(currentSubscriptionProvider)).
Future<void> subscribeToPlan(
  String? token, {
  required int subscriptionPlanId,
  String? paymentMethod,
  String? transactionId,
  void Function()? invalidateCurrentSubscription,
}) async {
  if (token == null || token.isEmpty) {
    throw Exception('Not logged in');
  }
  final uri = Uri.parse(CommonAPIController.subscriptionSubscribe);
  final body = <String, dynamic>{
    'subscription_plan_id': subscriptionPlanId,
    if (paymentMethod != null && paymentMethod.isNotEmpty) 'payment_method': paymentMethod,
    if (transactionId != null && transactionId.isNotEmpty) 'transaction_id': transactionId,
  };
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
    invalidateCurrentSubscription?.call();
    return;
  }
  final message = map['message']?.toString() ?? 'Subscription failed';
  throw Exception(message);
}
