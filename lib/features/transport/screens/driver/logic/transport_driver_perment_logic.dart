import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/transport_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/buyer/screens/prement/logic/global_logger.dart';
import 'package:market_jango/features/buyer/screens/prement/model/prement_line_items.dart';
import 'package:market_jango/features/buyer/screens/prement/screen/web_view_screen.dart';

Future<void> startTransportInvoiceCheckout(
  BuildContext context, {
  required int driverId, // উদাহরণ: 3
  required String dropAddress,
  required double dropLatitude,
  required double dropLongitude,
}) async {
  // Loading dialog
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
    final container = ProviderScope.containerOf(context, listen: false);
    final token = await container.read(authTokenProvider.future);

    // POST {{baseurl}}/api/transport/invoice/create/{transportId}
    final uri = Uri.parse(
      TransportAPIController.transport_invoice_create(driverId),
    );

    log.i('TransportInvoiceCreate → POST $uri (token: ${maskToken(token)})');

    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'token': token,
      },
      body: jsonEncode({
        'drop_address': dropAddress,
        'drop_longitude': dropLongitude.toString(),
        'drop_latitude': dropLatitude.toString(),
      }),
    );

    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    log.i('TransportInvoiceCreate ← status=${res.statusCode}');
    log.t(
      'body: ${res.body.length > 400 ? res.body.substring(0, 400) + '…' : res.body}',
    );

    if (res.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invoice failed: ${res.statusCode}')),
      );
      return;
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'];

    Map<String, dynamic>? obj;
    if (data is Map<String, dynamic>) {
      obj = data;
    } else if (data is List && data.isNotEmpty && data.first is Map) {
      obj = data.first as Map<String, dynamic>;
    }

    final paymentUrl = obj?['paymentMethod']?['payment_url']?.toString() ?? '';

    log.i('payment_url = $paymentUrl');

    if (paymentUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment URL not found')));
      return;
    }

    final result = await Navigator.of(context).push<PaymentStatusResult>(
      MaterialPageRoute(builder: (_) => PaymentWebView(url: paymentUrl)),
    );

    if (!context.mounted) return;

    if (result?.success == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment completed successfully')),
      );
      Navigator.pop(context); // success → আগের screen এ back
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment not completed')));
    }
  } catch (e, st) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    log.e('Transport checkout exception: $e\n$st');
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
  }
}
