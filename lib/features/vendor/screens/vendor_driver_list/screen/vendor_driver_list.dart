import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/screen/buyer_massage/model/chat_history_route_model.dart';
import 'package:market_jango/core/screen/buyer_massage/screen/global_chat_screen.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/global_pagination.dart';
import 'package:market_jango/features/transport/screens/driver/screen/driver_details_screen.dart';
import 'package:market_jango/features/vendor/screens/vendor_asign_to_order_driver/screen/asign_to_order_driver.dart';
import 'package:market_jango/features/vendor/screens/vendor_driver_list/data/driver_list_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_driver_list/model/driver_list_model.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';

class VendorDriverList extends ConsumerStatefulWidget {
  const VendorDriverList({super.key});
  static const routeName = "/vendorDriverList";

  @override
  ConsumerState<VendorDriverList> createState() => _VendorDriverListState();
}

class _VendorDriverListState extends ConsumerState<VendorDriverList> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driverAsync = ref.watch(driverNotifierProvider);
    final driverNotifier = ref.read(driverNotifierProvider.notifier);
    final searchQuery = _search.text.trim().toLowerCase();
    
    return Scaffold(
      backgroundColor: AllColor.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomBackButton(),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: ref.t(BKeys.searchYourTransporter),
                  hintStyle: TextStyle(color: AllColor.textHintColor),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AllColor.black54,
                  ),
                  filled: true,
                  fillColor: AllColor.grey100,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  enabledBorder: buildOutlineInputBorder(),
                  focusedBorder: buildOutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: driverAsync.when(
                data: (data) {
                  final allDrivers = data?.drivers ?? [];
                  
                  // Filter drivers based on search query
                  final filteredDrivers = allDrivers.where((driver) {
                    if (searchQuery.isEmpty) return true;
                    final name = driver.user.name.toLowerCase();
                    final phone = driver.user.phone.toLowerCase();
                    final location = driver.location.toLowerCase();
                    return name.contains(searchQuery) || 
                           phone.contains(searchQuery) ||
                           location.contains(searchQuery);
                  }).toList();
                  
                  if (filteredDrivers.isEmpty && searchQuery.isNotEmpty) {
                    return Center(
                      child: Text(
                        ref.t(BKeys.no_data),
                        style: TextStyle(color: AllColor.black54),
                      ),
                    );
                  }
                  
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredDrivers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final driver = filteredDrivers[i];
                            return _DriverCard(
                              data: driver,
                              onAssign: () {
                                context.push(
                                  AssignToOrderDriver.routeName,
                                  extra: driver.id,
                                );
                              },
                              onChat: () async {
                                final authStorage = AuthLocalStorage();
                                final userIdStr = await authStorage.getUserId();
                                if (userIdStr == null || userIdStr.isEmpty) {
                                  throw Exception("user id not founde");
                                }
                                final myUserId = int.tryParse(userIdStr);
                                if (myUserId == null) {
                                  throw Exception("Invalid user id");
                                }
                                context.push(
                                  GlobalChatScreen.routeName,
                                  extra: ChatArgs(
                                    partnerId: driver.user.id,
                                    partnerName: driver.user.name,
                                    partnerImage: driver.user.image,
                                    myUserId: myUserId,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      if (data != null && searchQuery.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: GlobalPagination(
                            currentPage: data.currentPage,
                            totalPages: data.lastPage,
                            onPageChanged: (page) {
                              driverNotifier.changePage(page);
                            },
                          ),
                        ),
                    ],
                  );
                },
                loading: () => Center(
                  child: Text(
                    ref.t(BKeys.loading),
                  ),
                ),
                error: (error, stackTrace) =>
                    Center(child: Text(error.toString())),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder buildOutlineInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: AllColor.grey200),
    );
  }
}

/* ===================== MODEL & DEMO DATA ===================== */

// class DriverItem {
//   final String id;
//   final String name;
//   final String phone;
//   final String address;
//   final double price;
//   final String avatarUrl;
//   final bool online;
//   const DriverItem({
//     required this.id,
//     required this.name,
//     required this.phone,
//     required this.address,
//     required this.price,
//     required this.avatarUrl,
//     required this.online,
//   });
// }

// const _drivers = <DriverItem>[
//   DriverItem(
//     id: '1',
//     name: 'Nguyen, Shane',
//     phone: '+00123456789',
//     address: 'australia, road 19 house 1',
//     price: 48,
//     avatarUrl:
//         'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=300',
//     online: true,
//   ),
//   DriverItem(
//     id: '2',
//     name: 'Henry, Arthur',
//     phone: '+00123456789',
//     address: 'australia, road 19 house 1',
//     price: 48,
//     avatarUrl:
//         'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=301',
//     online: true,
//   ),
//   DriverItem(
//     id: '3',
//     name: 'Cooper, Kristin',
//     phone: '+00123456789',
//     address: 'australia, road 19 house 1',
//     price: 48,
//     avatarUrl:
//         'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=300',
//     online: true,
//   ),
//   DriverItem(
//     id: '4',
//     name: 'Black, Marvin',
//     phone: '+00123456789',
//     address: 'australia, road 19 house 1',
//     price: 48,
//     avatarUrl:
//         'https://images.unsplash.com/photo-1544006659-f0b21884ce1d?w=300',
//     online: true,
//   ),
//   DriverItem(
//     id: '5',
//     name: 'Miles, Esther',
//     phone: '+00123456789',
//     address: 'australia, road 19 house 1',
//     price: 48,
//     avatarUrl:
//         'https://images.unsplash.com/photo-1548142813-c348350df52b?w=300',
//     online: true,
//   ),
// ];

/* ===================== CARD WIDGET ===================== */

class _DriverCard extends ConsumerWidget {
  final Driver data;
  final VoidCallback onAssign;
  final VoidCallback onChat;

  const _DriverCard({
    required this.data,
    required this.onAssign,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context, ref ) {
    final onlineColor = Colors.green;

    return GestureDetector(
      onTap: () {
        context.push(DriverDetailsScreen.routeName, extra: data.user.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AllColor.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AllColor.grey200),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 60.h,
                    width: 60.w,
                    color: AllColor.grey100,
                    child: data.user.image.isNotEmpty
                        ? FirstTimeShimmerImage(
                            imageUrl: data.user.image,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AllColor.grey100,
                            child: Icon(Icons.person, color: AllColor.grey),
                          ),
                  ),
                ),
                SizedBox(width: 10.h),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Online pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data.user.name,
                              style: TextStyle(
                                color: AllColor.black,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.h,
                              vertical: 5.w,
                            ),
                            decoration: BoxDecoration(
                              color: onlineColor.withOpacity(.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: onlineColor),
                            ),
                            child: Text(
                              'Online',
                              style: TextStyle(
                                color: onlineColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "014441114451",
                            style: TextStyle(color: AllColor.black54),
                          ),
                          Text(
                            '\$700',
                            style: TextStyle(
                              color: AllColor.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        data.location,
                        style: TextStyle(color: AllColor.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 36.h,
                  child: ElevatedButton(
                    onPressed: onAssign,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AllColor.loginButtomColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.h),
                    ),
                    child: Text(
                      // 'Assign to order',
                      ref.t(BKeys.assignedOrder),
                      style: TextStyle(
                        color: AllColor.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 40.h,
                  width: 40.w,
                  child: Material(
                    color: AllColor.blue500,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onChat,
                      child: Icon(
                        Icons.chat,
                        size: 20.sp,
                        color: AllColor.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
