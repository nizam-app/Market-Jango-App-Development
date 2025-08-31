import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:market_jango/core/constants/transport_bottom_nav_controller.dart';

class TransportBottomNavBar extends StatelessWidget {
  const TransportBottomNavBar({super.key});
  static const String routeName = '/transport_bottom_nav_bar';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransportBottomNavController());

    return Obx(
      () => Scaffold(
        body: controller.pages[controller.transportselectedIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.transportselectedIndex.value,
          onTap: controller.changeIndex,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFFFF8C00),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              label: "Home",
              icon: SvgPicture.asset(
                'assets/images/homeicon.svg',
                width: 24,
                height: 24,
              ),
            ),

            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
            BottomNavigationBarItem(
              label: "My Bookings",
              icon: SvgPicture.asset(
                'assets/images/bookicon.svg',
                width: 24,
                height: 24,
              ),
            ),
            
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}
