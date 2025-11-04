import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/buyer/data/new_items_data.dart';
import 'package:market_jango/features/buyer/model/new_items_model.dart';

String baseUrl = BuyerAPIController.buyer_product;

final buyerNewItemsRepositoryProvider = Provider<BuyerNewItemsRepository>((ref) {
  // This provider will be used only when we have token, so no need for token here.
  throw UnimplementedError('Token not provided yet');
});

/// Main provider that uses the token from authTokenProvider
final buyerNewItemsProvider =
FutureProvider.autoDispose<BuyerNewItemsModel>((ref) async {
  final tokenAsync = await ref.watch(authTokenProvider.future);

  if (tokenAsync == null || tokenAsync.isEmpty) {
    throw Exception('No authentication token found');
  }

  final repo = BuyerNewItemsRepository(baseUrl: baseUrl, token: tokenAsync);
  return repo.fetchBuyerNewItems();
});