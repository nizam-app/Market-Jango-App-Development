import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/buyer/screens/prement/logic/global_logger.dart';
import 'package:market_jango/features/buyer/screens/prement/model/prement_line_items.dart';
import 'package:market_jango/features/buyer/screens/prement/screen/web_view_screen.dart';

/// driverId = যাকে assign করছো
/// orderItemId = যেই order item select হয়েছে (items[_selectedIndex!].id)
Future<void> startVendorAssignCheckout(
  BuildContext context, {
  required int driverId,
  required int orderItemId,
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

    final url = VendorAPIController.vendorInvoiceCreate(driverId, orderItemId);
    final uri = Uri.parse(url);

    log.i('VendorInvoiceCreate → POST $uri (token: ${maskToken(token)})');

    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'token': token,
      },
    );

    // dialog বন্ধ
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    log.i('VendorInvoiceCreate ← status=${res.statusCode}');
    log.t(
      'VendorInvoiceCreate body: '
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

    // WebView এ payment
    final result = await Navigator.of(context).push<PaymentStatusResult>(
      MaterialPageRoute(builder: (_) => PaymentWebView(url: paymentUrl)),
    );

    log.i('Vendor WebView result: ${result?.success}');

    if (!context.mounted) return;

    if (result?.success == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment completed & order assigned successfully'),
        ),
      );
      Navigator.pop(context); // assign screen থেকে back
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment not completed')));
    }
  } catch (e, st) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    log.e('Vendor checkout exception: $e\n$st');
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
  }
}
