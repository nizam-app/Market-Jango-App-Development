import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

Future<String?> fetchPaymentUrl(Ref ref) async {
  final token = await ref.read(authTokenProvider.future);
  if (token == null || token.isEmpty) throw Exception('Token not found');

  final uri = Uri.parse(
    BuyerAPIController.invoice_createate,
  ); // /api/invoice/create
  final res = await http.get(
    uri,
    headers: {'Accept': 'application/json', 'token': token},
  );
  if (res.statusCode != 200)
    throw Exception('Invoice failed: ${res.statusCode}');

  final m = jsonDecode(res.body);
  final d = m['data'];
  final obj = (d is List && d.isNotEmpty) ? d.first : d;
  return obj?['paymentMethod']?['payment_url']?.toString();
}
