
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_jango/core/constants/bottom_nav_controller.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});
  static const String routeName = '/bottom_nav_bar';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BottomNavController());

    return Obx(() => Scaffold(
          body: controller.pages[controller.selectedIndex.value],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.changeIndex,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.yellow.shade500,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                label: "Chat",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none),
                label: "Notifications ",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping_outlined),
                   label: "Transport",
              ), 
              BottomNavigationBarItem(
                icon: Icon( Icons.settings_outlined,),
                label: "Settings",
              ),
            ],
          ),
        ));
  }
}
