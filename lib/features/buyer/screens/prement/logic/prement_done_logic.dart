import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/buyer/screens/prement/logic/global_logger.dart';
import 'package:market_jango/features/buyer/screens/prement/logic/prement_reverpod.dart';
import 'package:market_jango/features/buyer/screens/prement/model/prement_line_items.dart';
import 'package:market_jango/features/buyer/screens/prement/screen/web_view_screen.dart';

Future<void> startCheckout(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Dialog(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            SizedBox(width: 12),
            Text('Preparing checkout...'),
          ],
        ),
      ),
    ),
  );

  try {
    // ⬇️ riverpod container নিলাম
    final container = ProviderScope.containerOf(context, listen: false);
    final token = await container.read(authTokenProvider.future);

    // ⬇️ কোন shipping select আছে? 0 = Delivery charge, 1 = Own Pick up
    final selectedIndex = container.read(shippingMethodIndexProvider);
    final String paymentMethod = selectedIndex == 0 ? 'FW' : 'OPU';

    final uri = Uri.parse(BuyerAPIController.invoice_createate);
    log.i(
      'InvoiceCreate → POST $uri '
      '(payment_method=$paymentMethod, token: ${maskToken(token)})',
    );

    // ⬇️ GET না, এখন POST + JSON body পাঠাচ্ছি
    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'token': token,
      },
      body: jsonEncode({'payment_method': paymentMethod}),
    );

    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    log.i('InvoiceCreate ← status=${res.statusCode}');
    log.t(
      'InvoiceCreate body: '
      '${res.body.length > 400 ? res.body.substring(0, 400) + '…' : res.body}',
    );

    if (res.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invoice failed: ${res.statusCode}')),
      );
      return;
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'];

    Map<String, dynamic>? dataMap;
    if (data is Map<String, dynamic>) {
      dataMap = data;
    } else if (data is List && data.isNotEmpty && data.first is Map) {
      dataMap = data.first as Map<String, dynamic>;
    }

    final paymentField = dataMap?['paymentMethod'];

    // 🔹 CASE 1: Own Pick Up → OPU → শুধু success, কোনো webview না
    if (paymentMethod == 'OPU') {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            body['message']?.toString() ?? 'Order placed successfully',
          ),
        ),
      );
      // ইচ্ছে করলে এখানে order details screen এ push করতে পারো
      Navigator.pop(context); // payment screen থেকে back
      return;
    }

    // 🔹 CASE 2: Online payment → FW → আগের মতো payment_url নিয়ে webview এ যাবে
    String? paymentUrl;
    if (paymentField is Map<String, dynamic>) {
      paymentUrl = paymentField['payment_url']?.toString();
    }

    log.i('payment_url = $paymentUrl');

    if (paymentUrl == null || paymentUrl.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment URL not found')));
      return;
    }

    final result = await Navigator.of(context).push<PaymentStatusResult>(
      MaterialPageRoute(builder: (_) => PaymentWebView(url: paymentUrl ?? "")),
    );

    log.i('WebView result: ${result?.success}');

    if (!context.mounted) return;

    if (result?.success == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment completed successfully')),
      );
      Navigator.pop(context); // success → back
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment not completed')));
    }
  } catch (e, st) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    log.e('Checkout exception: $e\nStack trace: $st');
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
  }
}
