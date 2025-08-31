import 'package:flutter/material.dart';
import 'package:market_jango/features/buyer/screens/prement/model/prement_model.dart';

final paymentOptions = [
  PaymentOption(label: 'Card', icon: Icons.credit_card),
  PaymentOption(label: 'G Pay', asset: 'assets/icon/google.jpeg'),
  PaymentOption(label: 'PayPal', asset: 'assets/icon/paypal.png'),
  PaymentOption(label: 'Cash', icon: Icons.attach_money),
  PaymentOption(label: "Mobile", icon: Icons.phone_iphone_outlined)
];