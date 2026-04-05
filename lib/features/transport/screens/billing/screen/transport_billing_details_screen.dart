import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/transport/screens/my_booking/data/transport_booking_data.dart';

class TransportBillingDetailsScreen extends ConsumerWidget {
  const TransportBillingDetailsScreen({super.key, required this.shipmentId});
  static const routeName = '/transport_billing_details';

  final int shipmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(shipmentDetailProvider(shipmentId));

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tuppertextandbackbutton(
                  screenName: '${ref.t(BKeys.invoiceDetails)} #$shipmentId',
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: detailsAsync.when(
                    data: (data) {
                      if (data.isEmpty) {
                        return Center(
                          child: Text(
                            ref.t(BKeys.invoiceNotFound),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AllColor.grey,
                            ),
                          ),
                        );
                      }
                      final shipment =
                          data['shipment'] as Map<String, dynamic>? ?? {};
                      final totalPieces =
                          (data['total_pieces'] as num?)?.toInt() ?? 0;
                      final totalWeightKg =
                          (data['total_weight_kg'] as num?)?.toDouble() ?? 0.0;
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InvoiceHeader(
                              ref: ref,
                              shipment: shipment,
                              totalPieces: totalPieces,
                              totalWeightKg: totalWeightKg,
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          SizedBox(height: 12.h),
                          Text(
                            ref.t(BKeys.loading),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AllColor.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          ref.t(BKeys.errorOccurred),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AllColor.red,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceHeader extends StatelessWidget {
  const _InvoiceHeader({
    required this.ref,
    required this.shipment,
    required this.totalPieces,
    required this.totalWeightKg,
  });
  final WidgetRef ref;
  final Map<String, dynamic> shipment;
  final int totalPieces;
  final double totalWeightKg;

  @override
  Widget build(BuildContext context) {
    final createdAt = shipment['created_at']?.toString() ?? '';
    final dateStr = _formatDate(createdAt);
    final finalPrice = shipment['final_price']?.toString() ?? '0';
    final paymentStatus = shipment['payment_status']?.toString() ?? '';
    final status = shipment['status']?.toString() ?? '';
    final origin = shipment['origin_address']?.toString() ?? '';
    final destination = shipment['destination_address']?.toString() ?? '';
    final driver = shipment['driver'] as Map<String, dynamic>?;
    final user = driver?['user'] as Map<String, dynamic>?;
    final driverName = user?['name']?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(ref.t(BKeys.total), '\$$finalPrice'),
          SizedBox(height: 8.h),
          _row(ref.t(BKeys.payable), '\$$finalPrice'),
          SizedBox(height: 8.h),
          _row(ref.t(BKeys.date), dateStr),
          if (paymentStatus.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _row(ref.t(BKeys.payment), paymentStatus),
          ],
          if (status.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _row(ref.t(BKeys.status), status),
          ],
          if (origin.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _row(ref.t(BKeys.origin), origin),
          ],
          if (destination.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _row(ref.t(BKeys.destination), destination),
          ],
          if (driverName.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _row(ref.t(BKeys.driver), driverName),
          ],
          SizedBox(height: 8.h),
          _row(ref.t(BKeys.total_packages), '$totalPieces'),
          _row(ref.t(BKeys.total_weight_kg), '${totalWeightKg.toStringAsFixed(1)} kg'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: AllColor.grey,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AllColor.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      );

  static String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
