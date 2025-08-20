import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/bottom_nav_bar.dart';
import 'package:market_jango/features/buyer/review/review_screen.dart';
import 'package:market_jango/features/buyer/screens/all_categori/screen/all_categori_screen.dart';
import 'package:market_jango/features/buyer/screens/all_categori/screen/category_product_screen.dart';
import 'package:market_jango/features/buyer/screens/buyer_massage/screen/buyer_massage_screen.dart';
import 'package:market_jango/features/buyer/screens/buyer_massage/screen/chat_screen.dart';
import 'package:market_jango/features/buyer/screens/cart/screen/cart_screen.dart';
import 'package:market_jango/features/buyer/screens/notification/screen/notification_screen.dart';
import 'package:market_jango/features/buyer/screens/product/product_details.dart';
import 'package:market_jango/features/buyer/screens/vandor/vandor_profile_screen.dart';
import 'package:market_jango/features/buyer/screens/see_just_for_you_screen.dart';
import 'package:market_jango/features/buyer/screens/see_new_items_screen.dart';
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
import 'package:market_jango/features/transport/screens/transport.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';

final GoRouter router = GoRouter(

  initialLocation: SplashScreen.routeName,
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Error: ${state.error } '),
    ),
  ),



  routes: <RouteBase>[

    //Loging flow
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



    // Auth flow
    GoRoute(path:SplashScreen.routeName,
    name: 'splashScreen',
    builder: (context,state)=>const SplashScreen(),
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
    GoRoute(path:CodeScreen.routeName,
    name: 'codeScreen',
    builder: (context,state)=>const CodeScreen(),
     ),
    GoRoute(path:EmailScreen.routeName,
    name: 'emailScreen',
    builder: (context,state)=>const EmailScreen(),
     ),
    GoRoute(path:PasswordScreen.routeName,
    name: 'passwordScreen',
    builder: (context,state)=>const PasswordScreen(),
     ),
    GoRoute(path:CongratulationScreen.routeName,
    name: 'congratulationScreen',
    builder: (context,state)=>const CongratulationScreen(),
     ),

  // Seller flow
  // This section is for routes related to the seller functionality.
  // Add GoRoute widgets here for seller-specific screens.
  // Example:
  // GoRoute(
  //   path: SellerDashboardScreen.routeName,
  //   name: 'seller_dashboard',
  //   builder: (context, state) => const SellerDashboardScreen(),
  // ),
   GoRoute(
     path:VendorRequestFrom.routeName,
    name: 'vendorRequstFrom',
    builder: (context,state)=>const VendorRequestFrom(),
     ),


    // Settings Flow
    GoRoute(
      path: SettingScreen.routeName,
      name: 'settings_screen',
      builder: (context, state) => const SettingScreen(),
    ),


    // Buyer flow

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
      path: CategoriesScreen.routeName,
      name: CategoriesScreen.routeName,
      builder: (context, state) =>  CategoriesScreen(),
    ),
    GoRoute(
      path: BottomNavBar.routeName,
      name: 'bottom_nav_bar',
      builder: (context, state) => const BottomNavBar(),
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
    ),GoRoute(
      path: CartScreen.routeName,
      name: CartScreen.routeName,
      builder: (context, state) => const CartScreen(),
    ),GoRoute(
      path: CategoryProductScreen.routeName,
      name: CategoryProductScreen.routeName,
      builder: (context, state) => const CategoryProductScreen(),
    ),GoRoute(
      path: VendorProfileScreen.routeName,
      name: VendorProfileScreen.routeName,
      builder: (context, state) => const VendorProfileScreen(),
    ),GoRoute(
      path: ReviewScreen.routeName,
      name: ReviewScreen.routeName,
      builder: (context, state) => const ReviewScreen(),
    ),GoRoute(
      path: ProductDetails.routeName,
      name: ProductDetails.routeName,
      builder: (context, state) => const ProductDetails(),
    ),

    // Transport flow
    // This section is for routes related to the transport functionality.
    // Add GoRoute widgets here for transport-specific screens.
    // Example:
    // GoRoute(
    //   path: TrackOrderScreen.routeName,
    //   name: 'track_order',
    //   builder: (context, state) => const TrackOrderScreen(),
    // ),
    GoRoute(
      path: TransportScreen.routeName,
      name: 'transport',
      builder: (context, state) => const TransportScreen(),
    ),
  ],
);