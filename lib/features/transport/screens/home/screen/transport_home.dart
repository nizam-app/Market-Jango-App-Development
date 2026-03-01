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
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/screen/profile_screen/data/profile_data.dart';
import 'package:market_jango/core/utils/get_user_type.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/global_notification_icon.dart';
import 'package:market_jango/features/transport/screens/booking_confirm/transport_booking_confirm_screen.dart';
import 'package:market_jango/features/transport/screens/driver/screen/driver_details_screen.dart';
import 'package:market_jango/features/transport/screens/driver/screen/transport_See_all_driver.dart';

import '../../driver/data/transport_driver_data.dart';
import '../../driver/screen/model/transport_driver_model.dart';

class TransportHomeScreen extends ConsumerStatefulWidget {
  const TransportHomeScreen({super.key});
  static const String routeName = '/transport_home';

  @override
  ConsumerState<TransportHomeScreen> createState() => _TransportHomeScreenState();
}

/// Transport type options for shipping (motorcycle / car / air / water)
enum TransportType {
  motorcycle,
  car,
  air,
  water,
}

class _TransportHomeScreenState extends ConsumerState<TransportHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  String _searchQuery = '';
  TransportType? _selectedTransportType;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  bool _driverMatchesTransportType(Driver driver, TransportType type) {
    final carName = driver.carName.toLowerCase();
    final carModel = driver.carModel.toLowerCase();
    final combined = '$carName $carModel';
    switch (type) {
      case TransportType.motorcycle:
        return combined.contains('motorcycle') ||
            combined.contains('bike') ||
            combined.contains('moto');
      case TransportType.car:
        return combined.contains('car') ||
            combined.contains('vehicle') ||
            combined.contains('sedan') ||
            combined.contains('suv') ||
            combined.contains('truck');
      case TransportType.air:
        return combined.contains('air') ||
            combined.contains('plane') ||
            combined.contains('flight') ||
            combined.contains('cargo');
      case TransportType.water:
        return combined.contains('water') ||
            combined.contains('ship') ||
            combined.contains('boat') ||
            combined.contains('sea');
    }
  }

  String _transportTypeLabel(WidgetRef ref, TransportType type) {
    switch (type) {
      case TransportType.motorcycle:
        return ref.t(BKeys.transport_type_motorcycle);
      case TransportType.car:
        return ref.t(BKeys.transport_type_car);
      case TransportType.air:
        return ref.t(BKeys.transport_type_air);
      case TransportType.water:
        return ref.t(BKeys.transport_type_water);
    }
  }

  List<Driver> _filterDrivers(
    List<Driver> drivers,
    String query, {
    String? pickup,
    String? destination,
    TransportType? transportType,
    bool applySearchFilters = false,
  }) {
    var result = drivers;

    if (applySearchFilters) {
      if (transportType != null) {
        result = result.where((d) => _driverMatchesTransportType(d, transportType)).toList();
      }
      final pickupTrim = pickup?.trim() ?? '';
      if (pickupTrim.isNotEmpty) {
        result = result.where((d) =>
            d.location.toLowerCase().contains(pickupTrim.toLowerCase())).toList();
      }
      final destTrim = destination?.trim() ?? '';
      if (destTrim.isNotEmpty) {
        result = result.where((d) =>
            d.location.toLowerCase().contains(destTrim.toLowerCase())).toList();
      }
    }

    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      result = result.where((driver) {
        final name = driver.user.name.toLowerCase();
        final phone = driver.user.phone.toLowerCase();
        final carName = driver.carName.toLowerCase();
        final location = driver.location.toLowerCase();
        final carModel = driver.carModel.toLowerCase();
        return name.contains(lowerQuery) ||
            phone.contains(lowerQuery) ||
            carName.contains(lowerQuery) ||
            location.contains(lowerQuery) ||
            carModel.contains(lowerQuery);
      }).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(approvedDriversProvider);
    final userID = ref.watch(getUserIdProvider.select((value) => value.value));
    final async = ref.watch(userProvider(userID ?? ''));
    return Scaffold(
      backgroundColor: Color(0xFFF5F4F8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(approvedDriversProvider);
            ref.invalidate(userProvider(userID ?? ''));
            await Future.wait([
              ref.read(approvedDriversProvider.future),
              if (userID != null) ref.read(userProvider(userID).future),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                /// Header
                async.when(
                  data: (data) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${ref.t(BKeys.hello)}, ${data.name}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        InkWell(
                          onTap: () {
                            //"/transport_notificatons"
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
                    );
                  },
                  loading: () =>
                      const Center(child: Text('Loading...')),
                  error: (e, _) => Center(child: Text(e.toString())),
                ),
                //"Find your Driver"
                Text(
                  ref.t(BKeys.find_your_driver),
                  style: TextStyle(fontSize: 10.sp),
                ),
                SizedBox(height: 12.h),

                /// Search by vendor name (upore / above)
                _softField(
                  hint: ref.t(BKeys.search_by_vendor_name),
                  icon: Icons.search,
                  bg: Colors.white,
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                SizedBox(height: 16.h),

                /// Transport / Shipping type select (nica / below)
                Text(
                  ref.t(BKeys.transport_type),
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<TransportType?>(
                  value: _selectedTransportType,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: AllColor.grey300,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.r),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.r),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
                    ),
                  ),
                  hint: Text(
                    ref.t(BKeys.transport_type),
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFF9BA0A6)),
                  ),
                  items: TransportType.values.map((type) {
                    final label = _transportTypeLabel(ref, type);
                    return DropdownMenuItem<TransportType?>(
                      value: type,
                      child: Text(label, style: TextStyle(fontSize: 14.sp)),
                    );
                  }).toList(),
                  onChanged: (TransportType? value) {
                    setState(() {
                      _selectedTransportType = value;
                    });
                  },
                ),
                SizedBox(height: 16.h),

                /// Pickup, Destination
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Or divider
                    Row(
                      children: [
                        Expanded(child: Divider(thickness: 1, color: const Color(0xFFE5E7EB))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(ref.t(BKeys.or), style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280))),
                        ),
                        Expanded(child: Divider(thickness: 1, color: const Color(0xFFE5E7EB))),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Shipping From (Pickup)
                    _softField(
                      hint: ref.t(BKeys.pick_up_location),
                      icon: Icons.location_on_outlined,
                      bg: AllColor.grey300,
                      controller: _pickupController,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 10.h),

                    // Shipping To (Destination)
                    _softField(
                      hint: ref.t(BKeys.destination),
                      icon: Icons.flag_outlined,
                      bg: AllColor.grey300,
                      controller: _destinationController,
                      onChanged: (_) => setState(() {}),
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
                    onPressed: () {
                      setState(() {
                        _hasSearched = true;
                      });
                    },
                    child: Text(
                      ref.t(BKeys.search),
                      style: TextStyle(fontSize: 16.sp, color: AllColor.white),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                    
                

                SizedBox(height: 20.h),

                /// Drivers section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      //"Drivers",
                      ref.t(BKeys.driver),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push(TransportDriver.routeName);
                      },
                      child: Text(ref.t(BKeys.seeAll)),
                    ),
                  ],
                ),

                /// Driver Cards (ListView → Column with .map)
                state.when(
                  loading: () =>
                      const Center(child: Text('Loading...')),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Text(
                        // 'Failed to load drivers'
                        ref.t(BKeys.failed_to_load_drivers),
                      ),
                    ),
                  ),
                  data: (resp) {
                    final page = resp?.data;
                    final items = page?.data ?? <Driver>[];
                    final pickup = _pickupController.text.trim();
                    final destination = _destinationController.text.trim();
                    final filteredItems = _filterDrivers(
                      items,
                      _searchQuery,
                      pickup: pickup.isEmpty ? null : pickup,
                      destination: destination.isEmpty ? null : destination,
                      transportType: _selectedTransportType,
                      applySearchFilters: _hasSearched,
                    );

                    if (filteredItems.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(top: 20.h),
                        child: Text(
                          ref.t(BKeys.no_drivers_available),
                        ),
                      );
                    }
                    final homeItems = filteredItems.take(10).toList();

                    return Column(
                      children: homeItems
                          .map(
                            (d) => _DriverCard(
                              key: ValueKey(d.id),
                              driver: d,
                              images: d.images.whereType<String>().toList(),
                              onSelect: () {
                                context.push(
                                  TransportBookingConfirmScreen.routeName,
                                  extra: TransportBookingConfirmArgs(
                                    driver: d,
                                    pickup: _pickupController.text.trim().isEmpty
                                        ? null
                                        : _pickupController.text.trim(),
                                    destination: _destinationController.text.trim().isEmpty
                                        ? null
                                        : _destinationController.text.trim(),
                                  ),
                                );
                              },
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
    ),
    );
  }

  Widget _softField({
    required String hint,
    required IconData icon,
    Color? bg,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
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

/// Driver Card — redesigned for clear hierarchy and primary "Select" action
class _DriverCard extends ConsumerWidget {
  const _DriverCard({
    super.key,
    required this.driver,
    required this.images,
    required this.onSelect,
  });

  final Driver driver;
  final List<String> images;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = driver.user;

    final avatarUrl = (user.image?.isNotEmpty == true)
        ? user.image!
        : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTxfenNzfIFlwE5dd7aduVOvGR05Qqz7EDi-Q&s";

    final carUrl = images.isNotEmpty
        ? images.first
        : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTxfenNzfIFlwE5dd7aduVOvGR05Qqz7EDi-Q&s";

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top: Driver info + price
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      context.push(DriverDetailsScreen.routeName, extra: user.id);
                    },
                    borderRadius: BorderRadius.circular(28.r),
                    child: ClipOval(
                      child: FirstTimeShimmerImage(
                        imageUrl: avatarUrl,
                        width: 48.r,
                        height: 48.r,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        context.push(DriverDetailsScreen.routeName, extra: user.id);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              color: const Color(0xFF1F2937),
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            user.phone,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AllColor.blue500.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      "\$${driver.price}/km",
                      style: TextStyle(
                        color: AllColor.blue500,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// Vehicle image
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  height: 110.h,
                  width: double.infinity,
                  child: FirstTimeShimmerImage(
                    imageUrl: carUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            /// Vehicle & location
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Icon(Icons.directions_car_outlined, size: 18.sp, color: const Color(0xFF6B7280)),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      "${driver.carName} • ${driver.location}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            /// Actions: See Details (secondary) | Select (primary)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.push(DriverDetailsScreen.routeName, extra: user.id);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: const Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        foregroundColor: const Color(0xFF374151),
                      ),
                      child: Text(
                        ref.t(BKeys.see_details),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onSelect,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        backgroundColor: AllColor.blue500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        ref.t(BKeys.select_driver),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
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
