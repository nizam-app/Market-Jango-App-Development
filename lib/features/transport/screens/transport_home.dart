// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:http/http.dart' as http;

// // -------- MODEL --------
// class DriverModel {
//   final int id;
//   final String name;
//   final String car;
//   final String imageUrl;
//   final double pricePerKm;

//   DriverModel({
//     required this.id,
//     required this.name,
//     required this.car,
//     required this.imageUrl,
//     required this.pricePerKm,
//   });

//   factory DriverModel.fromJson(Map<String, dynamic> json) {
//     return DriverModel(
//       id: json["id"],
//       name: json["name"],
//       car: json["car"],
//       imageUrl: json["imageUrl"],
//       pricePerKm: (json["pricePerKm"] as num).toDouble(),
//     );
//   }
// }

// // -------- API SERVICE --------
// class DriverService {
//   static Future<List<DriverModel>> fetchDrivers() async {
//     // 🔹 Replace this URL with your real API
//     final url = Uri.parse("https://mocki.io/v1/5d6e3f84-31e7-4a91-9e7d-6f642a2ffbd6");

//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       final List data = jsonDecode(response.body);
//       return data.map((e) => DriverModel.fromJson(e)).toList();
//     } else {
//       throw Exception("Failed to load drivers");
//     }
//   }
// }

// // -------- TRANSPORT HOME SCREEN --------
// class TransportHome extends StatelessWidget {
//   const TransportHome({super.key});
//   static const String routeName = '/transport_home';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(16.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// Header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Hello, Jane Cooper 👋",
//                     style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
//                   ),
//                   Icon(Icons.notifications_none, size: 24.sp),
//                 ],
//               ),
//               SizedBox(height: 20.h),

//               /// Search Fields
//               TextField(
//                 decoration: InputDecoration(
//                   hintText: "Search by vendor name",
//                   prefixIcon: Icon(Icons.search),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 10.h),

//               Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   height: 2,
//                   width: 160,
//                   color:Colors.grey,
//                 ),
//                 Text("Or", style: TextStyle(fontSize: 16.sp)),
//                  Container(
//                   height: 2,
//                   width: 160,
//                   color:Colors.grey,
//                 ),
//               ],
//             ),
//                SizedBox(height: 10.h),
//               Column(
//                 children: [

//                     TextField(
//                       decoration: InputDecoration(
//                         hintText: "Enter Pickup location",
//                         prefixIcon: Icon(Icons.location_on_outlined),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                       ),
//                     ),

//                   SizedBox(height: 10.h),

//                     TextField(
//                       decoration: InputDecoration(
//                         hintText: "Destination",
//                         prefixIcon: Icon(Icons.flag_outlined),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                       ),
//                     ),

//                 ],
//               ),
//               SizedBox(height: 10.h),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 14.h),
//                     backgroundColor: Colors.blue,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                   ),
//                   onPressed: () {},
//                   child: Text("Search", style: TextStyle(fontSize: 16.sp)),
//                 ),
//               ),
//               SizedBox(height: 20.h),

//               /// Drivers section header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Drivers",
//                     style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
//                   ),
//                   TextButton(onPressed: () {}, child: const Text("See all")),
//                 ],
//               ),

//               /// Drivers List (API)
//               Expanded(
//                 child: FutureBuilder<List<DriverModel>>(
//                   future: DriverService.fetchDrivers(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return Center(child: Text("Error: ${snapshot.error}"));
//                     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                       return const Center(child: Text("No drivers available"));
//                     }

//                     final drivers = snapshot.data!;
//                     return ListView.builder(
//                       itemCount: drivers.length,
//                       itemBuilder: (context, index) {
//                         return DriverCard(driver: drivers[index]);
//                       },
//                     );
//                   },
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 0,
//         onTap: (i) {},
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//         ],
//       ),
//     );
//   }
// }

// // -------- DRIVER CARD --------
// class DriverCard extends StatelessWidget {
//   final DriverModel driver;
//   const DriverCard({super.key, required this.driver});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.only(bottom: 16.h),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       child: Padding(
//         padding: EdgeInsets.all(12.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// Driver Info
//             Row(
//               children: [
//                 CircleAvatar(radius: 20.r, backgroundImage: NetworkImage(driver.imageUrl)),
//                 SizedBox(width: 10.w),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(driver.name,
//                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
//                     Text(driver.car,
//                         style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
//                   ],
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade50,
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   child: Text(
//                     "\$${driver.pricePerKm}/km",
//                     style: TextStyle(
//                         color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 12.sp),
//                   ),
//                 )
//               ],
//             ),
//             SizedBox(height: 10.h),

//             /// Car Image
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12.r),
//               child: Image.network(
//                 "https://pngimg.com/uploads/porsche/porsche_PNG10613.png",
//                 height: 120.h,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             SizedBox(height: 10.h),

