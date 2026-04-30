import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/auth_header_provider.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/core/utils/get_user_type.dart';
import 'package:market_jango/features/buyer/data/banner_data.dart';
import 'package:market_jango/features/buyer/data/buyer_categori_data.dart';
import 'package:market_jango/features/buyer/data/buyer_just_for_you_data.dart';
import 'package:market_jango/features/buyer/data/buyer_top_data.dart';
import 'package:market_jango/features/buyer/data/new_items_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/data/vendor_product_data.dart';

typedef _Inv = void Function(ProviderBase<Object?> provider);

void _invalidateAuthSessionProviders(_Inv inv) {
  inv(authTokenProvider);
  inv(authHeadersProvider);
  inv(getUserTypeProvider);
  inv(getUserIdProvider);
  inv(getUserEmailProvider);
}

void _invalidateBuyerHomeFeedProviders(_Inv inv) {
  inv(bannerNotifierProvider);
  inv(topProductProvider);
  inv(buyerNewItemsProvider);
  inv(categoriesProvider);
  inv(justForYouProvider(BuyerAPIController.just_for_you));
}

void _invalidateVendorHomeProductProviders(_Inv inv) {
  inv(productNotifierProvider);
}

/// After logout — drop cached auth + feeds so the next login home load refetches immediately.
void invalidateCachesAfterLogout(ProviderContainer container) {
  void inv(ProviderBase<Object?> p) => container.invalidate(p);
  _invalidateAuthSessionProviders(inv);
  _invalidateBuyerHomeFeedProviders(inv);
  _invalidateVendorHomeProductProviders(inv);
}

/// Called after login token is persisted so home/tab feeds refetch for the new session.
void invalidateHomeFeedsAfterSuccessfulLogin(Ref ref) {
  void inv(ProviderBase<Object?> p) => ref.invalidate(p);
  _invalidateBuyerHomeFeedProviders(inv);
  _invalidateVendorHomeProductProviders(inv);
}
