import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

class LanguageResponse {
  final String status;
  final String message;
  final List<String> data;

  LanguageResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LanguageResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['data'] ?? [];
    return LanguageResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: raw.map((e) => e.toString()).toList(),
    );
  }
}

/// Languages provider -> returns just the List<String> for convenience
final languagesProvider =
    AsyncNotifierProvider<LanguagesNotifier, List<String>>(
      LanguagesNotifier.new,
    );

class LanguagesNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async => _fetch();

  Future<List<String>> _fetch() async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final uri = Uri.parse(BuyerAPIController.language); // e.g. /api/language
    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'token': token},
    );

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load languages: ${res.statusCode} ${res.reasonPhrase}',
      );
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    final parsed = LanguageResponse.fromJson(jsonMap);
    return parsed.data;
  }
}
