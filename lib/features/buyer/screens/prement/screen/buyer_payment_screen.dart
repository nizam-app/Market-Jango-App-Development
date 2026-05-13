import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/custom_total_checkout_section.dart';
import 'package:market_jango/features/buyer/screens/prement/logic/prement_done_logic.dart';
import 'package:market_jango/features/buyer/screens/prement/logic/prement_reverpod.dart';
import 'package:market_jango/features/buyer/screens/prement/model/prement_model.dart';
import 'package:market_jango/features/buyer/screens/prement/widget/show_shipping_contract_sheet.dart';
import 'package:market_jango/features/buyer/screens/prement/data/delivery_charges_data.dart';
import 'package:market_jango/features/transport/screens/add_card_screen.dart';
import 'package:market_jango/features/buyer/screens/cart/logic/cart_data.dart';
import 'package:market_jango/features/buyer/screens/cart/screen/shiping_address_update_botton_shet.dart';

import '../model/prement_page_data_model.dart'; // <-- PaymentPageData

class _RouteLineAgg {
  num total = 0;
  final List<String> productLines = <String>[];
  String skipReason = '';
}

class BuyerPaymentScreen extends ConsumerStatefulWidget {
  const BuyerPaymentScreen({super.key});
  static const routeName = "/buyerPaymentScreen";

  @override
  ConsumerState<BuyerPaymentScreen> createState() => _BuyerPaymentScreenState();
}

