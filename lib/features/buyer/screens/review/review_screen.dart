// lib/features/buyer/screens/review/review_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/features/buyer/screens/review/model/buyer_review_model.dart';

import 'data/buyer_review_data.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.vendorId});

  static const String routeName = '/reviewScreen';
  final int vendorId;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _currentPage = 1;
  late Future<VendorReviewsPage> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = fetchVendorReviews(vendorId: widget.vendorId, page: _currentPage);
  }

  void _changePage(int newPage, int lastPage) {
    if (newPage < 1 || newPage > lastPage || newPage == _currentPage) return;
    setState(() {
      _currentPage = newPage;
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              Tuppertextandbackbutton(screenName: "Review Screen"),
              SizedBox(height: 12.h),
              Expanded(
                child: FutureBuilder<VendorReviewsPage>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load reviews',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      );
                    }

                    final page = snapshot.data;
                    if (page == null || page.reviews.isEmpty) {
                      return Center(
                        child: Text(
                          'No reviews yet',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: page.reviews.length,
                            separatorBuilder: (_, __) => SizedBox(height: 8.h),
                            itemBuilder: (context, index) {
                              final review = page.reviews[index];
                              return CustomReview(review: review);
                            },
                          ),
                        ),
                        SizedBox(height: 8.h),
                        _PaginationBar(
                          currentPage: page.currentPage,
                          lastPage: page.lastPage,
                          onPageChange: (p) => _changePage(p, page.lastPage),
                        ),
                        SizedBox(height: 8.h),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.lastPage,
    required this.onPageChange,
  });

  final int currentPage;
  final int lastPage;
  final ValueChanged<int> onPageChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentPage > 1
              ? () => onPageChange(currentPage - 1)
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        SizedBox(width: 8.w),
        Text(
          'Page $currentPage / $lastPage',
          style: TextStyle(fontSize: 13.sp),
        ),
        SizedBox(width: 8.w),
        IconButton(
          onPressed: currentPage < lastPage
              ? () => onPageChange(currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class CustomReview extends StatelessWidget {
  const CustomReview({super.key, required this.review});

  final VendorReview review;

  @override
  Widget build(BuildContext context) {
    final user = review.user;
    final product = review.product;

    // user avatar (null hole initials use korbo)
    String? avatarUrl = user?.image;
    if (avatarUrl == null || avatarUrl.isEmpty) {
      final name = (user?.name ?? 'U');
      avatarUrl =
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}';
    }

    final productImage = product?.image ?? '';
    final productName = product?.name ?? '';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👉 user profile image
          CircleAvatar(radius: 24.r, backgroundImage: NetworkImage(avatarUrl)),
          SizedBox(width: 12.w),

          // content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // name + product thumb
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        review.userName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AllColor.black,
                        ),
                      ),
                    ),
                    // if (productImage.isNotEmpty)
                    //   ClipRRect(
                    //     borderRadius: BorderRadius.circular(8.r),
                    //     child: Image.network(
                    //       productImage,
                    //       width: 40.w,
                    //       height: 40.w,
                    //       fit: BoxFit.cover,
                    //     ),
                    //   ),
                  ],
                ),
                SizedBox(height: 4.h),

                // stars + product name
                Row(
                  children: [
                    StarRating(
                      rating: review.rating,
                      allowHalfRating: false,
                      size: 16.sp,
                      color: Colors.amber,
                      borderColor: Colors.grey.shade400,
                      starCount: 5,
                    ),
                    // SizedBox(width: 6.w),
                    // if (productName.isNotEmpty)
                    //   Expanded(
                    //     child: Text(
                    //       productName,
                    //       maxLines: 1,
                    //       overflow: TextOverflow.ellipsis,
                    //       style: TextStyle(
                    //         fontSize: 12.sp,
                    //         fontWeight: FontWeight.w500,
                    //         color: AllColor.grey,
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
                SizedBox(height: 6.h),

                // review text
                Text(
                  review.review,
                  style: TextStyle(fontSize: 12.sp, color: AllColor.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
