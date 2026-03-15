import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/transport_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

/// Fetches transport types from GET $baseUrl/shipments/transport-types.
/// Response: data.items = list of strings e.g. ["motorcycle", "car", "air", "water"].
final transportTypesProvider =
    AsyncNotifierProvider<TransportTypesNotifier, List<String>>(
  TransportTypesNotifier.new,
);

class TransportTypesNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async => _fetch();

  Future<List<String>> _fetch() async {
    final token = await ref.read(authTokenProvider.future) ?? '';
    final uri = Uri.parse(TransportAPIController.transportTypes);
    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'token': token,
      },
    );

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to fetch transport types: ${res.statusCode} ${res.reasonPhrase}',
      );
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (json['status'] != 'success') {
      throw Exception(json['message']?.toString() ?? 'Unknown error');
    }

    final data = json['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? [];
    return items.map((e) => e.toString()).toList();
  }
}
