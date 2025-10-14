import 'package:flutter/material.dart';

class CartItem {
  final String title;
  final String imageUrl; // Network/Asset/file path
  final int qty;
  final double price;
  CartItem({
    required this.title,
    required this.imageUrl,
    required this.qty,
    required this.price,
  });
}

class ShippingOption {
  final String title;
  final double cost; // 0.0 => Free/Pickup
  ShippingOption({required this.title, required this.cost});
}

/// Single payment option model
class PaymentOption {
  final String label;
  final IconData? icon;  // use when there is a Material icon (e.g., card, cash)
  final String? asset;   // use when no icon available (e.g., GPay, PayPal png/svg)

  PaymentOption({
    required this.label,
    this.icon,
    this.asset,
  });
}