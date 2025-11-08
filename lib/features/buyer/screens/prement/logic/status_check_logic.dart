// lib/features/buyer/screens/prement/logic/status_check_logic.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

Future<bool> verifyPaymentFromServer(BuildContext context, {String? trxId}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final token = await container.read(authTokenProvider.future);

  var uri = BuyerAPIController.invoiceStatus;
  if (trxId != null && trxId.isNotEmpty) {
    uri = uri.replace(queryParameters: {'transaction_id': trxId});
  }

  final res = await http
      .get(uri, headers: {
    'Accept': 'application/json',
    if (token != null && token.isNotEmpty) 'token': token,
  })
      .timeout(const Duration(seconds: 20));

  if (res.statusCode != 200) return false;

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  final st = (map['status'] ?? '').toString().toLowerCase();
  final dst = (map['data']?['status'] ?? '').toString().toLowerCase();
  return st == 'success' || dst == 'successful';
}