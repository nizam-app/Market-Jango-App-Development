// shipping_address_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/features/buyer/screens/cart/logic/buyer_shiping_update_logic.dart';
import 'package:market_jango/features/buyer/screens/cart/logic/cart_data.dart'; // cartProvider
import 'package:market_jango/features/buyer/screens/cart/data/visibility_locations_data.dart';
import 'package:market_jango/features/buyer/screens/prement/data/delivery_charges_data.dart';
import 'package:market_jango/features/buyer/screens/cart/model/cart_model.dart';

Future<void> showShippingAddressBottomSheet(
  BuildContext context,
  WidgetRef ref, { // <-- keep ref to call service
  Buyer? buyer,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _ShippingSheet(buyer: buyer),
    ),
  );
}

class _ShippingSheet extends ConsumerStatefulWidget {
  const _ShippingSheet({this.buyer});
  final Buyer? buyer;

  @override
  ConsumerState<_ShippingSheet> createState() => _ShippingSheetState();
}

class _ShippingSheetState extends ConsumerState<_ShippingSheet> {
  bool _submitting = false;

  String? _selectedZone;
  String? _selectedTown;
  late final TextEditingController _stateController;

  @override
  void initState() {
    super.initState();
    final b = widget.buyer;

    final zone = b?.shipZone?.trim();
    _selectedZone = (zone != null && zone.isNotEmpty && zone != 'null') ? zone : null;
    final st = b?.shipState?.trim();
    final stateText =
        (st != null && st.isNotEmpty && st != 'null') ? st : '';
    _stateController = TextEditingController(text: stateText);
    final town = b?.shipTown?.trim();
    _selectedTown = (town != null && town.isNotEmpty && town != 'null') ? town : null;
  }

  @override
  void dispose() {
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final stateText = _stateController.text.trim();
    if ((_selectedZone ?? '').trim().isEmpty ||
        stateText.isEmpty ||
        (_selectedTown ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select zone and town, and type your state'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final fields = <String, String>{
        if (_selectedZone != null && _selectedZone!.trim().isNotEmpty)
          'ship_zone': _selectedZone!.trim(),
        'ship_state': stateText,
        if (_selectedTown != null && _selectedTown!.trim().isNotEmpty)
          'ship_town': _selectedTown!.trim(),
      };

      await ref
          .read(userUpdateServiceProvider)
          .updateUserFields(
            fields: fields,
          );

      if (mounted) {
        ref.invalidate(cartProvider);
        ref.invalidate(cartDeliveryChargesProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          //'Shipping address updated'
          SnackBar(content: Text(ref.t(BKeys.shipping_address_updated))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF0F6FF),
    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: AllColor.grey300),
      borderRadius: BorderRadius.circular(8.r),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AllColor.grey300),
      borderRadius: BorderRadius.circular(8.r),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AllColor.blue200),
      borderRadius: BorderRadius.circular(8.r),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.85; // Use 85% of screen height
    
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Text(
                    ref.t(BKeys.shippingAddress),
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 6.h),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          ref.t(BKeys.chooseCountry),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      ref.watch(visibilityZonesProvider).when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text(
                          e.toString().replaceFirst('Exception: ', ''),
                          style: TextStyle(color: Colors.red, fontSize: 12.sp),
                        ),
                        data: (zones) => DropdownButtonFormField<String>(
                          value: _selectedZone != null && zones.contains(_selectedZone)
                              ? _selectedZone
                              : null,
                          decoration: _dec('Select zone'),
                          items: zones
                              .map(
                                (z) => DropdownMenuItem<String>(
                                  value: z,
                                  child: Text(
                                    z,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedZone = v;
                              _selectedTown = null;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'State',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      TextField(
                        controller: _stateController,
                        enabled: (_selectedZone ?? '').trim().isNotEmpty,
                        textCapitalization: TextCapitalization.words,
                        decoration: _dec('Type your state'),
                      ),
                      SizedBox(height: 14.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Town',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      (_selectedZone ?? '').trim().isEmpty
                          ? DropdownButtonFormField<String>(
                              value: null,
                              decoration: _dec('Select town'),
                              items: const [],
                              onChanged: null,
                            )
                          : ref
                              .watch(
                                visibilityTownsByZoneProvider(
                                  (_selectedZone ?? '').trim(),
                                ),
                              )
                              .when(
                                loading: () => const LinearProgressIndicator(),
                                error: (e, _) => Text(
                                  e.toString().replaceFirst('Exception: ', ''),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                data: (towns) => DropdownButtonFormField<String>(
                                  value: _selectedTown != null &&
                                          towns.contains(_selectedTown)
                                      ? _selectedTown
                                      : null,
                                  decoration: _dec('Select town'),
                                  items: towns
                                      .map(
                                        (t) => DropdownMenuItem<String>(
                                          value: t,
                                          child: Text(
                                            t,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedTown = v),
                                ),
                              ),
                      SizedBox(height: 18.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AllColor.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: _submitting ? null : _submit,
                          child: _submitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  ref.t(BKeys.saveChanges),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
