import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/screen/buyer_massage/data/vendor_product_notifier.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/model/vendor_product_model.dart';

class AllVendorProductScreen extends ConsumerStatefulWidget {
  const AllVendorProductScreen({super.key});

  @override
  ConsumerState<AllVendorProductScreen> createState() => _AllVendorProductScreenState();
}

class _AllVendorProductScreenState extends ConsumerState<AllVendorProductScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(vendorProductNotifierProvider.notifier).updateSearch(_searchController.text);
    });
    
    // Set up infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when 80% scrolled
      final notifier = ref.read(vendorProductNotifierProvider.notifier);
      notifier.nextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(vendorProductNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Product to Offer'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          Expanded(
            child: productAsync.when(
              data: (response) {
                if (response == null || response.products.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                final hasMore = response.currentPage < response.lastPage;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: response.products.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= response.products.length) {
                      // Show loading indicator at bottom
                      return Padding(
                        padding: EdgeInsets.all(16.w),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    
                    final product = response.products[index];
                    return _ProductCard(
                      product: product,
                      onTap: () => _onProductSelected(context, product),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _onProductSelected(BuildContext context, VendorProduct product) {
    // Return the selected product to the caller
    Navigator.of(context).pop(product);
  }
}

class _ProductCard extends StatelessWidget {
  final VendorProduct product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: ListTile(
        leading: product.image.isNotEmpty
            ? Image.network(
                product.image,
                width: 60.w,
                height: 60.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image),
              )
            : const Icon(Icons.image),
        title: Text(product.name),
        subtitle: Text('৳${product.sellPrice}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

