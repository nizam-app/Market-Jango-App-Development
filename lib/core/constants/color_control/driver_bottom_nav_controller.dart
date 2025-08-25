import 'package:get/get.dart';
import 'package:market_jango/features/driver/screen/driver_chat.dart';
import 'package:market_jango/features/driver/screen/driver_home.dart';
import 'package:market_jango/features/driver/screen/driver_order.dart';
import 'package:market_jango/features/driver/screen/driver_setting.dart';

class DriverBottomNavController extends GetxController{
var driverselectedIndex = 0.obs;

  void changeIndex(int index) {
    driverselectedIndex.value = index;
  }

  final pages = [
    const DriverHome(),
    const DriverChat(),
    const DriverOrder(),
    const DriverSetting(),
  ];

}