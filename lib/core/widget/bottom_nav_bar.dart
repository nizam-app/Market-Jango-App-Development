import 'package:flutter/material.dart';
import 'package:market_jango/features/account/screens/account_screen.dart';
import 'package:market_jango/features/buyer/screens/Home%20screen.dart';
import 'package:market_jango/features/categories/screen/categories_screen.dart';
import 'package:market_jango/features/chat/screens/chart_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});
  static const String routeName='/bottom_nav_bar'; 

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {

  final selectedIndex = 0;

  List<Widget> pages = [
    BuyerHomeScreen(),
    ChartScreen(),
    CategoriesScreen(),  
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomNavigationBar(
             // currentIndex: controller.selectedIndex.value,
              backgroundColor: Colors.white,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              //onTap: controller.changeIndex,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.chat_rounded,
                  ),
                  label: "Chart ",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.view_cozy,
                  ),
                  label: "Categories",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person,
                  ),
                  label: "Account",
                ),
              ],
            ),
    );
  }
}