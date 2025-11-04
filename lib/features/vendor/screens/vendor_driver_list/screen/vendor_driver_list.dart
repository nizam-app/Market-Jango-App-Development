import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/global_pagination.dart';
import 'package:market_jango/features/vendor/screens/vendor_driver_list/data/driver_list_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_driver_list/model/driver_list_model.dart';

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
    // final filtered = _drivers.where((d) {
    //   final q = _search.text.trim().toLowerCase();
    //   if (q.isEmpty) return true;
    //   return d.name.toLowerCase().contains(q) || d.phone.contains(q);
    // }).toList();
    final driverAsync = ref.watch(driverNotifierProvider);
    final driverNotifier = ref.read(driverNotifierProvider.notifier);
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
                  hintText: 'Search you transporter',
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

            driverAsync.when(
              data: (data) {
                final drivers = data?.drivers ?? [];
                return SizedBox(
                  height: 1.62.sw,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                          physics: const BouncingScrollPhysics(),
                          itemCount: drivers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _DriverCard(
                            data: drivers[i],
                            onAssign: () {
                              context.push("/assign_order_driver");

                            },
                            onChat: () {
                              context.push("/vendorTransportDetails");
                            },
                          ),
                        ),

                      ),
                      SizedBox(height: 20.h,),
                      if (data != null)
                        GlobalPagination(
                          currentPage: data.currentPage ?? 1,
                          totalPages: data.lastPage ?? 1,
                          onPageChanged: (page) {
                            driverNotifier.changePage(page);
                          },
                        )
                    ],
                  ),
                );
              }  ,
              loading: () => const Center(child: Text("Loading...")),
              error: (error, stackTrace) => Center(child: Text(error.toString())),
            ), ]
        )
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

class _DriverCard extends StatelessWidget {
  final Driver data;
  final VoidCallback onAssign;
  final VoidCallback onChat;

  const _DriverCard({
    required this.data,
    required this.onAssign,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final onlineColor = Colors.green;

    return Container(
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
                  child: Image.network("", fit: BoxFit.cover),
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
                    'Assign to order',
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
    );
  }
}