import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:market_jango/core/screen/buyer_massage/screen/global_massage_screen.dart';
import 'package:market_jango/core/screen/profile_screen/data/profile_data.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';

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
          final d = user.driver; // DriverInfo?
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
              : "Toyota";
          final carModel = d?.carModel?.isNotEmpty == true
              ? d!.carModel
              : "Cross Corolla";

          // car images from userImages (if any), otherwise fallback list
          final carImages = (user.userImages.isNotEmpty)
              ? user.userImages
                    .map((e) => e.imagePath)
                    .where((u) => u.isNotEmpty)
                    .toList()
              : <String>[
                  "https://pngimg.com/uploads/porsche/porsche_PNG10613.png",
                  "https://pngimg.com/uploads/porsche/porsche_PNG10613.png",
                  "https://pngimg.com/uploads/porsche/porsche_PNG10613.png",
                  "https://pngimg.com/uploads/porsche/porsche_PNG10613.png",
                ];
          Logger().d(user);
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
                  // আপনার API-তে যদি bio/description না থাকে, placeholder রাখলাম
                  "Lorem ipsum dolor sit amet consectetur. Id viverra elementum sit viverra vestibulum fames. Euismod habitasse habitant massa amet. Venenatis id netus orci dolor nulla ultricies dignissim vitae sagittis.",
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
                        : "https://pngimg.com/uploads/porsche/porsche_PNG10613.png";
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Card(child: Image.network(img, fit: BoxFit.cover)),
                    );
                  },
                ),
                SizedBox(height: 20.h),

                /// Buttons
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
                        onPressed: () {
                          context.push(GlobalMassageScreen.routeName);
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
                        onPressed: () {
                          context.push("/addCard");
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
