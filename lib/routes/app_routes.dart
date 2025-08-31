import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/bottom_nav_bar.dart';
import 'package:market_jango/core/widget/driver_bottom_nav_bar.dart';
import 'package:market_jango/core/widget/transport_bottom_nav_bar.dart';
import 'package:market_jango/features/auth/screens/account_request.dart';
import 'package:market_jango/features/auth/screens/car_info.dart';
import 'package:market_jango/features/auth/screens/vendor_request_screen.dart';
import 'package:market_jango/features/buyer/review/review_screen.dart';
import 'package:market_jango/features/buyer/screens/all_categori/screen/all_categori_screen.dart';
import 'package:market_jango/features/buyer/screens/all_categori/screen/category_product_screen.dart';
import 'package:market_jango/features/buyer/screens/buyer_massage/screen/buyer_massage_screen.dart';
import 'package:market_jango/features/buyer/screens/buyer_massage/screen/chat_screen.dart';
import 'package:market_jango/features/buyer/screens/cart/screen/cart_screen.dart';
import 'package:market_jango/features/buyer/screens/notification/screen/notification_screen.dart';
import 'package:market_jango/features/buyer/screens/prement/buyer_payment_screen.dart';
import 'package:market_jango/features/buyer/screens/product/product_details.dart';
import 'package:market_jango/features/buyer/screens/vandor/vandor_profile_screen.dart';
import 'package:market_jango/features/buyer/screens/see_just_for_you_screen.dart';
import 'package:market_jango/features/buyer/screens/see_new_items_screen.dart';
import 'package:market_jango/features/driver/screen/driver_chat.dart';
import 'package:market_jango/features/driver/screen/driver_delivered.dart';
import 'package:market_jango/features/driver/screen/driver_edit_rofile.dart';
import 'package:market_jango/features/driver/screen/driver_home.dart';
import 'package:market_jango/features/driver/screen/driver_notificatons.dart';
import 'package:market_jango/features/driver/screen/driver_ontheway.dart';
import 'package:market_jango/features/driver/screen/driver_order.dart';
import 'package:market_jango/features/driver/screen/driver_order_details.dart';
import 'package:market_jango/features/driver/screen/driver_setting.dart';
import 'package:market_jango/features/driver/screen/driver_traking_screen.dart';
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
import 'package:market_jango/features/buyer/screens/filter/screen/filter_screen.dart';
import 'package:market_jango/features/buyer/screens/home_screen.dart';

import 'package:market_jango/features/vendor/common/main/vendor_bottom_nav.dart';
import 'package:market_jango/features/vendor/screens/product_edit_screen.dart';


import 'package:market_jango/features/transport/screens/add_card_screen.dart';
import 'package:market_jango/features/transport/screens/driver_details_screen.dart';
import 'package:market_jango/features/transport/screens/language_screen.dart';
import 'package:market_jango/features/transport/screens/ongoing_order_screen.dart';
import 'package:market_jango/features/transport/screens/profile_edit.dart';
import 'package:market_jango/features/transport/screens/transport_booking.dart';
import 'package:market_jango/features/transport/screens/transport_cancelled.dart';
import 'package:market_jango/features/transport/screens/transport_cancelled_details.dart';
import 'package:market_jango/features/transport/screens/transport_chart.dart';
import 'package:market_jango/features/transport/screens/transport_competed_details.dart';
import 'package:market_jango/features/transport/screens/transport_completed.dart';
import 'package:market_jango/features/transport/screens/transport_driver.dart';
import 'package:market_jango/features/transport/screens/transport_home.dart';
import 'package:market_jango/features/transport/screens/transport_message.dart';
import 'package:market_jango/features/transport/screens/transport_notifications.dart';
import 'package:market_jango/features/transport/screens/transport_setting.dart';
import 'package:market_jango/features/transport/screens/transport_tracking.dart';
import 'package:market_jango/features/transport/screens/transport_tracking_screen.dart';
import 'package:market_jango/features/vendor/screens/vendor_assigned_order.dart';
import 'package:market_jango/features/vendor/screens/vendor_driver_list.dart';
import 'package:market_jango/features/vendor/screens/vendor_edit_profile.dart';
import 'package:market_jango/features/vendor/screens/vendor_notifications.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_cancel.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_complete.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_pending.dart';
import 'package:market_jango/features/vendor/screens/vendor_sale_platform.dart';
import 'package:market_jango/features/vendor/screens/vendor_settings.dart';
import 'package:market_jango/features/vendor/screens/vendor_transport_screen.dart';

