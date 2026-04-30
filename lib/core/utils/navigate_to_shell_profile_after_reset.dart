import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/features/navbar/provider/shell_tab_index_providers.dart';
import 'package:market_jango/features/navbar/screen/buyer_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/driver_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/transport_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/vendor_bottom_nav.dart';

/// Profile/settings tab indices (matches each shell’s `_pages`).
const _buyerProfileTab = 4;
const _vendorProfileTab = 4;
const _driverProfileTab = 3;
const _transportProfileTab = 3;

/// After resetting password when user came from logged-in edit profile — go shell + Profile tab.
void navigateToShellProfileTabForUserType({
  required WidgetRef ref,
  required BuildContext context,
  required String userTypeRaw,
}) {
  final ut = userTypeRaw.toLowerCase().trim();

  if (ut == 'buyer') {
    ref.read(buyerShellTabIndexProvider.notifier).state = _buyerProfileTab;
    context.go(BuyerBottomNavBar.routeName);
    return;
  }
  if (ut == 'vendor') {
    ref.read(vendorShellTabIndexProvider.notifier).state = _vendorProfileTab;
    context.go(VendorBottomNav.routeName);
    return;
  }
  if (ut == 'driver') {
    ref.read(driverNavIndexProvider.notifier).state = _driverProfileTab;
    context.go(DriverBottomNavBar.routeName);
    return;
  }
  if (ut == 'transport') {
    ref.read(transportNavIndexProvider.notifier).state = _transportProfileTab;
    context.go(TransportBottomNavBar.routeName);
    return;
  }
  ref.read(buyerShellTabIndexProvider.notifier).state = _buyerProfileTab;
  context.go(BuyerBottomNavBar.routeName);
}
