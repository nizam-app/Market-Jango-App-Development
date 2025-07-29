
import 'package:get/get.dart';
import 'package:market_jango/features/account/screens/account_screen.dart';
import 'package:market_jango/features/buyer/screens/Home%20screen.dart';
import 'package:market_jango/features/categories/screen/categories_screen.dart';
import 'package:market_jango/features/chat/screens/chart_screen.dart';

class BottomNavController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  final pages = [
    const BuyerHomeScreen(),
    const ChartScreen(),
    const CategoriesScreen(),
    const AccountScreen(),
  ];
}
