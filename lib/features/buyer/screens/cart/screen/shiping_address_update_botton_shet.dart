// shipping_address_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/screen/google_map/screen/google_map.dart';
import 'package:market_jango/features/buyer/screens/cart/logic/buyer_shiping_update_logic.dart';
import 'package:market_jango/features/buyer/screens/cart/logic/cart_data.dart'; // cartProvider
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
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _location;
  late final TextEditingController _postcode;
  late final TextEditingController _country;

  // optional extras
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _state;

  bool _submitting = false;
  
  // Location coordinates
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    final b = widget.buyer;

    // Initialize with current values (showing previous/old values)
    _name = TextEditingController(text: b?.shipName?.trim() ?? '');
    
    // Address: prefer ship_address, fallback to address
    final shipAddr = b?.shipAddress?.trim();
    final regAddr = (b?.address ?? '').trim();
    final addressValue = (shipAddr != null && shipAddr.isNotEmpty && shipAddr != 'null')
        ? shipAddr
        : (regAddr.isNotEmpty && regAddr != 'null' ? regAddr : '');
    _address = TextEditingController(text: addressValue);
    
    // City: use state field (since city value goes to state field, not ship_state)
    final stateValue = b?.state?.trim();
    final cityValue = (stateValue != null && stateValue.isNotEmpty && stateValue != 'null')
        ? stateValue
        : '';
    _city = TextEditingController(text: cityValue);
    // Initialize location with ship_location if available, otherwise location
    final shipLoc = b?.shipLocation?.trim();
    final regLoc = b?.location?.trim();
    _location = TextEditingController(text: shipLoc ?? regLoc ?? '');
    _postcode = TextEditingController(text: b?.postcode?.trim() ?? '');
    _country = TextEditingController(text: b?.shipCountry?.trim() ?? b?.country?.trim() ?? '');
    
    // Optional extras
    _email = TextEditingController(text: b?.shipEmail?.trim() ?? '');
    _phone = TextEditingController(text: b?.shipPhone?.trim() ?? '');
    _state = TextEditingController(text: b?.shipState?.trim() ?? b?.state?.trim() ?? '');
    
    // Initialize coordinates if available (from ship_latitude and ship_longitude)
    // Note: Buyer model may not have these fields yet, but we'll handle them in the update
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _city.dispose();
    _location.dispose();
    _postcode.dispose();
    _country.dispose();
    _email.dispose();
    _phone.dispose();
    _state.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await context.push<LatLng>(GoogleMapScreen.routeName);
    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        // ship_location remains as a separate text field for location name/description
        // ship_latitude and ship_longitude are stored separately
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      // ✅ কেবল যেগুলো দিয়েছেন সেগুলোই যাবে
      final fields = <String, String>{
        if (_name.text.trim().isNotEmpty) 'ship_name': _name.text.trim(),
        // Address field এর value address field এ পাঠানো হচ্ছে (ship_address নয়)
        if (_address.text.trim().isNotEmpty) 'address': _address.text.trim(),
        // City field এর value state field এ পাঠানো হচ্ছে (ship_state নয়)
        if (_city.text.trim().isNotEmpty) 'state': _city.text.trim(),
        if (_location.text.trim().isNotEmpty) 'ship_location': _location.text.trim(),
        if (_postcode.text.trim().isNotEmpty) 'postcode': _postcode.text.trim(),
        if (_country.text.trim().isNotEmpty) 'ship_country': _country.text.trim(),
        // Optional fields:
        // if (_email.text.trim().isNotEmpty) 'ship_email': _email.text.trim(),
        // if (_phone.text.trim().isNotEmpty) 'ship_phone': _phone.text.trim(),
      };

      await ref
          .read(userUpdateServiceProvider)
          .updateUserFields(
            fields: fields,
            latitude: _latitude,
            longitude: _longitude,
          );

      if (mounted) {
        ref.invalidate(cartProvider);
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
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name field
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Name',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        TextFormField(
                          controller: _name,
                          decoration: _dec('Receiver name'),
                        ),
                        SizedBox(height: 14.h),

                        // Address field
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ref.t(BKeys.address),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        TextFormField(
                          controller: _address,
                          minLines: 2,
                          maxLines: 3,
                          decoration: _dec('Your shipping address'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Address required'
                              : null,
                        ),
                        SizedBox(height: 14.h),

                        // City field
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ref.t(BKeys.townCity),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        TextFormField(
                          controller: _city,
                          decoration: _dec('City'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'City required'
                              : null,
                        ),
                        SizedBox(height: 14.h),

                        // Location field with live location button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Location',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _location,
                                decoration: _dec('Enter location name/description'),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            ElevatedButton.icon(
                              onPressed: _pickLocation,
                              icon: const Icon(Icons.location_on, size: 20),
                              label: Text(
                                'Live',
                                style: TextStyle(fontSize: 12.sp),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AllColor.blue200,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Show coordinates if location is picked
                        if (_latitude != null && _longitude != null)
                          Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Row(
                              children: [
                                Icon(Icons.my_location, size: 16.sp, color: AllColor.blue200),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Coordinates: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AllColor.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 14.h),

                        // Postcode field
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ref.t(BKeys.postCode),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        TextFormField(
                          controller: _postcode,
                          decoration: _dec('Postcode'),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 10.h),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ref.t(BKeys.chooseCountry),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _country,
                                decoration: _dec('Country (optional)'),
                              ),
                            ),
                          ],
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
                                ? const CircularProgressIndicator(color: Colors.white)
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
