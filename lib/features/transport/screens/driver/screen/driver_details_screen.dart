import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:market_jango/core/screen/buyer_massage/model/chat_history_route_model.dart';
import 'package:market_jango/core/screen/buyer_massage/screen/global_chat_screen.dart';
import 'package:market_jango/core/screen/profile_screen/data/profile_data.dart';
import 'package:market_jango/features/transport/screens/driver/screen/driver_promotion_screen.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';

class DriverDetailsScreen extends ConsumerWidget {
  const DriverDetailsScreen({super.key, required this.driverId});

  final int driverId;
  static const String routeName = "/driverDetails";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverDetails = ref.watch(userProvider(driverId.toString()));

    return Scaffold(
      body: driverDetails.when(
        loading: () => const Center(child: Text('Loading...')),
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
          final carBrand = d?.carName.isNotEmpty == true
              ? d!.carName
              : "Not available";
          final carModel = d?.carModel.isNotEmpty == true
              ? d!.carModel
              : "Not available";
          final description = d?.description.isNotEmpty == true
              ? d!.description
              : "Not available";

          // car images from userImages (if any)
          final carImages = user.userImages
              .map((e) => e.imagePath)
              .where((u) => u.isNotEmpty)
              .toList();
          // Logger().d(user);
          Logger().d(driverId);
          
          // Get cover image from driver info
          final String? coverImageUrl = d?.coverImage;
          final bool hasCoverImage = coverImageUrl != null && coverImageUrl.isNotEmpty;
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Cover image section
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
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                        ),
                        child: hasCoverImage
                            ? FirstTimeShimmerImage(
                                imageUrl: coverImageUrl,
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
                    // Back button positioned over cover image
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: const CustomBackButton(),
                      ),
                    ),
                  ],
                ),
                
                // Profile section positioned below cover image (overlapping)
                Transform.translate(
                  offset: Offset(0, -41.w), // Move profile image up to overlap cover
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        /// Profile Image
                        ClipOval(
                          child: FirstTimeShimmerImage(
                            imageUrl: avatarUrl,
                            width: 80.r,
                            height: 80.r,
                            fit: BoxFit.cover,
                          ),
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
                      ],
                    ),
                  ),
                ),
                
                // Rest of the content with padding
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                      SizedBox(height: 12.h),

                      if (carImages.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 32.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.directions_car_outlined,
                                size: 48.r,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "No car images",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: carImages.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 1.25,
                          ),
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14.r),
                                child: FirstTimeShimmerImage(
                                  imageUrl: carImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      SizedBox(height: 24.h),

                      // Promotion + Send Message row (same as buyer vendor profile)
                      Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(24.r),
                            elevation: 1,
                            shadowColor: Colors.orange.shade200.withOpacity(0.4),
                            child: InkWell(
                              onTap: () {
                                context.push(
                                  DriverPromotionScreen.routeName,
                                  extra: driverId,
                                );
                              },
                              borderRadius: BorderRadius.circular(24.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18.w,
                                  vertical: 11.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24.r),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                    width: 1.2,
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.shade100.withOpacity(0.5),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.campaign_rounded,
                                      size: 20.r,
                                      color: Colors.orange.shade700,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Promotion',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange.shade800,
                                        letterSpacing: 0.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
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
                                    partnerId: user.id,
                                    partnerName: user.name,
                                    partnerImage: user.image,
                                    myUserId: myUserId,
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
                        ],
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
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
