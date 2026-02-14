import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/features/buyer/screens/cart/screen/cart_screen.dart';

class PaymentCompleteScreen extends StatefulWidget {
  const PaymentCompleteScreen({super.key});
  static const routeName = "/paymentCompleteScreen";

  @override
  State<PaymentCompleteScreen> createState() => _PaymentCompleteScreenState();
}

class _PaymentCompleteScreenState extends State<PaymentCompleteScreen> {
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    // Auto navigate back to cart after 3 seconds
    _autoCloseTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToCart();
      }
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  void _navigateToCart() async {
    // Use Future.microtask to ensure this runs asynchronously
    // This prevents Navigator locked error
    await Future.microtask(() {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
    
    // Wait a tiny bit to ensure pop completes
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Now navigate to cart using GoRouter
    if (mounted) {
      context.go(CartScreen.routeName);
    }
  }

  void _closeAndGoBack() {
    _autoCloseTimer?.cancel();
    _navigateToCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _closeAndGoBack,
        ),
        title: const Text(
          'Complete Payment',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                           MediaQuery.of(context).padding.top - 
                           MediaQuery.of(context).padding.bottom - 
                           kToolbarHeight - 80.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Green circle with checkmark
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50), // Green color
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  
                  SizedBox(height: 40.h),
                  
                  // "Thanks for your payment!" message
                  Text(
                    'Thanks for your payment!',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange.shade700, // Orange/gold color
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // "Your transaction was completed successfully" message
                  Text(
                    'Your transaction was completed successfully.',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 60.h),
                  
                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _closeAndGoBack,
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
