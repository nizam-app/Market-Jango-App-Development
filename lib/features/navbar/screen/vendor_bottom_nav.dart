import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
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
            label: "Home",
            icon: SvgPicture.asset(
              'assets/images/homeicon.svg',
              width: 24,
              height: 24,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            // Kept similar, adjust if needed
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            // Changed Icon (example for Categories)
            label: "Notification",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.drive_eta), // Changed Icon
            label: "Driver",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // Changed Icon
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
