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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(vendorProductNotifierProvider.notifier).updateSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

                return ListView.builder(
                  itemCount: response.products.length,
                  itemBuilder: (context, index) {
                    final product = response.products[index];
                    return _ProductCard(
                      product: product,
                      onTap: () => _showOfferSheet(context, product),
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

  void _showOfferSheet(BuildContext context, VendorProduct product) {
    // For now, just pop with a placeholder message
    // TODO: Implement offer creation sheet
    Navigator.of(context).pop();
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

