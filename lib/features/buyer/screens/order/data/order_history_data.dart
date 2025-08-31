import 'package:market_jango/features/buyer/screens/order/model/order_history_model.dart';

final demoReviewOrders = List.generate(6, (i) {
  const pics = [
    'https://images.unsplash.com/photo-1490481651871-ab68de25d43d',
    'https://images.unsplash.com/photo-1512436991641-6745cdb1723f',
    'https://images.unsplash.com/photo-1519744792095-2f2205e87b6f',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9',
    'https://images.unsplash.com/photo-1491553895911-0055eca6402d',
  ];
  return ReviewOrder(
    orderId: '#9228715${i + 1}',
    imageUrl: pics[i % pics.length],
    dateText: 'April,0${(i % 6) + 1}',
    onReview: () {},
  );
});
