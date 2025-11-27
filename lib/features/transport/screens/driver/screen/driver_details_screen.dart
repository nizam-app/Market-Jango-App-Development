import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:market_jango/core/screen/buyer_massage/model/chat_history_route_model.dart';
import 'package:market_jango/core/screen/buyer_massage/screen/global_chat_screen.dart';
import 'package:market_jango/core/screen/profile_screen/data/profile_data.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/features/transport/screens/driver/logic/transport_driver_perment_logic.dart';
import 'package:market_jango/features/transport/screens/driver/widget/transport_driver_input_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverDetailsScreen extends ConsumerWidget {
  const DriverDetailsScreen({super.key, required this.driverId});

  final int driverId;
  static const String routeName = "/driverDetails";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverDetails = ref.watch(userProvider(driverId.toString()));

    return Scaffold(
      body: driverDetails.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (user) {
          final d = user.driver;
          final avatarUrl = (user.image.isNotEmpty)
              ? user.image
              : "https://i.pravatar.cc/150?img=12";

          // rating (0..5)
          final ratingVal = _clampRating(d?.rating);

          final verifiedSinceText = _verifiedSinceText(
            user.phoneVerifiedAt ?? user.createdAt,
            user.userType,
          );

          // car brand/model from driver info (fallback text)
          final carBrand = d?.carName?.isNotEmpty == true
              ? d!.carName
              : "Not available";
          final carModel = d?.carModel?.isNotEmpty == true
              ? d!.carModel
              : "Not available";
          final description = d?.description?.isNotEmpty == true
              ? d!.description
              : "Not available";

          // car images from userImages (if any), otherwise fallback list
          final carImages = (user.userImages.isNotEmpty)
              ? user.userImages
                    .map((e) => e.imagePath)
                    .where((u) => u.isNotEmpty)
                    .toList()
              : <String>[
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUn6fL1_OXhaWOYa0QSrP5jHKIjFHezT18Yw&s",
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUn6fL1_OXhaWOYa0QSrP5jHKIjFHezT18Yw&s",
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUn6fL1_OXhaWOYa0QSrP5jHKIjFHezT18Yw&s",
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUn6fL1_OXhaWOYa0QSrP5jHKIjFHezT18Yw&s",
                ];
          // Logger().d(user);
          Logger().d(driverId);
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                const CustomBackButton(),

                /// Profile Image
                CircleAvatar(
                  radius: 40.r,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
                SizedBox(height: 12.h),

                /// Name
                Text(
                  user.name.isNotEmpty ? user.name : "Bessie Cooper",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),

                /// Verified Since
                Text(
                  verifiedSinceText,
                  style: TextStyle(fontSize: 12.sp, color: Colors.blue),
                ),
                SizedBox(height: 10.h),

                /// Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RatingBarIndicator(
                      rating: ratingVal,
                      itemBuilder: (context, index) =>
                          const Icon(Icons.star, color: Colors.amber),
                      itemSize: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      ratingVal.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                /// Car Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Car Brand: ",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(carBrand, style: TextStyle(fontSize: 14.sp)),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Car Model: ",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(carModel, style: TextStyle(fontSize: 14.sp)),
                  ],
                ),
                SizedBox(height: 20.h),

                /// About
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "About",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  description,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[800]),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 20.h),

                /// Car Images
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Car Images",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                if (user.userImages.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: carImages.isNotEmpty
                        ? carImages.length.clamp(0, 4)
                        : 4,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 1.3,
                    ),
                    itemBuilder: (context, index) {
                      final img = index < carImages.length
                          ? carImages[index]
                          : "https://static.vecteezy.com/system/resources/previews/0"
                                "24/228/025/non_2x/slashed-zero-icon-symbol-in-mathematics-null-set-empty-set-illustration-free-vector.jpg";
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Card(
                          child: Image.network(img, fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
                SizedBox(height: 20.h),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        onPressed: () async {
                          SharedPreferences _prefs =
                              await SharedPreferences.getInstance();
                          final userId = _prefs.getString("user_id");
                          if (userId == null)
                            throw Exception("user id not founde");

                          context.push(
                            GlobalChatScreen.routeName,
                            extra: ChatArgs(
                              partnerId: user.id,
                              partnerName: user.name,
                              partnerImage: user.image,
                              myUserId: int.parse(userId),
                            ),
                          );
                        },
                        child: Text(
                          "Send Message",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        onPressed: () async {
                          // 1) নতুন screen থেকে address + location নাও
                          final dropData = await context
                              .push<TransportDropLocation>(
                                SetDropLocationScreen.routeName,
                              );
                          if (dropData == null) return;

                          // 2) payment API + webview
                          await startTransportInvoiceCheckout(
                            context,
                            driverId: driverId,
                            dropAddress: dropData.address,
                            dropLatitude: dropData.latitude,
                            dropLongitude: dropData.longitude,
                          );
                        },
                        child: Text(
                          "Pay Now",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
              ],
            ),
          );
        },
      ),
    );
  }

  static double _clampRating(num? r) {
    if (r == null) return 0.0;
    final v = r.toDouble();
    if (v.isNaN || v.isInfinite) return 0.0;
    if (v < 0) return 0.0;
    if (v > 5) return 5.0;
    return v;
  }

  static String _verifiedSinceText(String? iso, String userType) {
    final dt = DateTime.tryParse(iso ?? '');
    String when;
    if (dt == null) {
      when = "N/A";
    } else {
      const months = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
      ];
      when = "${months[dt.month - 1]} ${dt.year}";
    }
    // keep original sentence style; only value dynamic
    final role = userType.toLowerCase() == "driver" ? "Driver" : userType;
    return "Verified $role Since $when";
  }
}

class TransportDropLocation {
  final String address;
  final double latitude;
  final double longitude;

  TransportDropLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}
