import 'package:flutter/material.dart';
import 'package:market_jango/features/buyer/screens/prement/widget/custom_payment_method.dart';
class AddCardScreen extends StatelessWidget {
  const AddCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(child:
          Column(
             children: [
               CustomPaymentMethod()
             ],
          )
      ),
    );
  }
}