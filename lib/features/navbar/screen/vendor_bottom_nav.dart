import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/screen/buyer_massage/screen/global_massage_screen.dart';
import 'package:market_jango/core/screen/global_notification/screen/global_notifications_screen.dart';
import 'package:market_jango/core/screen/profile_screen/screen/global_profile_screen.dart';
import 'package:market_jango/features/vendor/screens/vendor_driver_list/screen/vendor_driver_list.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/screen/vendor_home_screen.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class VendorBottomNav extends ConsumerWidget {
  // Changed to ConsumerWidget
  VendorBottomNav({super.key});

  static const String routeName = '/vendor_bottom_nav_bar';

  // Define your pages/screens here
  final List<Widget> _pages = const [
    VendorHomeScreen(),
    GlobalMassageScreen(),
    GlobalNotificationsScreen(),
    // CategoriesScreen(),
    VendorDriverList(),
    GlobalSettingScreen(),
    // VendorSettings(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef
    // Watch the selectedIndexProvider
    final selectedIndex = ref.watch(selectedIndexProvider);

    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          // Update the selected index using the provider's notifier
          ref.read(selectedIndexProvider.notifier).state = index;
        },
        backgroundColor: AllColor.white,
        selectedItemColor: AllColor.orange,
        // Changed to orange
        unselectedItemColor: AllColor.grey,
        type: BottomNavigationBarType.fixed,
        // Keep this if you want fixed labels
        // showSelectedLabels: true, // Optional: ensure selected label is shown
        // showUnselectedLabels: true, // Optional: ensure unselected labels are shown
        items: [
          BottomNavigationBarItem(
            //"Home" 
            label: ref.t(BKeys.home),
            icon: SvgPicture.asset(
              'assets/images/homeicon.svg',
              width: 24,
              height: 24,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            // Kept similar, adjust if needed
            //"Chat" 
            label: ref.t(BKeys.chat),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            // Changed Icon (example for Categories)
            //"Notification" 
            label: ref.t(BKeys.notifications),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.drive_eta), // Changed Icon
            //"Driver", 
            label: ref.t(BKeys.driver),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // Changed Icon
            //"Settings"
            label: ref.t(BKeys.settings),
          ),
        ],
      ),
    );
  }
}
