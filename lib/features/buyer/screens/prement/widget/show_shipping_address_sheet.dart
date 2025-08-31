import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_save_botton.dart';
// import your AllColor class

/* ========================= BOTTOM SHEET ========================= */
void showShippingAddressSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AllColor.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (context) {
      final addressCtrl = TextEditingController();
      final cityCtrl = TextEditingController();
      final postCtrl = TextEditingController();

      return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header strip with close button
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
                      'Shipping Address',
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
              padding:  EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                      label: 'Address',
                      controller: addressCtrl,
                      hintText:
                      'Magadi Main Rd, next to Prasanna Theatre,\nCholourpalya, Bengaluru, Karnataka 560023',
                      maxLines: 3,
                    ),
                    SizedBox(height: 12.h),
                    CustomTextFormField(
                      label: 'Town / City',
                      controller: cityCtrl,
                      hintText: 'Bengaluru, Karnataka 560023',
                    ),
                    SizedBox(height: 12.h),
                    CustomTextFormField(
                      label: 'Postcode',
                      controller: postCtrl,
                      hintText: '700000',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20.h),

                    // Save button
                    GlobalSaveBotton(bottonName: 'Save Changes',),
                  ],
                ),
              ),
            ),
          ],
       
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
            hintStyle: TextStyle(color: AllColor.textHintColor, fontSize: 14.sp),
            filled: true,
            fillColor: AllColor.grey.withOpacity(0.12),
            contentPadding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AllColor.textBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AllColor.textBorderColor, width: 1.2),
            ),
          ),
          style: TextStyle(color: AllColor.black, fontSize: 14.sp),
        ),
      ],
    );
  }
}