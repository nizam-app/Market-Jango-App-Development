import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';

class DriverDetailsScreen extends StatelessWidget {
  const DriverDetailsScreen({super.key});
  static const String routeName = "/driverDetails";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w,vertical: 10.h ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),
            CustomBackButton(),  

            /// Profile Image
            CircleAvatar(
              radius: 40.r,
              backgroundImage: const NetworkImage(
                  "https://randomuser.me/api/portraits/men/32.jpg"),
            ),
            SizedBox(height: 12.h),

            /// Name
            Text(
              "Bessie Cooper",
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 4.h),

            /// Verified Since
            Text(
              "Verified Driver Since December 2014",
              style: TextStyle(fontSize: 12.sp, color: Colors.blue),
            ),
            SizedBox(height: 10.h),

            /// Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RatingBarIndicator(
                  rating: 4.6,
                  itemBuilder: (context, index) =>
                      const Icon(Icons.star, color: Colors.amber),
                  itemSize: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  "4.6",
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            /// Car Details
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Car Brand: ",
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                Text("Toyota", style: TextStyle(fontSize: 14.sp)),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Car Model: ",
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                Text("Cross Corolla", style: TextStyle(fontSize: 14.sp)),
              ],
            ),
            SizedBox(height: 20.h),

            /// About
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "About",
                style:
                    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
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
                style:
                    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10.h),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                childAspectRatio: 1.3,
              ),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Card(
                    child: Image.network(
                      "https://pngimg.com/uploads/porsche/porsche_PNG10613.png",
                      fit: BoxFit.cover,
                    ),
                  ),
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
                    onPressed: () {},
                    child: Text("Send Message",
                        style: TextStyle(fontSize: 14.sp, color: Colors.white)),
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
                    child: Text("Pay Now",
                        style: TextStyle(fontSize: 14.sp, color: Colors.black)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h,), 
          ],
        ),
      ),
    );
  }
}