import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: SplashScreen.routeName,
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Error: ${state.error} '))),

  routes: <RouteBase>[
    GoRoute(
      path: LoginScreen.routeName,
      name: 'loginScreen',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: SplashScreen.routeName,
      name: 'splashScreen',
      builder: (context, state) => const SplashScreen(),
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


 
     GoRoute(path:NameScreen.routeName,
    name: 'nameScreen',
    builder: (context,state)=>const NameScreen(),
     ),
    GoRoute(path:UserScreen.routeName,
    name: 'userScreen',
    builder: (context,state)=>const UserScreen(),
     ),
    GoRoute(path:PhoneNumberScreen.routeName,
    name: 'phoneNumberScreen',
    builder: (context,state)=>const PhoneNumberScreen(),
     ),
   
   
    GoRoute(path:PasswordScreen.routeName,
    name: 'passwordScreen',
    builder: (context,state)=>const PasswordScreen(),
     ),

     GoRoute(
      path:AccountRequest.routeName,
      name: 'accountRequest',
      builder: (context,state)=>const AccountRequest(),
     ), 

  
    GoRoute(
      path:VendorBottomNav.routeName,
      name: 'vendorBottomNavBar',
      builder: (context,state)=> VendorBottomNav(),
    ),

    GoRoute(
      path:ProductEditScreen.routeName,
      name: 'vendorProductEdit',
      builder: (context,state)=> ProductEditScreen(),
    ),

   GoRoute(
     path:VendorRequestFrom.routeName,
    name: 'vendorRequstFrom',
    builder: (context,state)=>const VendorRequestFrom(),
     ),


     GoRoute(
     path:VendorRequestScreen.routeName,
    name: 'vendor_request',
    builder: (context,state)=>const VendorRequestScreen(),
     ),

GoRoute(
     path:VendorNotifications.routeName,
    name: 'vendor_notificatons',
    builder: (context,state)=>const VendorNotifications(),
     ),

     GoRoute(
     path:VendorSettings.routeName,
    name: 'vendor_setting',
    builder: (context,state)=>const VendorSettings(),
     ),

     GoRoute(
     path:VendorEditProfile.routeName,
    name: 'vendorEditProfile',
    builder: (context,state)=>const VendorEditProfile(),
     ),

 GoRoute(
     path:VendorTransportScreen.routeName,
    name: 'vendorTransporter',
    builder: (context,state)=>const VendorTransportScreen(),
     ),

     GoRoute(
     path:VendorOrderPending.routeName,
    name: 'vendorOrderPending',
    builder: (context,state)=>const VendorOrderPending(),
     ),

     GoRoute(
     path:VendorAssignedOrder.routeName,
    name: 'vendorOrderAssigned',
    builder: (context,state)=>const VendorAssignedOrder(),
     ),
    
         GoRoute(
     path:VendorOrderComplete.routeName,
    name: 'vendorOrderCompleted',
    builder: (context,state)=>const VendorOrderComplete(),
     ),
 
  GoRoute(
     path:VendorOrderCancel.routeName,
    name: 'vendorOrderCancel',
    builder: (context,state)=>const VendorOrderCancel(),
     ),

      GoRoute(
     path:VendorSalePlatformScreen.routeName,
    name: 'vendorSalePlatform',
    builder: (context,state)=>const VendorSalePlatformScreen(),
     ),

     
      GoRoute(
     path:VendorDriverList.routeName,
    name: 'vendorDriverList',
    builder: (context,state)=>const VendorDriverList(),
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
      path: CongratulationScreen.routeName,
      name: 'congratulationScreen',
      builder: (context, state) => const CongratulationScreen(),
    ),


     GoRoute(
      path: CarInfoScreen.routeName,
      name: 'car_info',
      builder: (context, state) => const CarInfoScreen(),
    ),

  
    // Settings Flow
    GoRoute(
      path: SettingScreen.routeName,
      name: 'settings_screen',
      builder: (context, state) => const SettingScreen(),
    ),

    GoRoute(
      path: BuyerMassageScreen.routeName,
      name: "buyer_massage_screen",
      builder: (context, state) => const BuyerMassageScreen(),
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
      path: TransportMessage.routeName,
      name: 'transort_message',
      builder: (context, state) => TransportMessage(),
    ),

    GoRoute(
      path: TransportTracking.routeName,
      name: 'transport_tracking',
      builder: (context, state) => TransportTracking(),
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
      path: TransportTrackingScreen.routeName,
      name: 'transport_booking3',
      builder: (context, state) => TransportTrackingScreen(),
    ),

    GoRoute(
      path: OngoingOrdersScreen.routeName,
      name: 'ongoingOrders',
      builder: (context, state) => OngoingOrdersScreen(),
    ),

    GoRoute(
      path: TransportCompleted.routeName,
      name: 'completedOrders',
      builder: (context, state) => TransportCompleted(),
    ),

      GoRoute(
      path: TransportCompetedDetails.routeName,
      name: 'completedDetails',
      builder: (context, state) => TransportCompetedDetails(),
    ),

      GoRoute(
      path: TransportCancelled.routeName,
      name: 'cancelledOrders',
      builder: (context, state) => TransportCancelled(),
    ), 

    GoRoute(
      path: TransportCancelledDetails.routeName,
      name: 'cancelledDetails',
      builder: (context, state) => TransportCancelledDetails(),
    ), 


    GoRoute(
      path: LanguageScreen.routeName,
      name: 'language',
      builder: (context, state) => LanguageScreen(),
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

    GoRoute(
      path: CategoriesScreen.routeName,
      name: CategoriesScreen.routeName,
      builder: (context, state) => CategoriesScreen(),
    ),
    GoRoute(
      path: BottomNavBar.routeName,
      name: 'bottom_nav_bar',
      builder: (context, state) => const BottomNavBar(),
    ),

     GoRoute(
      path: DriverBottomNavBar.routeName,
      name: 'driver_bottom_nav_bar',
      builder: (context, state) => const DriverBottomNavBar(),
    ),

     GoRoute(
      path: DriverChat.routeName,
      name: 'driverChat',
      builder: (context, state) => const DriverChat(),
    ),
    
     GoRoute(
      path: DriverOrder.routeName,
      name: 'driverOrder',
      builder: (context, state) => const DriverOrder(),
    ),
    
     GoRoute(
      path: DriverSetting.routeName,
      name: 'driverSetting',
      builder: (context, state) => const DriverSetting(),
    ),
    
     GoRoute(
      path: DriverHome.routeName,
      name: 'driverHome',
      builder: (context, state) => const DriverHome(),
    ),
    
    GoRoute(
      path: OrderDetailsScreen.routeName,
      name: 'orderDetails',
      builder: (context, state) => const OrderDetailsScreen(),
    ),

    GoRoute(
      path: DriverEditProfile.routeName,
      name: 'driverEidtProfile',
      builder: (context, state) => const DriverEditProfile(),
    ),

     GoRoute(
      path: DriverNotificatons.routeName,
      name: 'driverNotifications',
      builder: (context, state) => const DriverNotificatons(),
    ),


     GoRoute(
      path: DriverTrakingScreen.routeName,
      name: 'driverTrackingScreen',
      builder: (context, state) => const  DriverTrakingScreen() ,
    ),

       GoRoute(
      path: DriverDelivered.routeName,
      name: 'driverDelivered',
      builder: (context, state) => const  DriverDelivered() ,
    ),

       GoRoute(
      path: DriverOntheway.routeName,
      name: 'on-the-way',
      builder: (context, state) => const  DriverOntheway() ,
    ),




    GoRoute(
      path: SeeNewItemsScreen.routeName,
      name: SeeNewItemsScreen.routeName,
      builder: (context, state) => const SeeNewItemsScreen(),
    ),
    GoRoute(
      path: SeeJustForYouScreen.routeName,
      name: SeeJustForYouScreen.routeName,
      builder: (context, state) => const SeeJustForYouScreen(),
    ),
    GoRoute(
      path: ChatScreen.routeName,
      name: ChatScreen.routeName,
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: CartScreen.routeName,
      name: CartScreen.routeName,
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: CategoryProductScreen.routeName,
      name: CategoryProductScreen.routeName,
      builder: (context, state) => const CategoryProductScreen(),
    ),
    GoRoute(
      path: VendorProfileScreen.routeName,
      name: VendorProfileScreen.routeName,
      builder: (context, state) => const VendorProfileScreen(),
    ),
    GoRoute(
      path: ReviewScreen.routeName,
      name: ReviewScreen.routeName,
      builder: (context, state) => const ReviewScreen(),
    ),
    GoRoute(
      path: ProductDetails.routeName,
      name: ProductDetails.routeName,
      builder: (context, state) => const ProductDetails(),
    ),GoRoute(
      path: BuyerPaymentScreen.routeName,
      name: BuyerPaymentScreen.routeName,
      builder: (context, state) => const BuyerPaymentScreen(),
    ),
    


  ],
);
