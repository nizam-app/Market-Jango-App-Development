import 'package:get/get.dart';
import 'package:market_jango/features/buyer/screens/buyer_massage_screen.dart';
import 'package:market_jango/features/buyer/screens/notification_screen.dart';
import 'package:market_jango/features/settings/screens/settings_screen.dart';
import 'package:market_jango/features/buyer/screens/home_screen.dart';

import 'package:market_jango/features/transport/screens/transport.dart';

class BottomNavController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  final pages = [
    const BuyerHomeScreen(),
    const BuyerMassageScreen(),
    NotificationsScreen(),
    const TransportScreen(),
    const SettingScreen(),
  ];
}
