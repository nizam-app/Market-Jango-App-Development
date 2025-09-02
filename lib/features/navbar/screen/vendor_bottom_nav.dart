
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/buyer/screens/buyer_massage/screen/buyer_massage_screen.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/screen/vendor_home_screen.dart';
import 'package:market_jango/features/vendor/screens/vendor_notification/screen/vendor_notifications.dart';
import 'package:market_jango/features/vendor/screens/vendor_setting/screen/vendor_settings.dart';
import 'package:market_jango/features/vendor/screens/vendor_transport/screen/vendor_transport_screen.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class VendorBottomNav extends ConsumerWidget {
  // Changed to ConsumerWidget
  VendorBottomNav({super.key});

  static const String routeName = '/vendor_bottom_nav_bar';


  // Define your pages/screens here
  final List<Widget> _pages = const [
    
    VendorHomeScreen(),
    BuyerMassageScreen(),
    VendorNotifications(),
   // CategoriesScreen(),
   VendorTransportScreen(),
    VendorSettings(),
   
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
          ref
              .read(selectedIndexProvider.notifier)
              .state = index;
        },
        backgroundColor: AllColor.white,
        selectedItemColor: AllColor.orange,
        // Changed to orange
        unselectedItemColor: AllColor.grey,
        type: BottomNavigationBarType.fixed,
        // Keep this if you want fixed labels
        // showSelectedLabels: true, // Optional: ensure selected label is shown
        // showUnselectedLabels: true, // Optional: ensure unselected labels are shown
        items:  [
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
            icon: Icon(Icons.emoji_transportation), // Changed Icon
            label: "Transport",
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