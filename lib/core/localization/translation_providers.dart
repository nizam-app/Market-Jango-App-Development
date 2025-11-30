import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/common_api.dart';
import 'package:market_jango/core/localization/translation_repository.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

Future<AppTranslations> _fetchTranslations(Ref ref) async {
  final token = await ref.read(authTokenProvider.future) ?? '';

  final uri = Uri.parse(CommonAPIController.translations);

  final res = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
      if (token.isNotEmpty) 'token': token,
      // language backend নিজে handle করলে এখানে আর কিছু লাগবে না
      // নাহলে চাইলে: 'Accept-Language': selectedLangCode
    },
  );

  if (res.statusCode != 200) {
    throw Exception(
      'Failed to load translations: '
      '${res.statusCode} ${res.body}',
    );
  }

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  return AppTranslations.fromJson(map);
}

/// AsyncNotifier যেন refresh করতে পারি
class AppTranslationsNotifier extends AsyncNotifier<AppTranslations> {
  @override
  Future<AppTranslations> build() async {
    return _fetchTranslations(ref);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchTranslations(ref));
  }

  /// helper – state এর উপরে safe get
  String t(String key, {String? fallback}) {
    final current = state;
    return current.maybeWhen(
      data: (tr) => tr.get(key, fallback: fallback),
      orElse: () => fallback ?? key,
    );
  }
}

/// main provider
final appTranslationsProvider =
    AsyncNotifierProvider<AppTranslationsNotifier, AppTranslations>(
      AppTranslationsNotifier.new,
    );
