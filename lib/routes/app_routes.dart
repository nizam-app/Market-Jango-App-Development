import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/screen/buyer_massage/model/chat_history_route_model.dart';
import 'package:market_jango/core/screen/buyer_massage/screen/global_chat_screen.dart';
import 'package:market_jango/core/screen/buyer_massage/screen/global_massage_screen.dart';
import 'package:market_jango/core/screen/global_language/screen/global_language_screen.dart';
import 'package:market_jango/core/screen/global_notification/screen/global_notifications_screen.dart';
import 'package:market_jango/core/screen/global_tracking_screen_1.dart';
import 'package:market_jango/core/screen/profile_screen/model/profile_model.dart';
import 'package:market_jango/core/screen/profile_screen/screen/global_profile_edit_screen.dart';
import 'package:market_jango/core/screen/profile_screen/screen/global_profile_screen.dart';
import 'package:market_jango/features/auth/screens/Congratulation.dart';
import 'package:market_jango/features/auth/screens/account_request.dart';
import 'package:market_jango/features/auth/screens/car_info_screen.dart';
import 'package:market_jango/features/auth/screens/code_screen.dart';
import 'package:market_jango/features/auth/screens/email_screen.dart';
import 'package:market_jango/features/auth/screens/forget_otp_verification_screen.dart';
import 'package:market_jango/features/auth/screens/name_screen.dart';
import 'package:market_jango/features/auth/screens/new_password_screen.dart';
import 'package:market_jango/features/auth/screens/phone_number_screen.dart';
import 'package:market_jango/features/auth/screens/reset_password_screen.dart';
import 'package:market_jango/features/auth/screens/splash_screen.dart';
import 'package:market_jango/features/auth/screens/user_type_screen.dart';
import 'package:market_jango/features/auth/screens/vendor_request_screen.dart';
import 'package:market_jango/features/buyer/screens/all_categori/screen/all_categori_screen.dart';
import 'package:market_jango/features/buyer/screens/all_categori/screen/category_product_screen.dart';
import 'package:market_jango/features/buyer/screens/buyer_home_screen.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/screen/buyer_vendor_cetagory_screen.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/screen/buyer_vendor_profile_screen.dart';
import 'package:market_jango/features/buyer/screens/cart/screen/cart_screen.dart';
import 'package:market_jango/features/buyer/screens/filter/screen/filter_product_screen.dart';
import 'package:market_jango/features/buyer/screens/order/screen/buyer_order_history_screen.dart';
import 'package:market_jango/features/buyer/screens/order/screen/buyer_order_page.dart';
import 'package:market_jango/features/buyer/screens/prement/screen/buyer_payment_screen.dart';
import 'package:market_jango/features/buyer/screens/product/product_details.dart';
import 'package:market_jango/features/buyer/screens/review/review_screen.dart';
import 'package:market_jango/features/buyer/screens/see_just_for_you_screen.dart';
import 'package:market_jango/features/driver/screen/driver_delivered.dart';
import 'package:market_jango/features/driver/screen/driver_edit_rofile.dart';
import 'package:market_jango/features/driver/screen/driver_home.dart';
import 'package:market_jango/features/driver/screen/driver_ontheway.dart';
import 'package:market_jango/features/driver/screen/driver_order.dart';
import 'package:market_jango/features/driver/screen/driver_order_details.dart';
import 'package:market_jango/features/driver/screen/driver_setting.dart';
import 'package:market_jango/features/driver/screen/driver_traking_screen.dart';
import 'package:market_jango/features/navbar/screen/buyer_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/driver_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/transport_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/vendor_bottom_nav.dart';
import 'package:market_jango/features/transport/screens/add_card_screen.dart';
import 'package:market_jango/features/transport/screens/driver/screen/transport_driver.dart';
import 'package:market_jango/features/transport/screens/driver_details_screen.dart';
import 'package:market_jango/features/transport/screens/ongoing_order_screen.dart';
import 'package:market_jango/features/transport/screens/profile_edit.dart';
import 'package:market_jango/features/transport/screens/transport_booking.dart';
import 'package:market_jango/features/transport/screens/transport_cancelled.dart';
import 'package:market_jango/features/transport/screens/transport_cancelled_details.dart';
import 'package:market_jango/features/transport/screens/transport_competed_details.dart';
import 'package:market_jango/features/transport/screens/transport_completed.dart';
import 'package:market_jango/features/transport/screens/transport_home.dart';
import 'package:market_jango/features/vendor/screens/my_product_color/screen/my_product_color.dart';
import 'package:market_jango/features/vendor/screens/product_edit/screen/product_edit_screen.dart';
import 'package:market_jango/features/vendor/screens/vendor_asign_to_order_driver/screen/asign_to_order_driver.dart';
import 'package:market_jango/features/vendor/screens/vendor_assigned_order/screen/vendor_assigned_order.dart';
import 'package:market_jango/features/vendor/screens/vendor_cancelled_screen/screen/vendor_cancelled_screen.dart';
import 'package:market_jango/features/vendor/screens/vendor_category_add_page/screen/category_add_page.dart';
import 'package:market_jango/features/vendor/screens/vendor_driver_list/screen/vendor_driver_list.dart';
import 'package:market_jango/features/vendor/screens/vendor_my_product_screen.dart/screen/vendor_my_product_screen.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_cancel/screen/vendor_order_cancel.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_complete/screen/vendor_order_complete.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_pending/screen/vendor_order_pending.dart';
import 'package:market_jango/features/vendor/screens/vendor_pending_secrren/screen/vendor_pending_screen.dart';
import 'package:market_jango/features/vendor/screens/vendor_product_other_screen/screen/vendor_product_color_name.dart';
import 'package:market_jango/features/vendor/screens/vendor_profile_edit/screen/vendor_edit_profile.dart';
import 'package:market_jango/features/vendor/screens/vendor_sale_platform/screen/vendor_sale_platform.dart';
import 'package:market_jango/features/vendor/screens/vendor_track_shipment/screen/vendor_track_shipment.dart';
import 'package:market_jango/features/vendor/screens/vendor_transport/screen/vendor_transport_screen.dart';
import 'package:market_jango/features/vendor/screens/vendor_transport_details/screen/vendor_transport_details.dart';

