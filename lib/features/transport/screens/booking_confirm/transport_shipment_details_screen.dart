import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/buyer/screens/prement/model/prement_line_items.dart';
import 'package:market_jango/features/buyer/screens/prement/screen/web_view_screen.dart';
import 'package:market_jango/features/transport/screens/booking_confirm/data/create_shipment_data.dart';
import 'package:market_jango/features/transport/screens/booking_confirm/data/transport_shipment_document_api.dart';
import 'package:market_jango/features/transport/screens/my_booking/data/transport_booking_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/util/vendor_order_document_local_save.dart';

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
  String? _docLoadingKey;

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
          SnackBar(
            content: Text('${ref.t(BKeys.pay, fallback: 'Pay')} success'),
          ),
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

  String _humanizeSnake(String raw) {
    final s = raw.trim();
    if (s.isEmpty || s == '-') return s;
    return s
        .split(RegExp(r'[_\s]+'))
        .where((p) => p.isNotEmpty)
        .map(
          (p) => p.length == 1
              ? p.toUpperCase()
              : '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  /// Display empty / null API values like the invoice PDF (—).
  String _em(dynamic v) {
    if (v == null) return '\u2014';
    if (v is String && v.trim().isEmpty) return '\u2014';
    if (v is String && v == '-') return '\u2014';
    return v.toString();
  }

  String _money(dynamic amount, String currency) {
    final a = _em(amount);
    if (a == '\u2014') return '\u2014 $currency';
    return '$a $currency';
  }

  String _formatShipmentDate(String raw) {
    final t = raw.trim();
    if (t.isEmpty || t == '-') return '\u2014';
    if (t.length >= 16 && t.contains('T')) {
      return '${t.substring(0, 10)} ${t.substring(11, 16)}';
    }
    return t;
  }

  List<Map<String, dynamic>> _packagesFromShipment(Map<String, dynamic> shipment) {
    final raw = shipment['packages'];
    if (raw is! List) return [];
    final out = <Map<String, dynamic>>[];
    for (final e in raw) {
      if (e is Map<String, dynamic>) out.add(e);
    }
    return out;
  }

  Map<String, dynamic>? _driverUser(Map<String, dynamic>? driver) {
    if (driver == null) return null;
    final u = driver['user'];
    return u is Map<String, dynamic> ? u : null;
  }

  Future<void> _downloadShipmentDocument(bool deliveryLabel) async {
    final id = widget.args.shipmentId ??
        _shipmentIdFromMap(widget.args.result?.shipment);
    if (id == null || id <= 0) {
      GlobalSnackbar.show(
        context,
        title: 'Unavailable',
        message: 'Could not resolve shipment id for download.',
        type: CustomSnackType.error,
      );
      return;
    }
    final key = deliveryLabel ? 'label' : 'invoice';
    setState(() => _docLoadingKey = key);
    try {
      final token = await ref.read(authTokenProvider.future) ?? '';
      final doc = deliveryLabel
          ? await fetchTransportShipmentDeliveryLabelDocument(
              token: token,
              shipmentId: id,
            )
          : await fetchTransportShipmentInvoiceDocument(
              token: token,
              shipmentId: id,
            );
      if (!mounted) return;
      await saveVendorOrderDocumentLocallyAndShare(
        context: context,
        bytes: doc.bytes,
        contentType: doc.contentType,
        orderLabel: '$id',
        isDeliveryLabel: deliveryLabel,
      );
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Download complete',
          message:
              'Your PDF is ready. Use the share sheet to save it to Downloads or Files.',
          type: CustomSnackType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Error',
          message: e.toString().replaceFirst('Exception: ', ''),
          type: CustomSnackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _docLoadingKey = null);
    }
  }

  PreferredSizeWidget _shipmentAppBar(Color textPrimary, Color cardBg) {
    return AppBar(
      backgroundColor: cardBg,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Text(
        ref.t(BKeys.shipment_details, fallback: 'Shipment details'),
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color cardBg = Color(0xFFFFFFFF);
    const Color textPrimary = Color(0xFF1E293B);
    const Color textSecondary = Color(0xFF64748B);

    String str(dynamic v) {
      if (v == null) return '-';
      if (v is String) return v.isEmpty ? '-' : v;
      return v.toString();
    }

    final result = widget.args.result;
    if (result != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: _shipmentAppBar(textPrimary, cardBg),
        body: _buildScrollContent(
          context,
          result,
          textPrimary,
          textSecondary,
          str,
        ),
      );
    }

    final shipmentId = widget.args.shipmentId!;
    final detailAsync = ref.watch(shipmentDetailProvider(shipmentId));
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _shipmentAppBar(textPrimary, cardBg),
      body: detailAsync.when(
        data: (data) {
          final shipmentMap =
              data['shipment'] as Map<String, dynamic>? ?? data as Map<String, dynamic>?;
          final loadedResult = CreateShipmentResult(
            shipment: shipmentMap,
            totalPieces: (data['total_pieces'] as num?)?.toInt() ?? 0,
            totalWeightKg: (data['total_weight_kg'] as num?)?.toDouble() ?? 0,
          );
          return _buildScrollContent(
            context,
            loadedResult,
            textPrimary,
            textSecondary,
            str,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
      ),
    );
  }

  Widget _buildScrollContent(
    BuildContext context,
    CreateShipmentResult result,
    Color textPrimary,
    Color textSecondary,
    String Function(dynamic) str,
  ) {
    final shipment = result.shipment ?? {};
    String v(dynamic key) => str(shipment[key]);
    final statusDisplay = _humanizeSnake(v('status'));
    final paymentStatusDisplay = _humanizeSnake(v('payment_status'));
    final sid = int.tryParse(v('id')) ?? 0;
    final currency = v('declared_value_currency');
    final cur = currency == '-' ? 'USD' : currency;
    final driver = shipment['driver'] is Map<String, dynamic>
        ? shipment['driver'] as Map<String, dynamic>
        : null;
    final driverUser = _driverUser(driver);
    final packages = _packagesFromShipment(shipment);
    final transportTypeRaw = shipment['transport_type'];
    final transportTypeLine = _em(transportTypeRaw);

    final overline = TextStyle(
      fontSize: 11.sp,
      height: 1.2,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w600,
      color: textSecondary,
    );
    final valueStyle = TextStyle(
      fontSize: 16.sp,
      height: 1.35,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    );
    final bodyStyle = TextStyle(
      fontSize: 14.sp,
      height: 1.45,
      fontWeight: FontWeight.w500,
      color: textPrimary,
    );
    final subtleStyle = TextStyle(
      fontSize: 13.sp,
      height: 1.35,
      color: textSecondary,
      fontWeight: FontWeight.w500,
    );

    Widget invoiceBlock(
      String label,
      String value, {
      bool bottomGap = true,
    }) {
      return Padding(
        padding: EdgeInsets.only(bottom: bottomGap ? 18.h : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: overline),
            SizedBox(height: 6.h),
            Text(value, style: valueStyle),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            sid > 0 ? 'SHIPMENT #$sid' : 'SHIPMENT',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _formatShipmentDate(v('created_at')),
            style: subtleStyle,
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _statusChip(paymentStatusDisplay, const Color(0xFFFEF3C7), const Color(0xFF92400E)),
              _statusChip(statusDisplay, const Color(0xFFE0F2FE), const Color(0xFF0369A1)),
            ],
          ),
          if (v('payment_tx_ref') != '-') ...[
            SizedBox(height: 14.h),
            _surfaceCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 20.sp, color: textSecondary),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PAYMENT REF', style: overline),
                        SizedBox(height: 4.h),
                        SelectableText(
                          v('payment_tx_ref'),
                          style: bodyStyle.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 20.h),

          /// Account / pickup (invoice-style grey panel)
          _surfaceCard(
            tint: const Color(0xFFF8FAFC),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PICKUP & CONTACT', style: overline),
                SizedBox(height: 10.h),
                if (shipment['user'] is Map<String, dynamic>) ...[
                  _accountLines(shipment['user'] as Map<String, dynamic>, bodyStyle, subtleStyle),
                  SizedBox(height: 12.h),
                  Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
                  SizedBox(height: 12.h),
                ],
                Text('Pickup phone', style: subtleStyle),
                SizedBox(height: 4.h),
                Text(_em(shipment['pickup_contact_phone']), style: valueStyle.copyWith(fontSize: 17.sp)),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          _surfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                invoiceBlock('Ship from', _em(shipment['origin_address'])),
                invoiceBlock('Ship to', _em(shipment['destination_address'])),
                invoiceBlock('Transport type', transportTypeLine, bottomGap: false),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          if (driver != null) ...[
            _surfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TRANSPORTER', style: overline),
                  SizedBox(height: 10.h),
                  Text(
                    () {
                      final n = _em(driverUser?['name']);
                      final p = _em(driverUser?['phone']);
                      if (n != '\u2014' && p != '\u2014') return '$n \u2014 $p';
                      if (n != '\u2014') return n;
                      if (p != '\u2014') return p;
                      return '\u2014';
                    }(),
                    style: valueStyle.copyWith(fontSize: 15.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    () {
                      final parts = [
                        _em(driver['car_name']),
                        _em(driver['car_model']),
                      ].where((x) => x != '\u2014').join(' · ');
                      return parts.isEmpty ? '\u2014' : parts;
                    }(),
                    style: subtleStyle,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],

          _surfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PACKAGES', style: overline),
                SizedBox(height: 8.h),
                Text(
                  '${result.totalPieces} pc · ${result.totalWeightKg.toStringAsFixed(2)} kg total',
                  style: valueStyle.copyWith(fontSize: 15.sp),
                ),
                if (packages.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  _packagesTable(packages, textPrimary, textSecondary),
                ],
              ],
            ),
          ),
          SizedBox(height: 20.h),

          _surfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                invoiceBlock(
                  'Pickup instructions',
                  _em(shipment['pickup_instructions']),
                  bottomGap: v('message_to_driver') != '-',
                ),
                if (v('message_to_driver') != '-') ...[
                  Text('MESSAGE TO DRIVER', style: overline),
                  SizedBox(height: 6.h),
                  Text(v('message_to_driver'), style: bodyStyle),
                ],
              ],
            ),
          ),
          SizedBox(height: 20.h),

          _surfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('AMOUNTS', style: overline),
                SizedBox(height: 12.h),
                _amountRow('Declared value', _money(shipment['declared_value'], cur)),
                _amountRow('Estimated price', _money(shipment['estimated_price'], cur)),
                _amountRow('Final price', _money(shipment['final_price'], cur), emphasize: true),
              ],
            ),
          ),
          SizedBox(height: 22.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _docLoadingKey != null
                      ? null
                      : () => _downloadShipmentDocument(false),
                  icon: _docLoadingKey == 'invoice'
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AllColor.blue500,
                          ),
                        )
                      : Icon(Icons.picture_as_pdf_outlined, size: 18.sp),
                  label: Text('Invoice', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AllColor.blue500,
                    side: BorderSide(color: AllColor.blue500.withValues(alpha: 0.55)),
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _docLoadingKey != null
                      ? null
                      : () => _downloadShipmentDocument(true),
                  icon: _docLoadingKey == 'label'
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AllColor.blue500,
                          ),
                        )
                      : Icon(Icons.local_shipping_outlined, size: 18.sp),
                  label: Text(
                    'Delivery label',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AllColor.blue500,
                    side: BorderSide(color: AllColor.blue500.withValues(alpha: 0.55)),
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          if (v('payment_status') == 'pending' || v('payment_status') == '-')
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
                        ref.t(BKeys.pay, fallback: 'Pay'),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _accountLines(
    Map<String, dynamic> user,
    TextStyle bodyStyle,
    TextStyle subtleStyle,
  ) {
    final name = _em(user['name']);
    final email = _em(user['email']);
    final phone = _em(user['phone']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (name != '\u2014') Text(name, style: bodyStyle.copyWith(fontWeight: FontWeight.w700, fontSize: 15.sp)),
        if (phone != '\u2014') Text(phone, style: bodyStyle),
        if (email != '\u2014') Text(email, style: subtleStyle),
      ],
    );
  }

  Widget _statusChip(String text, Color bg, Color fg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Widget _amountRow(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: emphasize ? 16.sp : 14.sp,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _packagesTable(
    List<Map<String, dynamic>> packages,
    Color textPrimary,
    Color textSecondary,
  ) {
    final headerStyle = TextStyle(
      fontSize: 11.sp,
      fontWeight: FontWeight.w700,
      color: textSecondary,
    );
    final cellStyle = TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: textPrimary);

    TableRow row(List<Widget> cells, {bool header = false}) {
      return TableRow(
        decoration: header
            ? const BoxDecoration(color: Color(0xFFEFF6FF))
            : null,
        children: cells
            .map(
              (w) => Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                child: w,
              ),
            )
            .toList(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Table(
        border: TableBorder.all(color: const Color(0xFFE2E8F0), width: 1),
        columnWidths: {
          0: FixedColumnWidth(28.w),
          1: FlexColumnWidth(2.2),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(0.75),
        },
        children: [
          row(
            [
              Text('#', style: headerStyle),
              Text('L×W×H (cm)', style: headerStyle),
              Text('Wt (kg)', style: headerStyle),
              Text('Qty', style: headerStyle),
            ],
            header: true,
          ),
          for (var i = 0; i < packages.length; i++)
            row([
              Text('${i + 1}', style: cellStyle),
              Text(
                '${packages[i]['length_cm']}\u00D7${packages[i]['width_cm']}\u00D7${packages[i]['height_cm']}',
                style: cellStyle,
              ),
              Text('${packages[i]['weight_kg']}', style: cellStyle),
              Text('${packages[i]['quantity']}', style: cellStyle),
            ]),
        ],
      ),
    );
  }

  Widget _surfaceCard({required Widget child, Color? tint}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: tint ?? Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
