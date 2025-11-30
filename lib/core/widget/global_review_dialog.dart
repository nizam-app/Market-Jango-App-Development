import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef ReviewSubmitCallback =
    Future<void> Function(double rating, String comment);

class ReviewDialog {
  /// Reusable dialog
  /// onSubmit er moddhe tumi je API hit korte chao korbe
  static Future<void> show(
    BuildContext context, {
    required ReviewSubmitCallback onSubmit,
    String title = 'Rate this item',
    String commentHint = 'Write something about this product...',
  }) {
    final commentCtrl = TextEditingController();
    double rating = 0;
    bool isSubmitting = false;
    String? errorText;

    const fill = Color(0xFFFFF2DE);
    const stroke = Color(0xFFFFE2BB);
    const orange = Color(0xFFFF8E1D);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
            child: StatefulBuilder(
              builder: (ctx, setState) {
                Future<void> handleSubmit() async {
                  if (rating == 0 || commentCtrl.text.trim().isEmpty) {
                    setState(() {
                      errorText = 'Please add both rating and comment';
                    });
                    return;
                  }

                  setState(() {
                    isSubmitting = true;
                    errorText = null;
                  });

                  try {
                    await onSubmit(rating, commentCtrl.text.trim());
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop(); // dialog close
                    }
                  } catch (e) {
                    setState(() {
                      isSubmitting = false;
                      errorText = 'Something went wrong. Please try again.';
                    });
                  }
                }

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title + close
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(
                              Icons.close_rounded,
                              size: 22.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // rating
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Tap to rate',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            RatingBar.builder(
                              initialRating: rating,
                              minRating: 1,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemSize: 30.sp,
                              glow: false,
                              unratedColor: Colors.grey.shade300,
                              itemBuilder: (_, __) => const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (v) {
                                setState(() {
                                  rating = v;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18.h),

                      // comment
                      Text(
                        'Your comment',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      TextField(
                        controller: commentCtrl,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: commentHint,
                          hintStyle: TextStyle(
                            color: const Color(0xFF6E7C87),
                            fontSize: 14.sp,
                          ),
                          filled: true,
                          fillColor: fill,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 16.h,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.r),
                            borderSide: BorderSide(color: stroke, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.r),
                            borderSide: BorderSide(color: stroke, width: 2),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),

                      if (errorText != null) ...[
                        Text(
                          errorText!,
                          style: TextStyle(color: Colors.red, fontSize: 12.sp),
                        ),
                        SizedBox(height: 6.h),
                      ],

                      SizedBox(height: 10.h),

                      // buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 13.h),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                foregroundColor: Colors.black,
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSubmitting ? null : handleSubmit,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 13.h),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                backgroundColor: orange,
                                foregroundColor: Colors.white,
                              ),
                              child: isSubmitting
                                  ? SizedBox(
                                      height: 18.w,
                                      width: 18.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Submit',
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
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
        );
      },
    );
  }
}
