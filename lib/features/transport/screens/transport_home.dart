
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
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TransportHome extends StatelessWidget {
  const TransportHome({super.key});
  static const String routeName = '/transport_home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F4F8), 
      body: SafeArea(
        child: SingleChildScrollView(
          //physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hello, Jane Cooper 👋",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        context.push("/transport_notificatons"); 
                      },
                      child: Icon(Icons.notifications_none, size: 24.sp)),
                  ],
                ),
                Text(
                      "Find your Driver",
                      style: TextStyle(
                        fontSize: 10.sp,
                      ),
                    ),
                SizedBox(height: 20.h),

                /// Search Fields
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search by vendor name",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                /// Or divider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: 2, width: 120.w, color: Colors.grey),
                    Text("Or", style: TextStyle(fontSize: 16.sp)),
                    Container(height: 2, width: 120.w, color: Colors.grey),
                  ],
                ),
                SizedBox(height: 10.h),

                /// Pickup & Destination
                Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Enter Pickup location",
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Destination",
                        prefixIcon: const Icon(Icons.flag_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),
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
                    child: Text("Search", style: TextStyle(fontSize: 16.sp)),
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
                        context.push("/transport_driver"); 
                      },
                      child: const Text("See all"),
                    ),
                  ],
                ),

                /// Driver Cards (ListView → Column with .map)
                Column(
                  children: List.generate(
                    4,
                    (index) => const _DriverCard(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Driver Card
class _DriverCard extends StatelessWidget {
  const _DriverCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Driver Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: const NetworkImage(
                    "https://randomuser.me/api/portraits/men/75.jpg",
                  ),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Jerome Bell",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        )),
                    Text("Porsche Taycan",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        )),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "\$25/km",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 10.h),

            /// Car Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                "https://pngimg.com/uploads/porsche/porsche_PNG10613.png",
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10.h),

            /// Title + Button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Driver Car",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Text(
                      "See Details ",
                      
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
