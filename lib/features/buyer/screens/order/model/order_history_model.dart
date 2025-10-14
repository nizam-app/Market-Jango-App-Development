import 'dart:ui';

class ReviewOrder {
  final String orderId;      // like "#92287157"
  final String imageUrl;     // thumbnail
  final String dateText;     // like "April,06"
  final String subtitle;     // short line under image
  final VoidCallback? onReview;

  ReviewOrder({
    required this.orderId,
    required this.imageUrl,
    required this.dateText,
    this.subtitle = 'Lorem ipsum dolor sit amet consectetur.',
    this.onReview,
  });
}
