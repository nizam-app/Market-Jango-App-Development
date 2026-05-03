import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_asign_to_order_driver/data/asign_to_order_driver_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';

/// Assign-only flow (no Flutterwave): `POST /vendor/orders/{invoice_item_id}/assign-driver`.
/// See `doc/details.md`.
///
/// [orderItemId] = invoice line id (`VendorPendingOrder.id`), same as marketplace assign.
Future<void> startVendorAssignCheckout(
  BuildContext context,
  WidgetRef ref, {
  required int driverId,
  required int orderItemId,
}) async {
  showDialog<void>(
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
            Text('Assigning driver…'),
          ],
        ),
      ),
    ),
  );

  try {
    await VendorOrderApi.instance.assignDriverToOrderItem(
      invoiceItemId: orderItemId,
      driverId: driverId,
    );

    if (!context.mounted) return;

    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    ref.invalidate(vendorPendingOrdersProvider);

    GlobalSnackbar.show(
      context,
      title: 'Assigned',
      message: 'Driver assigned to this order line.',
      type: CustomSnackType.success,
    );
    Navigator.pop(context);
  } catch (e, st) {
    if (!context.mounted) return;
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    debugPrint('Vendor assign-driver failed: $e\n$st');
    GlobalSnackbar.show(
      context,
      title: 'Cannot assign driver',
      message: e.toString().replaceFirst('Exception: ', ''),
      type: CustomSnackType.error,
      duration: const Duration(seconds: 4),
    );
  }
}
