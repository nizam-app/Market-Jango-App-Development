
import 'package:get/get.dart';
import 'package:market_jango/features/settings/screens/settings_screen.dart';
import 'package:market_jango/features/buyer/screens/Home%20screen.dart';
import 'package:market_jango/features/notifications/screen/Notifications.dart';
import 'package:market_jango/features/chat/screens/chart_screen.dart';
import 'package:market_jango/features/transport/screens/transport.dart';

class BottomNavController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  final pages = [
    const BuyerHomeScreen(),
    const ChartScreen(),
    const NotificationsScreen(),
     const TransportScreen(),
    const SettingScreen(),
   
  ];
}
