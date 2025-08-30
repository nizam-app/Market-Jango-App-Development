import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/global_save_botton.dart';
import 'package:market_jango/features/buyer/screens/prement/widget/custom_payment_method.dart';

import '../../buyer/screens/prement/data/prement_data.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});
  static const String routeName = "/addCard";

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  String selectedMethod = "Card"; // ✅ Default selected tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                   Tuppertextandbackbutton(screenName: "Add Card"),

                  CustomPaymentMethod(
                 options: paymentOptions,
                 initialIndex: 0,
                 onChanged: (i) {
                   // handle selected method index
                 },
               ),
          
                      SizedBox(height: 20.h),
          
                      /// ✅ Add Card Section
                      Row(
                        children: [
                          Icon(
                            Icons.credit_card,
                            color: Colors.orange,
                            size: 20.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "Add Credit / Debit Card",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
          
                      /// ✅ Card Form
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CustomTextField(
                              hint: "Card Holder's Name",
                              icon: Icons.person,
                            ),
                            SizedBox(height: 12.h),
                            _CustomTextField(
                              hint: "Card Number",
                              icon: Icons.credit_card,
                            ),
                            SizedBox(height: 16.h),
          
                            Text(
                              "Expire Date",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Expanded(child: _CustomTextField(hint: "Month")),
                                SizedBox(width: 10.w),
                                Expanded(child: _CustomTextField(hint: "Year")),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            _CustomTextField(
                              hint: "Security Code",
                              icon: Icons.info_outline,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          
              /// ✅ Bottom Payment Summary
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryRow("Total item", "\$50.00"),
                    SizedBox(height: 6.h),
                    _summaryRow("Subtotal", "\$100.00"),
                    SizedBox(height: 20.h),
                    GlobalSaveBotton(bottonName: 'Pay Now',)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Single Tab Builder
  Widget _buildTab({String? method, IconData? icon, String? asset}) {
    bool isActive = selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = method!),
      child: _PaymentMethodTab(
        icon: icon,
        asset: asset,
        label: method!,
        isActive: isActive,
      ),
    );
  }

  /// ✅ Summary Row
  Widget _summaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

/// =============================
/// Payment Method Tab Widget
/// =============================
class _PaymentMethodTab extends StatelessWidget {
  final IconData? icon;
  final String? asset;
  final String label;
  final bool isActive;

  const _PaymentMethodTab({
    this.icon,
    this.asset,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: isActive ? Colors.orange.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isActive ? Colors.orange : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 24.sp,
              color: isActive ? Colors.orange : Colors.grey,
            )
          else if (asset != null && asset!.endsWith(".svg"))
            SvgPicture.asset(
              asset!,
              height: 24.h,
              width: 24.w,
              colorFilter: isActive
                  ? const ColorFilter.mode(Colors.orange, BlendMode.srcIn)
                  : const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            )
          else if (asset != null)
            Image.asset(asset!, height: 24.h, width: 24.w),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.orange : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

/// =============================
/// Custom Input Field Widget
/// =============================
class _CustomTextField extends StatelessWidget {
  final String hint;
  final IconData? icon;
  const _CustomTextField({required this.hint, this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: icon != null
            ? Icon(icon, size: 18.sp, color: Colors.grey)
            : null,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}