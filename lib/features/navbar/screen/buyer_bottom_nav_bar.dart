import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/screen/buyer_massage/screen/global_massage_screen.dart';
import 'package:market_jango/core/screen/profile_screen/screen/global_profile_screen.dart';
import 'package:market_jango/features/buyer/screens/all_categori/screen/all_categori_screen.dart';
import 'package:market_jango/features/buyer/screens/buyer_home_screen.dart';
import 'package:market_jango/features/buyer/screens/cart/screen/cart_screen.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class BuyerBottomNavBar extends ConsumerWidget {
  const BuyerBottomNavBar({super.key});

  static const String routeName = '/bottom_nav_bar';

  // Define your pages/screens here
  static const List<Widget> _pages = [
    // Replace with your actual screen widgets
    BuyerHomeScreen(),
    // Example: HomeScreen(),
    GlobalMassageScreen(),
    // Example: ChatScreen(),
    CategoriesScreen(),
    // Example: CategoriesScreen(),
    CartScreen(),
    // Example: CartScreen(),
    GlobalSettingScreen(),
    // Example: AccountScreen(),
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
            icon: Icon(Icons.home_filled), // Changed Icon
            label: ref.t(BKeys.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            // Kept similar, adjust if needed
            label: ref.t(BKeys.chat),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets_outlined),
            // Changed Icon (example for Categories)
            label: ref.t(BKeys.categories),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined), // Changed Icon
            label: ref.t(BKeys.cart),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), // Changed Icon
            label: ref.t(BKeys.myProfile),
          ),
        ],
      ),
    );
  }
}
