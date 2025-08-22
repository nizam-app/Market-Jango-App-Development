import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/bottom_nav_bar.dart';
import 'package:market_jango/core/widget/transport_bottom_nav_bar.dart';
import 'package:market_jango/features/auth/screens/car_info.dart';
import 'package:market_jango/features/auth/screens/vendor_request_screen.dart';
import 'package:market_jango/features/settings/screens/settings_screen.dart';
import 'package:market_jango/features/auth/screens/Congratulation.dart';
import 'package:market_jango/features/auth/screens/code_screen.dart';
import 'package:market_jango/features/auth/screens/email_screen.dart';
import 'package:market_jango/features/auth/screens/name_screen.dart';
import 'package:market_jango/features/auth/screens/new_password_screen.dart';
import 'package:market_jango/features/auth/screens/password_screen.dart';
import 'package:market_jango/features/auth/screens/phone_number.dart';
import 'package:market_jango/features/auth/screens/splash_screen.dart';
import 'package:market_jango/features/auth/screens/user.dart';
import 'package:market_jango/features/auth/screens/vendor_request_from.dart';
import 'package:market_jango/features/auth/screens/verification_screen.dart';
import 'package:market_jango/features/notifications/screen/Notifications.dart';
import 'package:market_jango/features/buyer/screens/Filter_screen.dart';
import 'package:market_jango/features/buyer/screens/home_screen.dart';
import 'package:market_jango/features/chat/screens/chart_screen.dart';
import 'package:market_jango/features/transport/screens/add_card_screen.dart';
import 'package:market_jango/features/transport/screens/driver_details_screen.dart';
import 'package:market_jango/features/transport/screens/profile_edit.dart';
import 'package:market_jango/features/transport/screens/transport_booking.dart';
import 'package:market_jango/features/transport/screens/transport_chart.dart';
import 'package:market_jango/features/transport/screens/transport_driver.dart';
import 'package:market_jango/features/transport/screens/transport_home.dart';
import 'package:market_jango/features/transport/screens/transport_notifications.dart';
import 'package:market_jango/features/transport/screens/transport_setting.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: SplashScreen.routeName,
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Error: ${state.error} '))),

  routes: [
    GoRoute(
      path: LoginScreen.routeName,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: ForgotPasswordScreen.routeName,
      name: 'forgot_password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: VerificationScreen.routeName,
      name: 'verification',
      builder: (context, state) => const VerificationScreen(),
    ),
    GoRoute(
      path: NewPasswordScreen.routeName,
      name: 'new_password',
      builder: (context, state) => const NewPasswordScreen(),
    ),

    GoRoute(
      path: SplashScreen.routeName,
      name: 'splashScreen',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: NameScreen.routeName,
      name: 'nameScreen',
      builder: (context, state) => const NameScreen(),
    ),




    GoRoute(
      path: UserScreen.routeName,
      name: 'userScreen',
      builder: (context, state) => const UserScreen(),
    ),
    GoRoute(
      path: PhoneNumberScreen.routeName,
      name: 'phoneNumberScreen',
      builder: (context, state) => const PhoneNumberScreen(),
    ),

    GoRoute(
      path: CodeScreen.routeName,
      name: 'codeScreen',
      builder: (context, state) => const CodeScreen(),
    ),

    GoRoute(
      path: EmailScreen.routeName,
      name: 'emailScreen',
      builder: (context, state) => const EmailScreen(),
    ),

    GoRoute(
      path: PasswordScreen.routeName,
      name: 'passwordScreen',
      builder: (context, state) => const PasswordScreen(),
    ),

    GoRoute(
      path: VendorRequestFrom.routeName,
      name: 'vendorRequstFrom',
      builder: (context, state) => const VendorRequestFrom(),
    ),

    GoRoute(
      path: CongratulationScreen.routeName,
      name: 'congratulationScreen',
      builder: (context, state) => const CongratulationScreen(),
    ),

    GoRoute(
      path: SettingScreen.routeName,
      name: 'settings_screen',
      builder: (context, state) => const SettingScreen(),
    ),

    GoRoute(
      path: ChartScreen.routeName,
      name: 'chart_screen',
      builder: (context, state) => const ChartScreen(),
    ),

    GoRoute(
      path: NotificationsScreen.routeName,
      name: 'notifications_screen',
      builder: (context, state) => const NotificationsScreen(),
    ),

    GoRoute(
      path: BottomNavBar.routeName,
      name: 'bottom_nav_bar',
      builder: (context, state) => const BottomNavBar(),
    ),
    GoRoute(
      path: BuyerHomeScreen.routeName,
      name: 'buyer_home',
      builder: (context, state) => const BuyerHomeScreen(),
    ),

    GoRoute(
      path: NotificationsScreen.routeName,
      name: 'notification_screen',
      builder: (context, state) => NotificationsScreen(),
    ),

    GoRoute(
      path: VendorRequestScreen.routeName,
      name: 'vendor_request',
      builder: (context, state) => VendorRequestScreen(),
    ),

    GoRoute(
      path: CarInfoScreen.routeName,
      name: 'car_info',
      builder: (context, state) => CarInfoScreen(),
    ),

    GoRoute(
      path: FilterScreen.routeName,
      name: 'filter_screen',
      builder: (context, state) => FilterScreen(),
    ),

    GoRoute(
      path: TransportHome.routeName,
      name: 'transport_home',
      builder: (context, state) => TransportHome(),
    ),

    GoRoute(
      path: TransportBottomNavBar.routeName,
      name: 'transport_bottom_nav_bar',
      builder: (context, state) => TransportBottomNavBar(),
    ),

    GoRoute(
      path: TransportChart.routeName,
      name: 'transort_chat',
      builder: (context, state) => TransportChart(),
    ),

    GoRoute(
      path: TransportSetting.routeName,
      name: 'transport_setting',
      builder: (context, state) => TransportSetting(),
    ),

    GoRoute(
      path: TransportBooking.routeName,
      name: 'transport_booking',
      builder: (context, state) => TransportBooking(),
    ),

    GoRoute(
      path: TransportDriver.routeName,
      name: 'transport_driver',
      builder: (context, state) => TransportDriver(),
    ),

    GoRoute(
      path: DriverDetailsScreen.routeName,
      name: 'driverDetails',
      builder: (context, state) => DriverDetailsScreen(),
    ),
    

    GoRoute(
      path: AddCardScreen.routeName,
      name: 'addCard',
      builder: (context, state) => AddCardScreen(),
    ),

    GoRoute(
      path: TransportNotifications.routeName,
      name: 'transport_notificatons',
      builder: (context, state) => TransportNotifications(),
    ),
    GoRoute(
      path: EditProfilScreen.routeName,
      name: 'editProfile',
      builder: (context, state) => EditProfilScreen(),
    ),



  ],
);
