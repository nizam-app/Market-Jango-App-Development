import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/common_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

class CurrencyItem {
  final String code;
  final String name;
  final String symbol;

  CurrencyItem({
    required this.code,
    required this.name,
    required this.symbol,
  });

  factory CurrencyItem.fromJson(Map<String, dynamic> json) {
    return CurrencyItem(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
    );
  }
}

final currenciesProvider =
    AsyncNotifierProvider<CurrenciesNotifier, List<CurrencyItem>>(
  CurrenciesNotifier.new,
);

class CurrenciesNotifier extends AsyncNotifier<List<CurrencyItem>> {
  @override
  Future<List<CurrencyItem>> build() async => _fetch();

  Future<List<CurrencyItem>> _fetch() async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final uri = Uri.parse(CommonAPIController.currency);
    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'token': token},
    );

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load currencies: ${res.statusCode} ${res.reasonPhrase}',
      );
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    if ((jsonMap['status'] as String?) != 'success') {
      throw Exception(jsonMap['message']?.toString() ?? 'Failed to fetch currencies');
    }
    final data = jsonMap['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => CurrencyItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
