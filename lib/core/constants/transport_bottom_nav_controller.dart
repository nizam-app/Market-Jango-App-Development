import 'package:get/get.dart';
import 'package:market_jango/features/transport/screens/transport_booking.dart';
import 'package:market_jango/features/transport/screens/transport_chart.dart';
import 'package:market_jango/features/transport/screens/transport_home.dart';
import 'package:market_jango/features/transport/screens/transport_setting.dart';

class TransportBottomNavController extends GetxController{
var transportselectedIndex = 0.obs;

  void changeIndex(int index) {
    transportselectedIndex.value = index;
  }

  final pages = [
    const TransportHome(),
    const TransportChart(),
    const TransportBooking(),
    const TransportSetting(),
  ];

}