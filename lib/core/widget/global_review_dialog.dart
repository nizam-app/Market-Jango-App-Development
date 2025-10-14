import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReviewDialog {
  static void show(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final commentCtrl = TextEditingController();
    double rating = 0;

    // warm cream fill & border like the screenshot
    const fill = Color(0xFFFFF2DE);
    const stroke = Color(0xFFFFE2BB);
    const orange = Color(0xFFFF8E1D);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
          child: StatefulBuilder(
            builder: (context, setState) {
              Widget pillField({
                required TextEditingController c,
                int maxLines = 1,
                required String hint,
              }) {
                return TextField(
                  controller: c,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: const Color(0xFF6E7C87),
                      fontSize: 14.sp,
                    ),
                    filled: true,
                    fillColor: fill,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: maxLines == 1 ? 16.h : 18.h,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28.r),
                      borderSide: BorderSide(color: stroke, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28.r),
                      borderSide: BorderSide(color: stroke, width: 2),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add your review',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // fields (pill style like image-1)
                    pillField(c: nameCtrl, hint: 'Enter your name'),
                    SizedBox(height: 12.h),
                    pillField(c: emailCtrl, hint: 'email'),
                    SizedBox(height: 12.h),
                    pillField(c: commentCtrl, hint: 'Comment', maxLines: 4),
                    SizedBox(height: 18.h),

                    // rating row
                    RatingBar.builder(
                      initialRating: rating,
                      minRating: 1,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 28.sp,
                      glow: false,
                      unratedColor: Colors.grey.shade300,
                      itemBuilder: (_, __) =>
                      const Icon(Icons.star_rounded, color: Colors.amber),
                      onRatingUpdate: (v) => setState(() => rating = v),
                    ),
                    SizedBox(height: 22.h),

                    // action row: Cancel + Submit (orange pill)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding:
                              EdgeInsets.symmetric(vertical: 14.h),
                              side: BorderSide(
                                  color: Colors.grey.shade300, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              foregroundColor: Colors.black,
                            ),
                            child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: submit to API with nameCtrl.text, emailCtrl.text,
                              // commentCtrl.text, rating
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding:
                              EdgeInsets.symmetric(vertical: 14.h),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              backgroundColor: orange,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Submit', style: TextStyle(fontSize: 14.sp)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}