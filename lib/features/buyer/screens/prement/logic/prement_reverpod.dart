import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 0 = Delivery charge  → FW (online payment)
/// 1 = Own Pick up      → OPU (cash on delivery / own pickup)
final shippingMethodIndexProvider = StateProvider<int>((ref) => 0);
