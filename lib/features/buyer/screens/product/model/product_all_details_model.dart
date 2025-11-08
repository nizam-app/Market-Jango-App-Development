
import 'buyer_product_details_model.dart';
class ProductDetailsArgs {
  final DetailItem item;           // UI-ready detail
  final Object? source;            // পুরো response object (যেমন: TopProductsResponse/BuyerNewItemsModel)
  final Map<String, dynamic>? meta;

  const ProductDetailsArgs({
    required this.item,
    this.source,
    this.meta,
  });
  
  T? getAs<T>() => (source is T) ? source as T : null;
}