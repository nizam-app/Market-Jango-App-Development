// shipping_address_bottom_sheet.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
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
  const _ShippingSheet({super.key, this.buyer});
  final Buyer? buyer;

  @override
  ConsumerState<_ShippingSheet> createState() => _ShippingSheetState();
}

class _ShippingSheetState extends ConsumerState<_ShippingSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _postcode;

  // optional extras
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _state;
  late final TextEditingController _country;

  File? _pickedImage;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final b = widget.buyer;

    _address = TextEditingController(text: b?.shipAddress ?? b?.address ?? '');
    _city = TextEditingController(text: b?.shipCity ?? '');
    _postcode = TextEditingController(text: b?.postcode ?? '');
    _name = TextEditingController(text: b?.shipName ?? '');
    _email = TextEditingController(text: b?.shipEmail ?? '');
    _phone = TextEditingController(text: b?.shipPhone ?? '');
    _state = TextEditingController(text: b?.shipState ?? b?.state ?? '');
    _country = TextEditingController(text: b?.shipCountry ?? b?.country ?? '');
  }

  @override
  void dispose() {
    _address.dispose();
    _city.dispose();
    _postcode.dispose();
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _state.dispose();
    _country.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      // ✅ কেবল যেগুলো দিয়েছেন সেগুলোই যাবে
      final fields = <String, String>{
        'ship_address': _address.text,
        'ship_city': _city.text,
        if (_postcode.text.trim().isNotEmpty) 'postcode': _postcode.text,
        if (_country.text.trim().isNotEmpty) 'ship_country': _country.text,
        // চাইলে এগুলোও অন করতে পারেন:
        // if (_state.text.trim().isNotEmpty) 'ship_state': _state.text,
        // if (_name.text.trim().isNotEmpty) 'ship_name': _name.text,
        // if (_email.text.trim().isNotEmpty) 'ship_email': _email.text,
        // if (_phone.text.trim().isNotEmpty) 'ship_phone': _phone.text,
      };

      await ref
          .read(userUpdateServiceProvider)
          .updateUserFields(
            fields: fields,
            // imageFile: _pickedImage, // চাইলে ইমেজ অন করুন
          );

      if (mounted) {
        ref.invalidate(cartProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shipping address updated')),
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Shipping Address',
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

            Form(
              key: _formKey,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Address',
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

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Town / City',
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

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Postcode',
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
                      'Country',
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
                      // Optional image picker button (UI same, event only)
                      // SizedBox(width: 10.w),
                      // SizedBox(
                      //   height: 48.h,
                      //   child: OutlinedButton.icon(
                      //     onPressed: _pickImage,
                      //     icon: const Icon(Icons.image_outlined),
                      //     label: Text(
                      //       _pickedImage == null ? 'Add Image' : '1 image selected',
                      //     ),
                      //   ),
                      // ),
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
                              'Save Changes',
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
          ],
        ),
      ),
    );
  }
}
