import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:market_jango/core/screen/buyer_massage/screen/global_massage_screen.dart';
import 'package:market_jango/core/screen/profile_screen/screen/global_profile_screen.dart';

import '../../transport/screens/my_booking/screen/transport_booking.dart';
import '../../transport/screens/transport_home.dart';

// --- Providers ---------------------------------------------------------------

// Active tab index
final transportNavIndexProvider = StateProvider<int>((_) => 0);

// Pages (swap with your actual screens)
final transportPagesProvider = Provider<List<Widget>>(
  (_) => const [
    TransportHomeScreen(),
    GlobalMassageScreen(),
    TransportBooking(),
    GlobalSettingScreen(),
  ],
);

// --- Widget ------------------------------------------------------------------

class TransportBottomNavBar extends ConsumerWidget {
  const TransportBottomNavBar({super.key});
  static const String routeName = '/transport_bottom_nav_bar';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = ref.watch(transportPagesProvider);
    final currentIndex = ref.watch(transportNavIndexProvider);

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => ref.read(transportNavIndexProvider.notifier).state = i,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFF8C00),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            label: "Home",
            icon: _SvgIcon('assets/images/homeicon.svg'),
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(
            label: "My Bookings",
            icon: _SvgIcon('assets/images/bookicon.svg'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}

// Helper to use SVG in const BottomNavigationBarItem
class _SvgIcon extends StatelessWidget {
  final String asset;
  const _SvgIcon(this.asset, {super.key});

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset(asset, width: 24, height: 24);
}