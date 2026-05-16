import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/screen/global_currency/screen/global_currency_screen.dart';
import 'package:market_jango/core/screen/global_language/screen/global_language_screen.dart';
import 'package:market_jango/features/subscription/screen/subscription_screen.dart';
import 'package:market_jango/features/affiliate/screen/affiliate_screen.dart';
import 'package:market_jango/features/ranking/screen/ranking_screen.dart';
import 'package:market_jango/core/screen/google_map/data/location_store.dart';
import 'package:market_jango/core/screen/profile_screen/logic/user_data_update_riverpod.dart';
import 'package:market_jango/core/screen/profile_screen/screen/global_profile_edit_screen.dart';
import 'package:market_jango/core/utils/auth_session_utils.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/buyer/screens/billing/screen/buyer_billing_screen.dart';
import 'package:market_jango/features/buyer/screens/order/screen/buyer_order_history_screen.dart';
import 'package:market_jango/features/driver/screen/deliveries/screen/driver_deliveries_screen.dart';
import 'package:market_jango/features/driver/screen/wallet/screen/driver_wallet_screen.dart';
import 'package:market_jango/features/transport/screens/billing/screen/transport_billing_screen.dart';
import 'package:market_jango/features/transport/screens/wallet/screen/transport_wallet_screen.dart';
import 'package:market_jango/features/buyer/screens/order/screen/buyer_order_page.dart';
import 'package:market_jango/features/buyer/screens/refunds/screen/buyer_refunds_screen.dart';
import 'package:market_jango/features/buyer/screens/wallet/screen/buyer_wallet_screen.dart';
import 'package:market_jango/features/navbar/provider/shell_tab_index_providers.dart';
import '../../../../features/vendor/screens/vendor_my_product_screen.dart/screen/vendor_my_product_screen.dart';
import '../../../../features/vendor/screens/vendor_delivery_setting/screen/vendor_delivery_setting_screen.dart';
import 'package:market_jango/features/vendor/staff_management/screen/vendor_staff_list_screen.dart';
import 'package:market_jango/features/vendor/inventory/screen/vendor_inventory_screen.dart';
import 'package:market_jango/core/utils/get_user_type.dart';
import '../data/profile_data.dart';
import '../model/profile_model.dart';

void _popOrShellHome(BuildContext context, WidgetRef ref) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  ref.read(vendorShellTabIndexProvider.notifier).state = 0;
  ref.read(buyerShellTabIndexProvider.notifier).state = 0;
  ref.read(driverNavIndexProvider.notifier).state = 0;
  ref.read(transportNavIndexProvider.notifier).state = 0;
}

class GlobalSettingScreen extends ConsumerWidget {
  const GlobalSettingScreen({super.key});
  static const String routeName = '/settingsScreen';

