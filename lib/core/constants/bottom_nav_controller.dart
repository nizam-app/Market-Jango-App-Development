import 'package:get/get.dart';
import 'package:market_jango/features/buyer/screens/buyer_massage/screen/buyer_massage_screen.dart';
import 'package:market_jango/features/buyer/screens/notification/screen/notification_screen.dart';
import 'package:market_jango/features/settings/screens/settings_screen.dart';
import 'package:market_jango/features/buyer/screens/home_screen.dart';
<<<<<<< HEAD
import 'package:market_jango/features/chat/screens/chart_screen.dart';
=======

import 'package:market_jango/features/transport/screens/transport.dart';
>>>>>>> bb3ca8ceb102ea9f84f415a2649e6996b59b68ce

class BottomNavController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  final pages = [
    const BuyerHomeScreen(),
<<<<<<< HEAD
    const ChartScreen(),
    const NotificationsScreen(),
   // const TransportScreen(),
=======
    const BuyerMassageScreen(),
    NotificationsScreen(),
    const TransportScreen(),
>>>>>>> bb3ca8ceb102ea9f84f415a2649e6996b59b68ce
    const SettingScreen(),
  ];
}
