// lib/features/buyer/screens/prement/logic/status_check_logic.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

Future<bool> verifyPaymentFromServer(
    BuildContext context, {
      Uri? callbackUri,
      String? transactionId,
      String? txRef,
      String? statusParam,
    }) async {
  try {
    final container = ProviderScope.containerOf(context, listen: false);
    final token = await container.read(authTokenProvider.future);

    // query parameters build
    final qp = <String, String>{
      if (callbackUri != null) ...callbackUri.queryParameters.map((k, v) => MapEntry(k, v.toString())),
      if (transactionId != null) 'transaction_id': transactionId,
      if (txRef != null) 'tx_ref': txRef,
      if (statusParam != null) 'status': statusParam,
    };

    final uri = BuyerPaymentAPIController.paymentResponse.replace(queryParameters: qp);

    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'token': token,
      },
    );

    if (res.statusCode != 200) return false;

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final st  = (map['status'] ?? '').toString().toLowerCase();
    final dst = (map['data']?['status'] ?? '').toString().toLowerCase();
    return st == 'success' || dst == 'successful';
  } catch (_) {
    return false;
  }
}