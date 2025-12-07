import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/core/screen/buyer_massage/data/offer_product_repository.dart';
import 'package:market_jango/core/screen/buyer_massage/model/vendor_product_response_model.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/model/vendor_product_model.dart';

final vendorProductNotifierProvider =
    AsyncNotifierProvider.autoDispose<VendorProductNotifier, VendorProductResponse?>(
  VendorProductNotifier.new,
);

class VendorProductNotifier extends AutoDisposeAsyncNotifier<VendorProductResponse?> {
  Timer? _searchDebounceTimer;
  String _currentSearch = '';
  int _currentPage = 1;
  List<VendorProduct> _allProducts = [];

  @override
  Future<VendorProductResponse?> build() async {
    _currentPage = 1;
    _allProducts = [];
    _currentSearch = '';
    
    // Register cleanup callback
    ref.onDispose(() {
      _searchDebounceTimer?.cancel();
    });
    
    return await _loadProducts();
  }

  /// Update search query with debounce
  void updateSearch(String value) {
    _currentSearch = value;
    _currentPage = 1;
    _allProducts = [];
    
    // Cancel previous timer
    _searchDebounceTimer?.cancel();
    
    // Debounce: wait 500ms before searching
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() => _loadProducts());
    });
  }

  /// Load next page for infinite scroll
  Future<void> nextPage() async {
    final current = state.value;
    if (current == null || _currentPage >= current.lastPage) return;
    if (state.isLoading) return;

    _currentPage++;
    final repository = OfferProductRepository();
    
    try {
      final result = await repository.fetchVendorProducts(
        page: _currentPage,
        search: _currentSearch.isEmpty ? null : _currentSearch,
      );

      // Merge new products with existing ones
      _allProducts.addAll(result.products);

      state = AsyncValue.data(
        VendorProductResponse(
          products: _allProducts,
          currentPage: result.currentPage,
          lastPage: result.lastPage,
          total: result.total,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<VendorProductResponse> _loadProducts() async {
    final repository = OfferProductRepository();
    final result = await repository.fetchVendorProducts(
      page: _currentPage,
      search: _currentSearch.isEmpty ? null : _currentSearch,
    );

    _allProducts = result.products;
    return result;
  }
}

