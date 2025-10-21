import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:market_jango/features/driver/screen/driver_chat.dart';

import '../../driver/screen/driver_home.dart';
import '../../driver/screen/driver_order.dart';
import '../../driver/screen/driver_setting.dart';

// --- Providers ---------------------------------------------------------------

// Active tab index
final driverNavIndexProvider = StateProvider<int>((_) => 0);

// Pages (swap these with your real screens)
final driverPagesProvider = Provider<List<Widget>>((_) => const [
  DriverHomeScreen(),
  DriverChat(),
  DriverOrder(),
  DriverSetting(),
]);

// --- Widget ------------------------------------------------------------------

class DriverBottomNavBar extends ConsumerWidget {
  const DriverBottomNavBar({super.key});
  static const String routeName = '/driver_bottom_nav_bar';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = ref.watch(driverPagesProvider);
    final currentIndex = ref.watch(driverNavIndexProvider);

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => ref.read(driverNavIndexProvider.notifier).state = i,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFF8C00),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            label: "Home",
            icon: _SvgIcon('assets/images/homeicon.svg'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            label: "Order",
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

// Small helper so BottomNavigationBarItem icon is const-friendly
class _SvgIcon extends StatelessWidget {
  final String asset;
  const _SvgIcon(this.asset);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(asset, width: 24, height: 24);
  }
}
