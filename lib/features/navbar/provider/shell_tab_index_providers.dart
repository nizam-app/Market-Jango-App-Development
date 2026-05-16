import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active tab index when [VendorBottomNav] is the current shell.
final vendorShellTabIndexProvider = StateProvider<int>((ref) => 0);

/// Active tab index when [BuyerBottomNavBar] is the current shell.
final buyerShellTabIndexProvider = StateProvider<int>((ref) => 0);

/// Active tab index when [DriverBottomNavBar] is the current shell.
final driverNavIndexProvider = StateProvider<int>((ref) => 0);

/// Active tab index when [TransportBottomNavBar] is the current shell.
final transportNavIndexProvider = StateProvider<int>((ref) => 0);
