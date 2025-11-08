import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
// ⬇️ এগুলো তোমার প্রজেক্টেই আছে
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/buyer/screens/prement/screen/buyer_payment_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CustomTotalCheckoutSection extends StatelessWidget {
  const CustomTotalCheckoutSection({
    super.key,
    required this.totalPrice,
    required this.context,
    this.onCheckout, // optional external handler
  });

  final double totalPrice;
  final BuildContext context;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AllColor.white,
        boxShadow: [
          BoxShadow(
            color: AllColor.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, -3.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "Total ",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AllColor.black,
                ),
              ),
              Text(
                '\$${totalPrice}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AllColor.black,
                ),
              ),
            ],
          ),

          ElevatedButton(
            onPressed: () {
              if (onCheckout != null) {
                onCheckout!();
              } else {
                _defaultCheckout(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AllColor.blue,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              "Checkout",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AllColor.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ DEFAULT CHECKOUT FLOW ------------------
  Future<void> _defaultCheckout(BuildContext ctx) async {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
              SizedBox(width: 12),
              Text('Preparing checkout...'),
            ],
          ),
        ),
      ),
    );

    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      final token = _pref.getString("auth_token");
      final uri = Uri.parse(BuyerAPIController.invoice_createate);
      final res = await http.get(
        uri,
        headers: {'Accept': 'application/json', 'token': token ?? ''},
      );

      if (ctx.mounted) Navigator.pop(ctx);

      if (res.statusCode != 200) {
        ctx.push(BuyerPaymentScreen.routeName);
        GlobalSnackbar.show(
          context,
          title: "Error",
          message: 'Invoice failed: ${res.statusCode}',
          type: CustomSnackType.error,
        );
        return;
      }

      final body = res.body;
      final url = _extractPaymentUrl(body);

      if (url == null || url.isEmpty) {
        ctx.push(BuyerPaymentScreen.routeName);
        GlobalSnackbar.show(
          context,
          title: "Error",
          message: 'Payment Url not found',
          type: CustomSnackType.error,
        );
        return;
      }

      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (ctx.mounted) {
        Navigator.pop(ctx); // loader off if still open
        ctx.push(BuyerPaymentScreen.routeName);
        GlobalSnackbar.show(
          context,
          title: "Error",
          message: 'Checkout failed: ${e}',
          type: CustomSnackType.error,
        );
        ;
      }
    }
  }

  String? _extractPaymentUrl(String raw) {
    final reg = RegExp(r'"payment_url"\s*:\s*"([^"]+)"');
    final m = reg.firstMatch(raw);
    return m?.group(1);
  }
}