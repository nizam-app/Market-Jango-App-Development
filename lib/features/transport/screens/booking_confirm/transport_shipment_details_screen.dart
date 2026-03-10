import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/buyer/screens/prement/model/prement_line_items.dart';
import 'package:market_jango/features/buyer/screens/prement/screen/web_view_screen.dart';
import 'package:market_jango/features/transport/screens/booking_confirm/data/create_shipment_data.dart';
import 'package:market_jango/features/transport/screens/my_booking/data/transport_booking_data.dart';

/// Arguments for the shipment details screen. Either [result] (from create flow) or [shipmentId] (from list tap).
class TransportShipmentDetailsArgs {
  const TransportShipmentDetailsArgs({this.result, this.shipmentId})
      : assert(result != null || shipmentId != null, 'Provide result or shipmentId');

  final CreateShipmentResult? result;
  final int? shipmentId;
}

class TransportShipmentDetailsScreen extends ConsumerStatefulWidget {
  const TransportShipmentDetailsScreen({super.key, required this.args});

  final TransportShipmentDetailsArgs args;
  static const String routeName = '/transport_shipment_details';

  @override
  ConsumerState<TransportShipmentDetailsScreen> createState() =>
      _TransportShipmentDetailsScreenState();
}

class _TransportShipmentDetailsScreenState
    extends ConsumerState<TransportShipmentDetailsScreen> {
  bool _isPaying = false;

  Future<void> _payShipment() async {
    final id = widget.args.shipmentId ??
        _shipmentIdFromMap(widget.args.result?.shipment);
    if (id == null) return;

    setState(() => _isPaying = true);
    try {
      final token = await ref.read(authTokenProvider.future) ?? '';
      final init = await initiateShipmentPayment(token: token, shipmentId: id);
      if (!mounted) return;
      if (init.paymentUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment URL not found')),
        );
        return;
      }

      final result = await Navigator.of(context).push<PaymentStatusResult>(
        MaterialPageRoute(
          builder: (_) => PaymentWebView(url: init.paymentUrl),
        ),
      );

      if (!mounted) return;
      if (result?.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ref.t(BKeys.pay)} success')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment not completed')),
        );
      }
      // Payment WebView theke firelei details screen theke pichone chole jao
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  int? _shipmentIdFromMap(Map<String, dynamic>? m) {
    if (m == null) return null;
    final idRaw = m['id'];
    return idRaw is int ? idRaw : (idRaw is num ? idRaw.toInt() : null);
  }

  @override
  Widget build(BuildContext context) {
    const Color cardBg = Color(0xFFFFFFFF);
    const Color textPrimary = Color(0xFF1E293B);
    const Color textSecondary = Color(0xFF64748B);

    String _str(dynamic v) {
      if (v == null) return '-';
      if (v is String) return v.isEmpty ? '-' : v;
      return v.toString();
    }

    // From create flow we have result; from list tap we fetch by shipmentId
    final result = widget.args.result;
    if (result != null) {
      return _buildBody(context, result, cardBg, textPrimary, textSecondary, _str);
    }

    final shipmentId = widget.args.shipmentId!;
    final detailAsync = ref.watch(shipmentDetailProvider(shipmentId));
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          ref.t(BKeys.shipment_details),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: detailAsync.when(
        data: (data) {
          final shipmentMap = data['shipment'] as Map<String, dynamic>? ?? data as Map<String, dynamic>?;
          final loadedResult = CreateShipmentResult(
            shipment: shipmentMap,
            totalPieces: (data['total_pieces'] as num?)?.toInt() ?? 0,
            totalWeightKg: (data['total_weight_kg'] as num?)?.toDouble() ?? 0,
          );
          return _buildBody(context, loadedResult, cardBg, textPrimary, textSecondary, _str);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CreateShipmentResult result,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    String Function(dynamic) _str,
  ) {
    final shipment = result.shipment ?? {};
    String _v(dynamic key) => _str(shipment[key]);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          ref.t(BKeys.shipment_details),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20.h),

            /// Shipment overview
            _sectionTitle(ref.t(BKeys.shipment_details)),
            SizedBox(height: 10.h),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow(ref.t(BKeys.id), _v('id'), textSecondary),
                  _gap(),
                  _detailRow(ref.t(BKeys.status), _v('status'), textSecondary),
                  _gap(),
                  _detailRow('Payment status', _v('payment_status'), textSecondary),
                  _gap(),
                  _detailRow('Created', _v('created_at'), textSecondary),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            /// Route
            _sectionTitle(ref.t(BKeys.origin)),
            SizedBox(height: 10.h),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow(ref.t(BKeys.origin), _v('origin_address'), textSecondary),
                  _gap(),
                  _detailRow(ref.t(BKeys.destination), _v('destination_address'), textSecondary),
                  if (_v('transport_type') != '-') ...[_gap(), _detailRow('Transport type', _v('transport_type'), textSecondary)],
                ],
              ),
            ),
            SizedBox(height: 20.h),

            /// Contact & instructions
            _sectionTitle(ref.t(BKeys.pickup_contact_details)),
            SizedBox(height: 10.h),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow(ref.t(BKeys.building_shop_number_name), _v('pickup_instructions'), textSecondary),
                  _gap(),
                  _detailRow(ref.t(BKeys.phone_number), _v('pickup_contact_phone'), textSecondary),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            /// Message to driver
            if (_v('message_to_driver') != '-') ...[
              _sectionTitle(ref.t(BKeys.message_to_driver)),
              SizedBox(height: 10.h),
              _card(
                child: Text(
                  _v('message_to_driver'),
                  style: TextStyle(fontSize: 14.sp, color: textPrimary, height: 1.4),
                ),
              ),
              SizedBox(height: 20.h),
            ],

            /// Pricing
            _sectionTitle(ref.t(BKeys.totals)),
            SizedBox(height: 10.h),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('Estimated price', _v('estimated_price') != '-' ? '\$${_v('estimated_price')}' : _v('estimated_price'), textSecondary),
                  _gap(),
                  _detailRow('Final price', _v('final_price') != '-' ? '\$${_v('final_price')}' : _v('final_price'), textSecondary),
                  _gap(),
                  _detailRow(ref.t(BKeys.total_packages), '${result.totalPieces}', textSecondary),
                  _gap(),
                  _detailRow(ref.t(BKeys.total_weight_kg), '${result.totalWeightKg.toStringAsFixed(1)} kg', textSecondary),
                  if (_v('declared_value_currency') != '-') _gap(),
                  if (_v('declared_value_currency') != '-') _detailRow('Currency', _v('declared_value_currency'), textSecondary),
                ],
              ),
            ),
            SizedBox(height: 28.h),

            /// Pay button
            if (_v('payment_status') == 'pending' || _v('payment_status') == '-')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPaying ? null : _payShipment,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    backgroundColor: AllColor.blue500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: _isPaying
                      ? SizedBox(
                          height: 22.h,
                          width: 22.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          ref.t(BKeys.pay),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _gap() => SizedBox(height: 12.h);

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1E293B),
      ),
    );
  }

  Widget _detailRow(String label, String value, Color labelColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}
