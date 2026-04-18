import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/vendor/screens/vendor_barcode/model/vendor_barcode_models.dart';
import 'package:market_jango/features/vendor/screens/vendor_barcode/provider/vendor_barcode_provider.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

import 'vendor_barcode_product_detail_screen.dart';
import 'vendor_barcode_scan_screen.dart';

/// Barcode list, search, and entry to scanner (doc/VENDOR_BARCODE_AND_SCANNER_API.md).
class VendorBarcodeHubScreen extends ConsumerStatefulWidget {
  const VendorBarcodeHubScreen({super.key});

  static const routeName = '/vendor/barcodes';

  @override
  ConsumerState<VendorBarcodeHubScreen> createState() =>
      _VendorBarcodeHubScreenState();
}

class _VendorBarcodeHubScreenState
    extends ConsumerState<VendorBarcodeHubScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _applySearch() {
    ref.read(vendorBarcodeListParamsProvider.notifier).state =
        VendorBarcodeListParams(page: 1, search: _search.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final params = ref.watch(vendorBarcodeListParamsProvider);
    final async = ref.watch(vendorBarcodeListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AllColor.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: const CustomBackButton(),
        ),
        title: Text(
          'Barcodes',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Scan',
            onPressed: () => context.push(VendorBarcodeScanScreen.routeName),
            icon: const Icon(Icons.qr_code_scanner_rounded),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
            child: Material(
              color: AllColor.white,
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _search,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _applySearch(),
                        decoration: const InputDecoration(
                          hintText: 'Search name or barcode',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: _applySearch,
                      style: FilledButton.styleFrom(
                        backgroundColor: AllColor.loginButtomColor,
                      ),
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(vendorBarcodeListProvider);
              },
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 80.h),
                    Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        e.toString().replaceFirst('Exception: ', ''),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                data: (page) {
                  if (page.items.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 80.h),
                        Center(
                          child: Text(
                            'No products found.',
                            style: TextStyle(
                              color: AllColor.grey500,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                    itemCount: page.items.length,
                    itemBuilder: (_, i) {
                      final p = page.items[i];
                      return _ProductTile(
                        product: p,
                        onTap: () => context.push(
                          VendorBarcodeProductDetailScreen.routePath(p.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          _PaginationBar(
            current: params.page,
            lastPage: async.valueOrNull?.lastPage ?? 1,
            onPage: (p) {
              ref.read(vendorBarcodeListParamsProvider.notifier).state = ref
                  .read(vendorBarcodeListParamsProvider)
                  .copyWith(page: p);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(VendorBarcodeScanScreen.routeName),
        backgroundColor: AllColor.loginButtomColor,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan'),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.current,
    required this.lastPage,
    required this.onPage,
  });

  final int current;
  final int lastPage;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AllColor.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: current <= 1 ? null : () => onPage(current - 1),
                child: const Text('Previous'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text('$current / $lastPage'),
              ),
              TextButton(
                onPressed: current >= lastPage
                    ? null
                    : () => onPage(current + 1),
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});

  final VendorBarcodeProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      child: ListTile(
        onTap: onTap,
        title: Text(
          product.name.isEmpty ? 'Product #${product.id}' : product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            SelectableText(
              product.barcode.isEmpty ? '—' : product.barcode,
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'monospace',
                color: AllColor.grey500,
              ),
            ),
            Text(
              'Stock ${product.stock} · ${product.sellPrice}',
              style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy_rounded),
          onPressed: product.barcode.isEmpty
              ? null
              : () {
                  Clipboard.setData(ClipboardData(text: product.barcode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Barcode copied')),
                  );
                },
        ),
      ),
    );
  }
}