class _BuyerPaymentScreenState extends ConsumerState<BuyerPaymentScreen> {
  String _prettyKey(String k) {
    return k
        .replaceAll('_', ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _humanizeSkipReason(String code) {
    if (code.trim().isEmpty) return '';
    final t = code.trim();
    if (t == 'no_matching_route') {
      return 'No matching delivery route for this vendor → buyer path.';
    }
    return _prettyKey(t);
  }

  static const Color _deliveryTableBorder = Color(0xFF212121);

  String _fmtMoney(String currency, num v) =>
      '$currency${v.toStringAsFixed(2)}';

  TableRow _deliveryTableHeader(String col2, String col3) {
    TextStyle headerStyle() => TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        );
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
            child: Text('#', textAlign: TextAlign.center, style: headerStyle()),
          ),
        ),
        TableCell(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Text(col2, style: headerStyle()),
          ),
        ),
        TableCell(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Text(
              col3,
              textAlign: TextAlign.right,
              style: headerStyle(),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _deliveryTableDataRow(
    String idx,
    String label,
    String costRight, {
    String? detailLine,
    String? warningLine,
  }) {
    final base = TextStyle(fontSize: 12.sp, color: Colors.black87);
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
            child: Text(idx, textAlign: TextAlign.center, style: base),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: base),
                if (detailLine != null && detailLine.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      detailLine,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.black45,
                        height: 1.2,
                      ),
                    ),
                  ),
                if (warningLine != null && warningLine.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      warningLine,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.deepOrange.shade800,
                        height: 1.2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Text(
              costRight,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12.sp, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  Widget _deliveryChargeDetailTables(
    DeliveryChargesResponse resp,
    String currency,
  ) {
    final border = TableBorder.all(color: _deliveryTableBorder, width: 1);
    final colWidths = {
      0: FixedColumnWidth(34.w),
      1: const FlexColumnWidth(1),
      2: FixedColumnWidth(76.w),
    };

    // --- Route: prefer zone `per_town_breakdown`; else merge line_items by vendor→buyer ---
    final routeRows = <TableRow>[_deliveryTableHeader('Route', 'Cost')];
    if (resp.routeSummaries.isNotEmpty) {
      var n = 0;
      for (final s in resp.routeSummaries) {
        n++;
        final route = '${s.vendorTown} to ${s.buyerTown}';
        final detailParts = <String>[];
        if (s.flat != 0) {
          detailParts.add('Flat ${_fmtMoney(currency, s.flat)}');
        }
        if (s.weightBased != 0) {
          detailParts.add('Weight ${_fmtMoney(currency, s.weightBased)}');
        }
        final detail =
            detailParts.isEmpty ? null : detailParts.join(' · ');
        routeRows.add(
          _deliveryTableDataRow(
            '$n',
            route,
            _fmtMoney(currency, s.townTotal),
            detailLine: detail,
          ),
        );
      }
    } else if (resp.items.isEmpty) {
      routeRows.add(_deliveryTableDataRow('', '—', _fmtMoney(currency, 0)));
    } else {
      final byRoute = <String, _RouteLineAgg>{};
      for (final it in resp.items) {
        final key = '${it.vendorTown}|${it.buyerTown}';
        final a = byRoute.putIfAbsent(key, _RouteLineAgg.new);
        a.total += it.finalDeliveryCharge;
        final sub = StringBuffer('${it.productName} ×${it.quantity}');
        if (it.vendorName.isNotEmpty) {
          sub.write(' · ${it.vendorName}');
        }
        a.productLines.add(sub.toString());
        if (it.skipReason.isNotEmpty) {
          a.skipReason = it.skipReason;
        }
      }
      var n = 0;
      for (final e in byRoute.entries) {
        n++;
        final parts = e.key.split('|');
        final vt = parts.isNotEmpty ? parts[0] : '';
        final bt = parts.length > 1 ? parts[1] : '';
        final route = '$vt to $bt';
        final a = e.value;
        final skipNote = a.skipReason.isNotEmpty
            ? _humanizeSkipReason(a.skipReason)
            : null;
        routeRows.add(
          _deliveryTableDataRow(
            '$n',
            route,
            _fmtMoney(currency, a.total),
            detailLine: a.productLines.join(' · '),
            warningLine: skipNote,
          ),
        );
      }
    }

    // --- Extras: only merged `charges_applied` from `data.zones` (no weight row, no line surcharges) ---
    final extraPairs = <(String, num)>[];
    final zoneKeys = resp.zoneChargesApplied.keys.toList()
      ..sort((a, b) {
        const order = ['city_based', 'weight_based', 'cube_based'];
        final ia = order.indexOf(a);
        final ib = order.indexOf(b);
        if (ia != -1 || ib != -1) {
          final va = ia == -1 ? 999 : ia;
          final vb = ib == -1 ? 999 : ib;
          final c = va.compareTo(vb);
          if (c != 0) return c;
        }
        return a.compareTo(b);
      });
    for (final k in zoneKeys) {
      final v = resp.zoneChargesApplied[k]!;
      extraPairs.add((_prettyKey(k), v));
    }
    if (extraPairs.isEmpty) {
      extraPairs.add(('', 0));
    }

    final extraRows = <TableRow>[_deliveryTableHeader('Extras', 'Cost')];
    var ex = 0;
    for (final p in extraPairs) {
      ex++;
      extraRows.add(
        _deliveryTableDataRow(
          '$ex',
          p.$1.isEmpty ? ' ' : p.$1,
          _fmtMoney(currency, p.$2),
        ),
      );
    }
    extraRows.add(_deliveryTableDataRow('', ' ', ' '));

    // --- Fees ---
    final feeRows = <TableRow>[
      _deliveryTableHeader('Fees', 'Cost'),
      _deliveryTableDataRow(
        '',
        'Platform fees',
        _fmtMoney(currency, resp.platformFee),
      ),
      _deliveryTableDataRow(
        '1',
        'Tax',
        _fmtMoney(currency, resp.tax),
      ),
      _deliveryTableDataRow('', ' ', ' '),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Table(
          border: border,
          columnWidths: colWidths,
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: routeRows,
        ),
        SizedBox(height: 10.h),
        Table(
          border: border,
          columnWidths: colWidths,
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: extraRows,
        ),
        SizedBox(height: 10.h),
        Table(
          border: border,
          columnWidths: colWidths,
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: feeRows,
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            border: Border.all(color: _deliveryTableBorder, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Total (merchandise + delivery + fees)',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                width: 76.w,
                child: Text(
                  _fmtMoney(
                    currency,
                    resp.grandTotal > 0
                        ? resp.grandTotal
                        : (resp.merchandiseSubtotal +
                            resp.cartTotalDeliveryCharge +
                            resp.platformFee +
                            resp.tax),
                  ),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Merchandise ${_fmtMoney(currency, resp.merchandiseSubtotal)} · '
          'Delivery ${_fmtMoney(currency, resp.cartTotalDeliveryCharge)} · '
          'Fees ${_fmtMoney(currency, resp.platformFee + resp.tax)}'
          '${resp.zonesAggregatedWeightKg > 0 ? ' · Zone weight ${resp.zonesAggregatedWeightKg} kg' : ''}',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 10.sp, color: Colors.black54),
        ),
      ],
    );
  }

  void _showDeliveryChargeDetails(
    BuildContext context,
    DeliveryChargesResponse resp,
    String currency,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Delivery charge details',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Flexible(
                child: SingleChildScrollView(
                  child: _deliveryChargeDetailTables(resp, currency),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pull-to-refresh: reload cart (buyer/address) and delivery-charges totals.
  Future<void> _onRefreshPaymentScreen() async {
    ref.invalidate(cartProvider);
    ref.invalidate(cartDeliveryChargesProvider);
    await Future.wait<void>([
      ref.read(cartProvider.future).then((_) {}),
      ref.read(cartDeliveryChargesProvider.future).then((_) {}),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final args = GoRouterState.of(context).extra as PaymentPageData?;
    
    // Watch cart provider to get updated buyer data after address update
    final cartAsync = ref.watch(cartProvider);
    
    // Get updated buyer from cart if available, otherwise use args
    // Priority: cart data (updated) > args (initial)
    final buyer = cartAsync.when(
      data: (cart) {
        // If cart has items, use buyer from cart (most up-to-date)
        if (cart.items.isNotEmpty) {
          return cart.items.first.buyer;
        }
        // If cart is empty, fall back to args
        return args?.buyer;
      },
      loading: () => args?.buyer, // While loading, use args
      error: (_, __) => args?.buyer, // On error, use args
    );

    // Build shipping address lines - show zone/state/town (same as cart summary)
    final shippingLines = buyer == null
        ? const ['No address available']
        : () {
            final lines = <String>[];

            final zone = buyer.shipZone?.trim();
            if (zone != null && zone.isNotEmpty && zone != 'null') {
              lines.add(zone);
            }

            final st = buyer.shipState?.trim();
            if (st != null && st.isNotEmpty && st != 'null') {
              lines.add(st);
            }

            final town = buyer.shipTown?.trim();
            if (town != null && town.isNotEmpty && town != 'null') {
              lines.add(town);
            }

            // Fallback: show something if shipping zone/state/town not set yet
            if (lines.isEmpty) {
              final shipLocation = buyer.shipLocation?.trim();
              if (shipLocation != null &&
                  shipLocation.isNotEmpty &&
                  shipLocation != 'null') {
                lines.add(shipLocation);
              }
              final shipAddress = buyer.shipAddress?.trim();
              if (shipAddress != null &&
                  shipAddress.isNotEmpty &&
                  shipAddress != 'null') {
                lines.add(shipAddress);
              }
            }

            return lines.isEmpty ? const ['No shipping address provided'] : lines;
          }();

    final contactLines = buyer == null
        ? const ['___,', '+____,', '_____']
        : [
            (buyer.shipName ?? '—'),
            (buyer.shipPhone ?? '—'),
            (buyer.shipEmail ?? '—'),
          ];

    // UI items map (ডিজাইন একই, কেবল ডেটা ম্যাপ করা)
    final List<CartItem> uiItems = args == null
        ? [
            CartItem(
              title: 'Lorem ipsum dolor sit amet consectetur.',
              imageUrl: 'https://picsum.photos/seed/a/200',
              qty: 1,
              price: 17.00,
            ),
            CartItem(
              title: 'Lorem ipsum dolor sit amet consectetur.',
              imageUrl: 'https://picsum.photos/seed/b/200',
              qty: 1,
              price: 23.00,
            ),
          ]
        : args.items
              .map(
                (it) => CartItem(
                  title: it.product.name,
                  imageUrl: it.product.image,
                  qty: it.quantity,
                  price: double.tryParse(it.price) ?? 0,
                ),
              )
              .toList();

    final deliveryChargesAsync = ref.watch(cartDeliveryChargesProvider);
    final charges = deliveryChargesAsync.valueOrNull;

    /// Authoritative delivery $ from GET /cart/delivery-charges when loaded.
    final deliveryCost = charges != null
        ? charges.cartTotalDeliveryCharge.toDouble()
        : (args?.deliveryTotal ?? 0).toDouble();

    final List<ShippingOption> options = [
      ShippingOption(title: 'Delivery charge', cost: deliveryCost),
      ShippingOption(title: 'Own Pick up', cost: 0),
    ];

    // ⬇️ currently selected shipping index (0 or 1)
    final selectedShippingIndex = ref.watch(shippingMethodIndexProvider);

    /// Payable total: API `cart_total_with_delivery_and_fees` (incl. fees), not cart-only args.
    final double checkoutTotal;
    if (charges != null) {
      final fullPayable = charges.grandTotal.toDouble();
      if (selectedShippingIndex == 0) {
        checkoutTotal = fullPayable;
      } else {
        // Own pickup: no delivery component (merchandise + platform + tax).
        checkoutTotal = (charges.merchandiseSubtotal +
                charges.platformFee +
                charges.tax)
            .toDouble();
      }
    } else {
      checkoutTotal = args?.grandTotal ?? 0;
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefreshPaymentScreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                children: [
                  Tuppertextandbackbutton(screenName: ref.t(BKeys.payment)),
                  SizedBox(height: 20.h),
                  CustomAddressAnddContract(
                    title: ref.t(BKeys.shippingAddress),
                    lines: shippingLines,
                    onEdit: () {
                      // Get updated buyer from cart if available, otherwise use args
                      final updatedBuyer = cartAsync.maybeWhen(
                        data: (cart) => cart.items.isNotEmpty ? cart.items.first.buyer : null,
                        orElse: () => null,
                      );
                      final buyerToUse = updatedBuyer ?? args?.buyer;
                      showShippingAddressBottomSheet(context, ref, buyer: buyerToUse);
                    },
                  ),
                  SizedBox(height: 20.h),
                  CustomAddressAnddContract(
                    title: ref.t(BKeys.contactInformation),
                    lines: contactLines,
                    onEdit: () {
                      showShippingContractSheet(context, ref, args);
                    },
                  ),

                  SizedBox(height: 20.h),
                  CustomItemShow(
                    items: uiItems,
                    options: options,
                    selectedIndex: selectedShippingIndex,
                    onShippingChanged: (i) {
                      // ⬇️ user নতুন যেটা select করবে সেটা riverpod এ save করলাম
                      ref.read(shippingMethodIndexProvider.notifier).state = i;
                    },
                    currency: '\$',
                    onShippingDetails: deliveryChargesAsync.maybeWhen(
                      data: (resp) => () =>
                          _showDeliveryChargeDetails(context, resp, '\$'),
                      orElse: () => null,
                    ),
                  ),

                  // buildPaymentMethodText(theme, context),
                  // SizedBox(height: 12.h),
                  //
                  // CustomPaymentMethod(
                  //   options: paymentOptions,
                  //   initialIndex: 0,
                  //   onChanged: (i) {},
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
      // Bottom total: args থেকে
      bottomNavigationBar: CustomTotalCheckoutSection(
        totalPrice: checkoutTotal,
        context: context,
        onCheckout: () => startCheckout(context),
      ),
    );
  }

  Row buildPaymentMethodText(TextTheme theme, BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text("Payment Method", style: theme.headlineLarge)),
        AddressEditIcon(
          tiBg: AllColor.blue500,
          onEdit: () {
            context.push(AddCardScreen.routeName);
          },
        ),
      ],
    );
  }

  // Future<void> _onCheckout(BuildContext context, ref) async {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) => const Dialog(
  //       child: Padding(
  //         padding: EdgeInsets.all(16),
  //         child: Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             SizedBox(
  //               width: 22,
  //               height: 22,
  //               child: CircularProgressIndicator(strokeWidth: 2.4),
  //             ),
  //             SizedBox(width: 12),
  //             Text('Preparing checkout...'),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  //
  //   try {
  //     final url = await fetchPaymentUrl(ref);
  //     if (context.mounted) Navigator.pop(context);
  //     if (url == null || url.isEmpty) {
  //       if (context.mounted)
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Payment URL not found')),
  //         );
  //       return;
  //     }
  //     await launchUrlString(url, mode: LaunchMode.externalApplication);
  //   } catch (e) {
  //     if (context.mounted) {
  //       Navigator.pop(context);
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
  //     }
  //   }
  // }
}

class CustomAddressAnddContract extends StatelessWidget {
  const CustomAddressAnddContract({
    super.key,
    required this.title,
    required this.lines,
    this.onEdit,
  });

  final String title;

  final List<String> lines;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final bg = AllColor.white;
    final tiBg = AllColor.blueGrey900;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AllColor.black.withOpacity(0.06),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
        border: Border.all(color: AllColor.grey.withOpacity(0.25)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 12.w, 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Body lines
                  Text(
                    lines.join('\n'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black.withOpacity(0.8),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Edit button
            AddressEditIcon(tiBg: tiBg, onEdit: onEdit),
          ],
        ),
      ),
    );
  }
}

class AddressEditIcon extends StatelessWidget {
  const AddressEditIcon({super.key, required this.tiBg, required this.onEdit});

  final Color tiBg;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tiBg,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Icon(Icons.edit, color: Colors.white, size: 18.sp),
        ),
      ),
    );
  }
}