//             /// Action Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.orange,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                 ),
//                 onPressed: () {},
//                 child: Text("See details",
//                     style: TextStyle(color: Colors.white, fontSize: 14.sp)),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/global_notification_icon.dart';
import 'package:market_jango/features/transport/screens/driver/screen/transport_driver.dart';
import 'package:market_jango/features/transport/screens/driver_details_screen.dart';

import 'driver/data/transport_driver_data.dart';
import 'driver/screen/model/transport_driver_model.dart';

class TransportHomeScreen extends ConsumerWidget {
  const TransportHomeScreen({super.key});
  static const String routeName = '/transport_home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(approvedDriversProvider);
    return Scaffold(
      backgroundColor: Color(0xFFF5F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, Jane Cooper",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    InkWell(
                      onTap: () {
                        context.push("/transport_notificatons");
                      },
                      child: Icon(
                        Icons.verified,
                        size: 20.sp,
                        color: AllColor.blue500,
                      ),
                    ),
                    Spacer(),
                    GlobalNotificationIcon(),
                  ],
                ),
                Text("Find your Driver", style: TextStyle(fontSize: 10.sp)),
                SizedBox(height: 20.h),

                /// Search Fields
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search (white bg)
                    _softField(
                      hint: "Search by vendor name",
                      icon: Icons.search,
                      bg: Colors.white, // image-2 এ সার্চটা সাদা
                    ),
                    SizedBox(height: 12.h),

                    // Or divider (পাতলা গ্রে)
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: const Color(0xFFE5E7EB),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(
                            "Or",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: const Color(0xFFE5E7EB),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Pickup (light grey bg)
                    _softField(
                      hint: "Enter Pickup location",
                      icon: Icons.location_on_outlined,
                      bg: AllColor.grey300, // হালকা ধূসর
                    ),
                    SizedBox(height: 10.h),

                    // Destination (light grey bg)
                    _softField(
                      hint: "Destination",
                      icon: Icons.flag_outlined,
                      bg: AllColor.grey300,
                    ),
                  ],
                ),

                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Search",
                      style: TextStyle(fontSize: 16.sp, color: AllColor.white),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                /// Drivers section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Drivers",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push(TransportDriver.routeName);
                      },
                      child: const Text("See all"),
                    ),
                  ],
                ),

                /// Driver Cards (ListView → Column with .map)
                state.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Text('Failed to load drivers'),
                    ),
                  ),
                  data: (resp) {
                    final page = resp?.data;
                    final items = page?.data ?? <Driver>[];

                    if (items.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(top: 20.h),
                        child: const Text('No drivers available'),
                      );
                    }
                    final homeItems = items.take(10).toList();

                    return Column(
                      children: homeItems
                          .map(
                            (d) => _DriverCard(
                              driver: d,
                              images: (d.images is List)
                                  ? (d.images as List)
                                        .whereType<String>()
                                        .toList()
                                  : <String>[],
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _softField({required String hint, required IconData icon, Color? bg}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF9BA0A6), // নরম ধূসর হিন্ট
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF8E8E93)),
        isDense: true,
        filled: true,
        fillColor: bg ?? const Color(0xFFF3F4F6),
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),

        // বর্ডার = পাতলা গ্রে, রাউন্ডেড
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
    );
  }
}

/// Driver Card
class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.driver, required this.images});

  final Driver driver;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final user = driver.user;

    // Safe fallbacks
    final avatarUrl = (user.image?.isNotEmpty == true)
        ? user.image!
        : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTxfenNzfIFlwE5dd7aduVOvGR05Qqz7EDi-Q&s";

    final carUrl = images.isNotEmpty
        ? images.first
        : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTxfenNzfIFlwE5dd7aduVOvGR05Qqz7EDi-Q&s";

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Driver Info
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Logger().i(user.id);
                    context.push(DriverDetailsScreen.routeName, extra: driver.userId);
                  },
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundImage: NetworkImage(avatarUrl),
                  ),
                ),
                SizedBox(width: 10.w),
                InkWell(
                  onTap: () {
                    Logger().i(user.id);
                    context.push(DriverDetailsScreen.routeName, extra: driver.userId);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        "${user.phone}",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "\$${driver.price}/km",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            /// Car Image (safe)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: FirstTimeShimmerImage(
                  imageUrl: carUrl,
                  height: 120.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${driver.carName} • ${driver.location}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Logger().e(driver.id);
                      context.push(
                      DriverDetailsScreen.routeName,
                      extra: driver.userId,
                    );},
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Text(
                        "See Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}