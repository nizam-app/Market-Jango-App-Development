import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/features/buyer/screens/prement/model/prement_model.dart';


/// Load local JSON (later you can swap to API without touching UI)
final productFutureProvider = FutureProvider<ProductData>((ref) async {
  final raw = await rootBundle.loadString('assets/product.json');
  final map = jsonDecode(raw) as Map<String, dynamic>;
  return ProductData.fromJson(map['data'] as Map<String, dynamic>);
});

/// UI-controlled states (main widget থেকে control করবে)
final selectedShippingProvider = StateProvider<String>((ref) => '');
final selectedPaymentProvider = StateProvider<String>((ref) => 'card');