class CustomItemShow extends StatefulWidget {
  const CustomItemShow({
    super.key,
    required this.items,
    required this.options,
    this.selectedIndex = 0,
    this.onShippingChanged,
    this.onShippingDetails,
    this.currency = '\$',
    this.titleItems = 'Items',
    this.titleShipping = 'Shipping Options',
  });

  final List<CartItem> items;
  final List<ShippingOption> options;
  final int selectedIndex;
  final ValueChanged<int>? onShippingChanged;
  final VoidCallback? onShippingDetails;
  final String currency;
  final String titleItems;
  final String titleShipping;

  @override
  State<CustomItemShow> createState() => _CustomItemShowState();
}

class _CustomItemShowState extends State<CustomItemShow> {
  late int _selected;

  @override
  void initState() {
    _selected = widget.selectedIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            widget.titleItems,
            badgeText: '${widget.items.length}',
          ),
          SizedBox(height: 8.h),

          // Items (ListView.builder)
          ListView.builder(
            itemCount: widget.items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) => _itemRow(widget.items[i]),
          ),
          SizedBox(height: 30.h),

          Row(
            children: [
              Expanded(
                child: Text(widget.titleShipping, style: theme.headlineLarge),
              ),
              if (widget.onShippingDetails != null)
                TextButton(
                  onPressed: widget.onShippingDetails,
                  child: const Text('Details'),
                ),
            ],
          ),
          SizedBox(height: 20.h),

          Column(
            children: List.generate(widget.options.length, (i) {
              final op = widget.options[i];
              final selected = _selected == i;
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _shippingTile(
                  title: op.title,
                  priceLabel: op.cost == 0
                      ? 'Free'
                      : '${widget.currency}${op.cost.toStringAsFixed(2)}',
                  selected: selected,
                  onTap: () {
                    setState(() => _selected = i);
                    widget.onShippingChanged?.call(i);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {required String badgeText}) {
    final theme = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(title, style: theme.headlineLarge),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AllColor.blue.shade100,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            badgeText,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemRow(CartItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          // avatar + qty badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: AllColor.white,
                child: ClipOval(
                  child: FirstTimeShimmerImage(
                    imageUrl: item.imageUrl,
                    width: 52.r,
                    height: 52.r,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: -2.w,
                top: -2.h,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6.r,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 10.r,
                    backgroundColor: const Color(0xffE5EBFC),
                    child: Text(
                      '${item.qty}',
                      style: TextStyle(
                        color: AllColor.black,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),

          Expanded(
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(width: 8.w),

          Text(
            item.price.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shippingTile({
    required String title,
    required String priceLabel,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade50 : Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              // custom radio
              Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? Colors.blue : Colors.blueGrey,
                    width: 2,
                  ),
                  color: selected ? Colors.blue : Colors.transparent,
                ),
                child: selected
                    ? Center(
                        child: Icon(
                          Icons.check,
                          size: 16.r,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                priceLabel,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Future<void> startCheckout(BuildContext context) async {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) => const Dialog(
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               width: 22,
//               height: 22,
//               child: CircularProgressIndicator(strokeWidth: 2.4),
//             ),
//             SizedBox(width: 12),
//             Text('Preparing checkout...'),
//           ],
//         ),
//       ),
//     ),
//   );
//
//   try {
//     final container = ProviderScope.containerOf(context, listen: false);
//     final token = await container.read(authTokenProvider.future);
//
//     // ✅ এখানে তোমার কনস্ট্যান্ট যেটাই হোক (Uri/String) সেটি log করবো
//     final uri = Uri.parse(BuyerAPIController.invoice_createate);
//     log.i('InvoiceCreate → GET $uri  (token: ${maskToken(token)})');
//
//     final res = await http.get(
//       uri,
//       headers: {
//         'Accept': 'application/json',
//         if (token != null && token.isNotEmpty) 'token': token,
//       },
//     );
//
//     if (Navigator.of(context, rootNavigator: true).canPop()) {
//       Navigator.of(context, rootNavigator: true).pop();
//     }
//
//     log.i('InvoiceCreate ← status=${res.statusCode}');
//     log.t(
//       'InvoiceCreate body: ${res.body.length > 400 ? res.body.substring(0, 400) + '…' : res.body}',
//     );
//
//     if (res.statusCode != 200) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Invoice failed: ${res.statusCode}')),
//       );
//       return;
//     }
//
//     final body = jsonDecode(res.body) as Map<String, dynamic>;
//     final data = body['data'];
//     final obj = (data is List && data.isNotEmpty) ? data.first : data;
//     final paymentUrl = obj?['paymentMethod']?['payment_url']?.toString();
//
//     log.i('payment_url = $paymentUrl');
//
//     if (paymentUrl == null || paymentUrl.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Payment URL not found')));
//       return;
//     }
//
//     final result = await Navigator.of(context).push<PaymentStatusResult>(
//       MaterialPageRoute(builder: (_) => PaymentWebView(url: paymentUrl)),
//     );
//
//     log.i('WebView result: ${result?.success}');
//
//     if (result?.success == true) {
//       if (!context.mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Payment completed successfully')),
//       );
//       Navigator.pop(context); // success → back
//     } else {
//       if (!context.mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Payment not completed')));
//     }
//   } catch (e, st) {
//     if (Navigator.of(context, rootNavigator: true).canPop()) {
//       Navigator.of(context, rootNavigator: true).pop();
//     }
//     log.e('Checkout exception: $e\nStack trace: $st');
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
//   }
// }