  /// Show logout confirmation dialog
  static void _showLogoutConfirmation(BuildContext context) {
    AuthSessionUtils.showLogoutConfirmationDialog(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(
      userProvider(ref.watch(getUserIdProvider).value ?? ""),
    );
    final userTypeAsync = ref.watch(getUserTypeProvider);
    final isDriver = userTypeAsync.value == "driver";

    return ScreenBackground(
      child: userAsync.when(
        data: (user) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover image section for driver (similar to vendor home)
                if (isDriver)
                  buildCoverAndProfileSection(context, ref, user)
                else
                  Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        Tuppertextandbackbutton(
                          screenName: ref.t(BKeys.settings),
                          onBack: () => _popOrShellHome(context, ref),
                        ),
                        SizedBox(height: 16.h),
                        ProfileSection(
                          name: user.name,
                          username: user.email,
                          imageUrl: user.image,
                          userType: user,
                        ),
                        SizedBox(height: 20.h),
                        _buildSettingsContent(
                          context,
                          ref,
                          user,
                          userTypeAsync,
                        ),
                      ],
                    ),
                  ),
                // Settings content
                if (isDriver)
                  Padding(
                    padding: EdgeInsets.all(20.r),
                    child: _buildSettingsContent(
                      context,
                      ref,
                      user,
                      userTypeAsync,
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: Text('Loading...')),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    AsyncValue<String?> userTypeAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // if (!isDriver) SizedBox(height: 12.h),
        // if (!isDriver)
        //   Tuppertextandbackbutton(screenName: ref.t(BKeys.settings)),
        // if (!isDriver) SizedBox(height: 16.h),
        // if (!isDriver)
        //   ProfileSection(
        //     name: user.name,
        //     username: user.email,
        //     imageUrl: user.image,
        //     userType: user,
        //   ),
        // if (!isDriver) SizedBox(height: 5.h),
        _SettingsLine(icon: Icons.phone_in_talk_outlined, text: user.phone),
        _DividerLine(),
        _SettingsLine(icon: Icons.email_outlined, text: user.email),

        SizedBox(height: 12.h),
        _DividerLine(),

        if (userTypeAsync.value == "buyer")
          _SettingsTile(
            leadingIcon: Icons.shopping_bag_outlined,
            // "My Order"
            title: ref.t(BKeys.myOrders),
            onTap: () => context.push(BuyerOrderPage.routeName),
          ),
        if (userTypeAsync.value == "driver") ...[
          _DividerLine(),
          _SettingsTile(
            leadingIcon: Icons.delivery_dining_outlined,
            title: 'Delivery setting',
            onTap: () => context.push(VendorDeliverySettingScreen.routeName),
          ),
          _DividerLine(),
          _SettingsTile(
            leadingIcon: Icons.account_balance_wallet_outlined,
            title: 'Wallet',
            onTap: () => context.push(DriverWalletScreen.routeName),
          ),
          _DividerLine(),
          _SettingsTile(
            leadingIcon: Icons.local_shipping_outlined,
            title: 'My deliveries',
            onTap: () => context.push(DriverDeliveriesScreen.routeName),
          ),
        ],
        if (userTypeAsync.value == "vendor")
          Consumer(
            builder: (context, ref, _) {
              final canProducts = ref.watch(canManageProductsProvider);
              return canProducts.when(
                data: (ok) {
                  if (!ok) return const SizedBox.shrink();
                  return _SettingsTile(
                    leadingIcon: Icons.shopping_bag_outlined,
                    title: ref.t(BKeys.my_product),
                    onTap: () => context.push(VendorMyProductScreen.routeName),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        if (userTypeAsync.value == "vendor")
          Consumer(
            builder: (context, ref, _) {
              final canViewStaff = ref.watch(canViewStaffManagementProvider);
              return canViewStaff.when(
                data: (ok) {
                  if (!ok) return const SizedBox.shrink();
                  return Column(
                    children: [
                      _DividerLine(),
                      _SettingsTile(
                        leadingIcon: Icons.people_alt_outlined,
                        title: 'Staff Management',
                        onTap: () => context.push(VendorStaffListScreen.routeName),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        if (userTypeAsync.value == "vendor") _DividerLine(),
        if (userTypeAsync.value == "vendor")
          _SettingsTile(
            leadingIcon: Icons.inventory_2_outlined,
            title: 'Inventory',
            onTap: () => context.push(VendorInventoryScreen.routeName),
          ),
        _DividerLine(),
        if (userTypeAsync.value == "buyer")
          _SettingsTile(
            leadingIcon: Icons.event_note_outlined,
            // "Order history"
            title: ref.t(BKeys.orderHistory),
            onTap: () => context.push(BuyerOrderHistoryScreen.routeName),
          ),
        _DividerLine(),
        if (userTypeAsync.value == "buyer")
          _SettingsTile(
            leadingIcon: Icons.receipt_long_outlined,
            title: ref.t(BKeys.billing),
            onTap: () => context.push(BuyerBillingScreen.routeName),
          ),
        if (userTypeAsync.value == "buyer")
          _DividerLine(),
               if (userTypeAsync.value == "buyer")
          _SettingsTile(
            leadingIcon: Icons.account_balance_wallet_outlined,
            title: 'Wallet',
            onTap: () => context.push(BuyerWalletScreen.routeName),
          ),
        if (userTypeAsync.value == "buyer")
         _DividerLine(),
           if (userTypeAsync.value == "buyer")
          _SettingsTile(
            leadingIcon: Icons.undo_outlined,
            title: 'Refunds',
            onTap: () => context.push(BuyerRefundsScreen.routeName),
          ),
        if (userTypeAsync.value == "transport")
          _SettingsTile(
            leadingIcon: Icons.receipt_long_outlined,
            title: ref.t(BKeys.billing),
            onTap: () => context.push(TransportBillingScreen.routeName),
          ),
        if (userTypeAsync.value == "transport") _DividerLine(),
        if (userTypeAsync.value == "transport")
          _SettingsTile(
            leadingIcon: Icons.account_balance_wallet_outlined,
            title: 'Wallet',
            onTap: () => context.push(TransportWalletScreen.routeName),
          ),
        _DividerLine(),
        if (userTypeAsync.value == "vendor")
          Consumer(
            builder: (context, ref, _) {
              final isOwner = ref.watch(isVendorOwnerProvider);
              return isOwner.when(
                data: (ok) {
                  if (!ok) return const SizedBox.shrink();
                  return _SettingsTile(
                    leadingIcon: Icons.card_membership_outlined,
                    title: 'Subscription',
                    onTap: () => context.push(SubscriptionScreen.routeName),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        if (userTypeAsync.value == "driver")
          _SettingsTile(
            leadingIcon: Icons.card_membership_outlined,
            title: 'Subscription',
            onTap: () => context.push(SubscriptionScreen.routeName),
          ),
        _DividerLine(),
        if (userTypeAsync.value == "vendor")
          Consumer(
            builder: (context, ref, _) {
              final isOwner = ref.watch(isVendorOwnerProvider);
              return isOwner.when(
                data: (ok) {
                  if (!ok) return const SizedBox.shrink();
                  return _SettingsTile(
                    leadingIcon: Icons.link,
                    title: 'Affiliate Links',
                    onTap: () => context.push(AffiliateScreen.routeName),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        if (userTypeAsync.value == "driver")
          _SettingsTile(
            leadingIcon: Icons.link,
            title: 'Affiliate Links',
            onTap: () => context.push(AffiliateScreen.routeName),
          ),
        if (userTypeAsync.value == "vendor" || userTypeAsync.value == "driver")
          _DividerLine(),
        _SettingsTile(
          leadingIcon: Icons.attach_money,
          title: '${ref.t(BKeys.currency)} (${user.currency ?? 'USD'})',
          onTap: () => context.push(GlobalCurrencyScreen.routeName),
        ),
        _DividerLine(),
        if (userTypeAsync.value == "vendor" || userTypeAsync.value == "driver")
          _SettingsTile(
            leadingIcon: Icons.leaderboard_outlined,
            title: 'Rankings',
            onTap: () => context.push(RankingScreen.routeName),
          ),
        _DividerLine(),
        _SettingsTile(
          leadingIcon: Icons.language_outlined,
          title: ref.t(BKeys.language),
          onTap: () => context.push(GlobalLanguageScreen.routeName),
        ),
        _DividerLine(),
        _SettingsTile(
          leadingIcon: Icons.logout_outlined,
          title: ref.t(BKeys.logOut),
          titleColor: AllColor.orange,
          iconColor: AllColor.orange,
          arrowColor: AllColor.orange,
          onTap: () => GlobalSettingScreen._showLogoutConfirmation(context),
        ),
      ],
    );
  }

  Widget buildCoverAndProfileSection(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) {
    final String? coverImageUrl = user.driver?.coverImage;
    final bool hasCoverImage =
        coverImageUrl != null && coverImageUrl.isNotEmpty;
    final String coverImage = coverImageUrl ?? '';

    return Column(
      children: [
        // Cover image section (Facebook style - at the top, no padding)
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
              child: Container(
                height: 200.h,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.shade200),
                child: hasCoverImage
                    ? FirstTimeShimmerImage(
                        imageUrl: coverImage,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey.shade300,
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 50.r,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: 10.h,
              right: 10.w,
              child: InkWell(
                onTap: () =>
                    _handleCoverImageEdit(context, ref, user.id.toString()),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AllColor.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 16.r,
                        color: AllColor.loginButtomColor,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        hasCoverImage ? 'Edit Cover' : 'Add Cover',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AllColor.loginButtomColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // Profile section positioned below cover image (overlapping like Facebook)
        Transform.translate(
          offset: Offset(0, -41.w), // Move profile image up to overlap cover
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipOval(
                          child: FirstTimeShimmerImage(
                            imageUrl: user.image,
                            width: 82.w,
                            height: 82.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () => _handleProfileImageEdit(
                              context,
                              ref,
                              user.id.toString(),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: AllColor.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AllColor.loginButtomColor,
                                  width: 1.w,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 14.r,
                                color: AllColor.loginButtomColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AllColor.loginButtomColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      onPressed: () {
                        ref.invalidate(selectedLatitudeProvider);
                        ref.invalidate(selectedLongitudeProvider);
                        context.push(
                          BuyerProfileEditScreen.routeName,
                          extra: user,
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.edit_outlined,
                        color: AllColor.loginButtomColor,
                        size: 18.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleCoverImageEdit(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    await _updateCoverImage(
                      context,
                      ref,
                      File(image.path),
                      userId,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    await _updateCoverImage(
                      context,
                      ref,
                      File(image.path),
                      userId,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateCoverImage(
    BuildContext context,
    WidgetRef ref,
    File imageFile,
    String userId,
  ) async {
    try {
      final notifier = ref.read(updateUserProvider.notifier);
      final userTypeAsync = await ref.read(getUserTypeProvider.future);
      final userType = userTypeAsync ?? 'driver';

      final success = await notifier.updateUser(
        userType: userType,
        coverImage: imageFile,
      );

      if (success) {
        if (context.mounted) {
          ref.invalidate(userProvider(userId));
          GlobalSnackbar.show(
            context,
            title: "Success",
            message: "Cover image updated successfully",
          );
        }
      } else {
        if (context.mounted) {
          GlobalSnackbar.show(
            context,
            title: "Error",
            message: "Failed to update cover image",
            type: CustomSnackType.error,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        GlobalSnackbar.show(
          context,
          title: "Error",
          message: e.toString(),
          type: CustomSnackType.error,
        );
      }
    }
  }

  Future<void> _handleProfileImageEdit(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    await _updateProfileImage(
                      context,
                      ref,
                      File(image.path),
                      userId,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    await _updateProfileImage(
                      context,
                      ref,
                      File(image.path),
                      userId,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateProfileImage(
    BuildContext context,
    WidgetRef ref,
    File imageFile,
    String userId,
  ) async {
    try {
      final notifier = ref.read(updateUserProvider.notifier);
      final userTypeAsync = await ref.read(getUserTypeProvider.future);
      final userType = userTypeAsync ?? 'driver';

      final success = await notifier.updateUser(
        userType: userType,
        image: imageFile,
      );

      if (success) {
        if (context.mounted) {
          ref.invalidate(userProvider(userId));
          GlobalSnackbar.show(
            context,
            title: "Success",
            message: "Profile image updated successfully",
          );
        }
      } else {
        if (context.mounted) {
          GlobalSnackbar.show(
            context,
            title: "Error",
            message: "Failed to update profile image",
            type: CustomSnackType.error,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        GlobalSnackbar.show(
          context,
          title: "Error",
          message: e.toString(),
          type: CustomSnackType.error,
        );
      }
    }
  }
}

class SettingTitle extends ConsumerWidget {
  const SettingTitle({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Text(
      // "My Settings",
      ref.t(BKeys.my_settings),
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w800,
        color: AllColor.black,
      ),
    );
  }
}

class ProfileSection extends ConsumerWidget {
  final String name;
  final String username;
  final String imageUrl;
  final UserModel userType;

  const ProfileSection({
    super.key,
    required this.name,
    required this.username,
    required this.imageUrl,
    required this.userType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTypeAsync = ref.watch(getUserTypeProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipOval(
              child: FirstTimeShimmerImage(
                imageUrl: imageUrl,
                width: 52.r,
                height: 52.r,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: -2.h,
              right: -2.w,
              child: Container(
                width: 18.r,
                height: 18.r,
                decoration: BoxDecoration(
                  color: AllColor.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AllColor.black.withOpacity(0.08),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  size: 12.sp,
                  color: AllColor.black,
                ),
              ),
            ),
          ],
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AllColor.black,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    username.length > 20
                        ? '${username.substring(0, 17)}...'
                        : username,
                    style: TextStyle(fontSize: 13.sp, color: AllColor.black),
                  ),
                  SizedBox(width: 8.w),
                  _PrivateBadge(status: userType.status),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            ref.invalidate(selectedLatitudeProvider);
            ref.invalidate(selectedLongitudeProvider);
            if (userTypeAsync.value == "buyer") {
              context.push(BuyerProfileEditScreen.routeName, extra: userType);
            } else if (userTypeAsync.value == "vendor") {
              context.push(BuyerProfileEditScreen.routeName, extra: userType);
            } else if (userTypeAsync.value == "transport") {
              context.push(BuyerProfileEditScreen.routeName, extra: userType);
            } else if (userTypeAsync.value == "driver") {
              context.push(BuyerProfileEditScreen.routeName, extra: userType);
              // Transport
            }
          },

          icon: Icon(Icons.edit_outlined, color: AllColor.black, size: 18.sp),
        ),
      ],
    );
  }
}

class _SettingsLine extends StatelessWidget {
  const _SettingsLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, color: AllColor.black, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                color: AllColor.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.leadingIcon,
    required this.title,
    this.onTap,
    this.titleColor,
    this.iconColor,
    this.arrowColor,
  });

  final IconData leadingIcon;
  final String title;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;
  final Color? arrowColor;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            Icon(leadingIcon, color: iconColor ?? AllColor.black, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: titleColor ?? AllColor.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: arrowColor ?? AllColor.black,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivateBadge extends StatelessWidget {
  final String status;
  const _PrivateBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AllColor.orange,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: AllColor.white,
          fontWeight: FontWeight.w700,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0,
      thickness: 1,
      color: AllColor.grey.withOpacity(0.25),
    );
  }
}