import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login/screen/login_screen.dart';
import '../features/vendor/screens/vendor_home/model/vendor_product_model.dart';
import '../features/vendor/screens/vendor_my_product_size/screen/my_product_size.dart';
import '../features/vendor/screens/vendor_product_add_page/screen/product_add_page.dart';

final GoRouter router = GoRouter(
  initialLocation: BuyerBottomNavBar.routeName,
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Error: ${state.error} '))),

  routes: <RouteBase>[
    GoRoute(
      path: LoginScreen.routeName,
      name: 'loginScreen',
      builder: (context, state) => LoginScreen(),
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
      path: ForgetOTPVerificationScreen.routeName,
      name: 'verification',
      builder: (context, state) => const ForgetOTPVerificationScreen(),
    ),
    GoRoute(
      path: NewPasswordScreen.routeName,
      name: 'new_password',
      builder: (context, state) => const NewPasswordScreen(),
    ),

    GoRoute(
      path: '${NameScreen.routeName}/:role',
      name: NameScreen.routeName,
      builder: (context, state) {
        final role = state.pathParameters['role'] ?? '';
        return NameScreen(roleName: role);
      },
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
      path: ResetPasswordScreen.routeName,
      name: 'passwordScreen',
      builder: (context, state) => const ResetPasswordScreen(),
    ),

    GoRoute(
      path: AccountRequest.routeName,
      name: 'accountRequest',
      builder: (context, state) => const AccountRequest(),
    ),

    GoRoute(
      path: VendorBottomNav.routeName,
      name: 'vendorBottomNavBar',
      builder: (context, state) => VendorBottomNav(),
    ),
    GoRoute(
      path: ProductEditScreen.routeName,
      name: ProductEditScreen.routeName,
      builder: (context, state) {
        final product = state.extra as VendorProduct;
        return ProductEditScreen(product: product);
      },
    ),

    // GoRoute(
    //   path:VendorRequestForm.routeName,
    //  name: VendorRequestForm.routeName,
    //  builder: (context,state)=>const VendorRequestForm(),
    //   ),
    GoRoute(
      path: VendorRequestScreen.routeName,
      name: 'vendor_request',
      builder: (context, state) => const VendorRequestScreen(),
    ),

    GoRoute(
      path: GlobalNotificationsScreen.routeName,
      name: 'vendor_notificatons',
      builder: (context, state) => const GlobalNotificationsScreen(),
    ),

    GoRoute(
      path: VendorEditProfile.routeName,
      name: 'vendorEditProfile',
      builder: (context, state) {
        UserModel userType = state.extra as UserModel;
        return VendorEditProfile(userType: userType);
      },
    ),

    GoRoute(
      path: VendorTransportScreen.routeName,
      name: 'vendorTransporter',
      builder: (context, state) => const VendorTransportScreen(),
    ),

    GoRoute(
      path: VendorOrderPending.routeName,
      name: 'vendorOrderPending',
      builder: (context, state) => const VendorOrderPending(),
    ),

    GoRoute(
      path: AsignToOrderDriver.routeName,
      name: 'assign_order_driver',
      builder: (context, state) => const AsignToOrderDriver(),
    ),

    GoRoute(
      path: VendorAssignedOrder.routeName,
      name: 'vendorOrderAssigned',
      builder: (context, state) => const VendorAssignedOrder(),
    ),

    GoRoute(
      path: VendorOrderComplete.routeName,
      name: 'vendorOrderCompleted',
      builder: (context, state) => const VendorOrderComplete(),
    ),

    GoRoute(
      path: VendorOrderCancel.routeName,
      name: 'vendorOrderCancel',
      builder: (context, state) => const VendorOrderCancel(),
    ),

    GoRoute(
      path: VendorSalePlatformScreen.routeName,
      name: 'vendorSalePlatform',
      builder: (context, state) => const VendorSalePlatformScreen(),
    ),

    GoRoute(
      path: VendorDriverList.routeName,
      name: 'vendorDriverList',
      builder: (context, state) => const VendorDriverList(),
    ),

    GoRoute(
      path: VendorTransportDetails.routeName,
      name: 'vendorTransportDetails',
      builder: (context, state) => const VendorTransportDetails(),
    ),

    GoRoute(
      path: VendorShipmentsScreen.routeName,
      name: 'vendortrack_shipments',
      builder: (context, state) => const VendorShipmentsScreen(),
    ),

    GoRoute(
      path: VendorPendingScreen.routeName,
      name: 'vendorPendingScreen',
      builder: (context, state) => const VendorPendingScreen(),
    ),

    GoRoute(
      path: VendorCancelledScreen.routeName,
      name: 'vendorCancelledScreen',
      builder: (context, state) => const VendorCancelledScreen(),
    ),

    GoRoute(
      path: VendorMyProductScreen.routeName,
      name: VendorMyProductScreen.routeName,
      builder: (context, state) => const VendorMyProductScreen(),
    ),

    GoRoute(
      path: VendorProductColorName.routeName,
      name: 'vendorProductColorName',
      builder: (context, state) => VendorProductColorName(),
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
      path: GlobalSettingScreen.routeName,
      name: GlobalSettingScreen.routeName,
      builder: (context, state) => const GlobalSettingScreen(),
    ),

    GoRoute(
      path: GlobalMassageScreen.routeName,
      name: "buyer_massage_screen",
      builder: (context, state) => const GlobalMassageScreen(),
    ),

    GoRoute(
      path: BuyerHomeScreen.routeName,
      name: 'buyer_home',
      builder: (context, state) => const BuyerHomeScreen(),
    ),

    GoRoute(
      path: FilterScreen.routeName,
      name: 'filter_screen',
      builder: (context, state) => FilterScreen(),
    ),

    GoRoute(
      path: TransportHomeScreen.routeName,
      name: 'transport_home',
      builder: (context, state) => TransportHomeScreen(),
    ),

    GoRoute(
      path: TransportBottomNavBar.routeName,
      name: 'transport_bottom_nav_bar',
      builder: (context, state) => TransportBottomNavBar(),
    ),

    // GoRoute(
    //   path: TransportChart.routeName,
    //   name: 'transort_chat',
    //   builder: (context, state) => TransportChart(),
    // ),
    GoRoute(
      path: GlobalTrackingScreen1.routeName,
      name: GlobalTrackingScreen1.routeName,
      builder: (context, state) {
        // primary: extra থেকে পার্স
        final extra = state.extra;
        if (extra is TrackingArgs) {
          return GlobalTrackingScreen1(
            screenName: extra.screenName,
            startAdvanced: extra.startAdvanced,
            autoAdvance: extra.autoAdvance,
          );
        }

        // fallback: query/path থেকে পার্স (যদি extra না দেও)
        bool _b(String? v, bool def) {
          if (v == null) return def;
          final s = v.toLowerCase();
          return s == 'true' || s == '1';
        }

        String _s(String key, {String def = 'Tracking'}) {
          return state.uri.queryParameters[key] ??
              state.pathParameters[key] ??
              def;
        }

        return GlobalTrackingScreen1(
          screenName: _s('screenName'),
          startAdvanced: _b(state.uri.queryParameters['startAdvanced'], false),
          autoAdvance: _b(state.uri.queryParameters['autoAdvance'], true),
        );
      },
    ),

    // GoRoute(
    //   path: TransportSetting.routeName,
    //   name: 'transport_setting',
    //   builder: (context, state) => TransportSetting(),
    // ),
    GoRoute(
      path: TransportBooking.routeName,
      name: 'transport_booking',
      builder: (context, state) => TransportBooking(),
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
      path: GlobalLanguageScreen.routeName,
      name: 'language',
      builder: (context, state) => GlobalLanguageScreen(),
    ),

    GoRoute(
      path: TransportDriver.routeName,
      name: 'transport_driver',
      builder: (context, state) => TransportDriver(),
    ),

    GoRoute(
      path: DriverDetailsScreen.routeName,
      name: 'driverDetails',
      builder: (context, state) {
        return DriverDetailsScreen(driverId: state.extra as int);
      },
    ),

    GoRoute(
      path: AddCardScreen.routeName,
      name: 'addCard',
      builder: (context, state) => AddCardScreen(),
    ),

    GoRoute(
      path: EditProfilScreen.routeName,
      name: 'editProfile',
      builder: (context, state) => EditProfilScreen(),
    ),

    GoRoute(
      path: CategoriesScreen.routeName,
      name: CategoriesScreen.routeName,
      builder: (context, state) {
        // final categories = state.extra as CategoryResponse;

        return CategoriesScreen();
      },
    ),
    GoRoute(
      path: BuyerBottomNavBar.routeName,
      name: 'bottom_nav_bar',
      builder: (context, state) => const BuyerBottomNavBar(),
    ),

    GoRoute(
      path: DriverBottomNavBar.routeName,
      name: 'driver_bottom_nav_bar',
      builder: (context, state) => const DriverBottomNavBar(),
    ),

    // GoRoute(
    //   path: DriverChat.routeName,
    //   name: 'driverChat',
    //   builder: (context, state) => const DriverChat(),
    // ),
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
      path: DriverHomeScreen.routeName,
      name: 'driverHome',
      builder: (context, state) => const DriverHomeScreen(),
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
      path: DriverTrakingScreen.routeName,
      name: 'driverTrackingScreen',
      builder: (context, state) => const DriverTrakingScreen(),
    ),

    GoRoute(
      path: DriverDelivered.routeName,
      name: 'driverDelivered',
      builder: (context, state) => const DriverDelivered(),
    ),

    GoRoute(
      path: DriverOntheway.routeName,
      name: 'on-the-way',
      builder: (context, state) => const DriverOntheway(),
    ),

    GoRoute(
      path: SeeJustForYouScreen.routeName,
      name: SeeJustForYouScreen.routeName,
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        final screenName = extras['screenName'] as String;
        final url = extras['url'] as String;
        return SeeJustForYouScreen(screenName: screenName, url: url);
      },
    ),
    GoRoute(
      path: ChatScreen.routeName, // "/chatScreen"
      name: ChatScreen.routeName,
      builder: (context, state) {
        final args = state.extra as ChatArgs;
        return ChatScreen(
          partnerId: args.partnerId,
          partnerName: args.partnerName,
          partnerImage: args.partnerImage,
          myUserId: args.myUserId,
        );
      },
    ),

    GoRoute(
      path: CartScreen.routeName,
      name: CartScreen.routeName,
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: CategoryProductScreen.routeName,
      name: CategoryProductScreen.routeName,
      builder: (context, state) =>
          CategoryProductScreen(categoryVendorId: state.extra as int),
    ),
    GoRoute(
      path: BuyerVendorProfileScreen.routeName,
      name: BuyerVendorProfileScreen.routeName,
      builder: (context, state) =>
          BuyerVendorProfileScreen(vendorId: state.extra as int),
    ),
    GoRoute(
      path: ReviewScreen.routeName,
      name: ReviewScreen.routeName,
      builder: (context, state) => const ReviewScreen(),
    ),
    GoRoute(
      path: ProductDetails.routeName,
      name: ProductDetails.routeName,
      builder: (context, state) =>
          ProductDetails(productId: state.extra as int),
    ),
    GoRoute(
      path: BuyerPaymentScreen.routeName,
      name: BuyerPaymentScreen.routeName,
      builder: (context, state) => BuyerPaymentScreen(),
    ),
    GoRoute(
      path: BuyerProfileEditScreen.routeName,
      name: BuyerProfileEditScreen.routeName,
      builder: (context, state) {
        final userData = state.extra as UserModel;
        return BuyerProfileEditScreen(user: userData);
      },
    ),
    GoRoute(
      path: BuyerOrderPage.routeName,
      name: BuyerOrderPage.routeName,
      builder: (context, state) => BuyerOrderPage(),
    ),
    GoRoute(
      path: BuyerOrderHistoryScreen.routeName,
      name: BuyerOrderHistoryScreen.routeName,
      builder: (context, state) => BuyerOrderHistoryScreen(),
    ),
    GoRoute(
      path: MyProductColorScreen.routeName,
      name: MyProductColorScreen.routeName,
      builder: (context, state) => MyProductColorScreen(),
    ),
    GoRoute(
      path: MyProductSizeScreen.routeName,
      name: MyProductSizeScreen.routeName,
      builder: (context, state) => MyProductSizeScreen(),
    ),
    GoRoute(
      path: ProductAddPage.routeName,
      name: ProductAddPage.routeName,
      builder: (context, state) => ProductAddPage(),
    ),
    GoRoute(
      path: CategoryAddPage.routeName,
      name: CategoryAddPage.routeName,
      builder: (context, state) => CategoryAddPage(),
    ),
    GoRoute(
      path: '${BuyerVendorCetagoryScreen.routeName}/:screenName',
      name: BuyerVendorCetagoryScreen.routeName, // তুমি pushNamed-ও করতে পারবে

      builder: (context, state) {
        final screenName = state.pathParameters['screenName'] ?? '';

        // extra থেকে vendorId সেফলি ধরছি
        int vendorId = 0;
        final extra = state.extra;
        if (extra is int) {
          vendorId = extra;
        } else if (extra is Map && extra['vendorId'] is int) {
          vendorId = extra['vendorId'] as int;
        }

        if (screenName.isEmpty || vendorId == 0) {
          return const Scaffold(
            body: Center(child: Text('Invalid route data')),
          );
        }

        return BuyerVendorCetagoryScreen(
          screenName: screenName,
          vendorId: vendorId,
        );
      },
    ),
  ],
);
