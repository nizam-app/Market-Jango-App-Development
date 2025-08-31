import 'package:get/get.dart';
import 'package:market_jango/features/buyer/screens/buyer_massage/screen/buyer_massage_screen.dart';
import 'package:market_jango/features/buyer/screens/notification/screen/notification_screen.dart';
import 'package:market_jango/core/screen/global_profile_screen.dart';
import 'package:market_jango/features/buyer/screens/home_screen.dart';


class BottomNavController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  final pages = [
    const BuyerHomeScreen(),

     NotificationsScreen(),
   // const TransportScreen(),

    const BuyerMassageScreen(),
    NotificationsScreen(),
    const SettingScreen(),
  ];
}