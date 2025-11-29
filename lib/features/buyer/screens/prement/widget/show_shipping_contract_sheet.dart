// show_shipping_contract_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- ADD
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_save_botton.dart';
import 'package:market_jango/features/buyer/screens/cart/logic/buyer_shiping_update_logic.dart';
import 'package:market_jango/features/buyer/screens/cart/logic/cart_data.dart';
import 'package:market_jango/features/buyer/screens/prement/model/prement_page_data_model.dart';

void showShippingContractSheet(
  BuildContext context,
  WidgetRef ref, // <-- ADD ref
  PaymentPageData? ares,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AllColor.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (context) {
      final nameCtrl = TextEditingController(text: ares?.buyer.shipName ?? "");
      final phoneCtrl = TextEditingController(
        text: ares?.buyer.shipPhone ?? "",
      );
      final emailCtrl = TextEditingController(
        text: ares?.buyer.shipEmail ?? "",
      );

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 8.w, 16.h),
              decoration: BoxDecoration(
                color: AllColor.blue.withOpacity(0.08),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Shipping Contract',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AllColor.black,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.close, color: AllColor.black),
                    splashRadius: 20.r,
                  ),
                ],
              ),
            ),

            // Form body
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                      label: 'Name',
                      controller: nameCtrl,
                      hintText: 'Receiver Name',
                    ),
                    SizedBox(height: 12.h),
                    CustomTextFormField(
                      label: 'Phone Number',
                      controller: phoneCtrl,
                      hintText: 'Phone',
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 12.h),
                    CustomTextFormField(
                      label: 'Email Address',
                      controller: emailCtrl,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20.h),

                    GlobalSaveBotton(
                      bottonName: 'Save Changes',
                      onPressed: () async {
                        try {
                          await ref
                              .read(userUpdateServiceProvider)
                              .updateUserFields(
                                fields: {
                                  if (nameCtrl.text.trim().isNotEmpty)
                                    'ship_name': nameCtrl.text,
                                  if (phoneCtrl.text.trim().isNotEmpty)
                                    'ship_phone': phoneCtrl.text,
                                  if (emailCtrl.text.trim().isNotEmpty)
                                    'ship_email': emailCtrl.text,
                                },
                              );
                          if (context.mounted) {
                            ref.invalidate(cartProvider);
                            context.pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contact info updated'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AllColor.black,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: AllColor.textHintColor,
              fontSize: 14.sp,
            ),
            filled: true,
            fillColor: const Color(0xFFE6F0F8),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(
                color: Color(0xFF0168B8),
                width: 0.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(
                color: Color(0xFF0168B8),
                width: 0.2,
              ),
            ),
          ),
          style: TextStyle(color: AllColor.black, fontSize: 14.sp),
        ),
      ],
    );
  }
}
