import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/global_pagination.dart';
import 'package:market_jango/features/vendor/screens/my_product_color/data/verndor_add_color_data_logic.dart';
import 'package:market_jango/features/vendor/screens/my_product_color/screen/my_product_color.dart';
import 'package:market_jango/features/vendor/screens/product_edit/data/product_attribute_data.dart';
import 'package:market_jango/features/vendor/screens/product_edit/screen/product_edit_screen.dart';
import 'package:market_jango/features/vendor/screens/vendor_category_add_page/screen/category_add_page.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/data/vendor_product_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/model/vendor_product_model.dart';
import 'package:market_jango/features/vendor/screens/vendor_my_product_size/screen/my_product_size.dart';
import 'package:market_jango/features/vendor/screens/vendor_product_add_page/screen/product_add_page.dart';

import '../../product_edit/model/product_attribute_response_model.dart';
import '../logic/vendor_product_delete.dart';

class VendorMyProductScreen extends ConsumerStatefulWidget {
  const VendorMyProductScreen({super.key});
  static const routeName = "/vendorMyProductScreen";

  @override
  ConsumerState<VendorMyProductScreen> createState() => _VendorMyProductScreenState();
}

class _VendorMyProductScreenState extends ConsumerState<VendorMyProductScreen> {
  final List<String> attributes = [];

  Future<void> _showAttributeMenu(BuildContext context, Offset position) async {
    // 1) API থেকে attribute list আনছি
    ProductAttributeResponse res;
    try {
      res = await ref.read(productAttributesProvider.future);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      return;
    }

    final attrs = res.data;
    if (attrs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No attributes found')),
      );
      return;
    }

    // 2) popup position
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    // 3) showMenu – name দেখাচ্ছি
    final selected = await showMenu<VendorProductAttribute>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: attrs
          .map(
            (a) => PopupMenuItem<VendorProductAttribute>(
          value: a,
          child: Text(a.name),
        ),
      )
          .toList(),
    );

    // 4) value handle
    if (selected != null) {
      setState(() {
        attributes.add(selected.name);
      });
      if (selected.name == "Color") {
        ref.invalidate(attributeShowProvider);
        context.push(MyProductColorScreen.routeName, extra: selected.id);
      } else if (selected.name == "Size") {
        ref.invalidate(attributeShowProvider);
        context.push(MyProductSizeScreen.routeName, extra: selected.id);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${selected.name} attribute added!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productNotifierProvider);
    final productNotifier = ref.read(productNotifierProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                         CustomBackButton() , 
                  Text(
                    "My Products",
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              /// Add Product and Add Category
              Row(
                children: [
                  _AddBox(
                    title: "Add your\nProduct",
                    onTap: () {
                      context.push(ProductAddPage.routeName);
                    },
                  ),
                  SizedBox(width: 12.w),
                  _AddBox(
                    title: "Add your\nCategory",
                    onTap: () {
                      context.push(CategoryAddPage.routeName);
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              /// Add custom attribute
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Add your custom attribute"),
                      InkWell(
                        onTapDown: (details) {
                          _showAttributeMenu(context, details.globalPosition);
                        },
                        child:   Icon(Icons.add),
                      ),
                     
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              /// Products List
              Text(
                "Products List",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12.h),

              /// Product items
              productAsync.when(
                data: (paginetion) {
                if(paginetion == null ) {
                  return const Center(child: Text("No Data"));
                }
                 final products = paginetion.products ;
                  return Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _ProductCard(
                            imageUrl:
                            product.image, // ✅ placeholder image
                            title: product.name,
                            category: product.categoryName,
                            price: product.sellPrice,
                            product: product,
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                      GlobalPagination(
                        currentPage: paginetion.currentPage,
                        totalPages: paginetion.lastPage,
                        onPageChanged: (page) {
                          productNotifier.changePage(page);
                        },
                      ),
                    ],
                  );
                }     ,
                error: (error, stackTrace) {
                  return Center(child: Text(error.toString()));
                },
                loading: () {
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Add Box Widget
class _AddBox extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _AddBox({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 30),
              SizedBox(height: 8.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Product Card
class _ProductCard extends ConsumerWidget {
  final String title;
  final String category;
  final String price;
  final String imageUrl;
  final VendorProduct product;

  const _ProductCard({
    required this.title,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.product,  
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              height: 64.r,
              width: 64.r,
              color: AllColor.grey100,
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          /// Price
          Text(
            price,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 6.w),

          GestureDetector(
            onTapDown: (details) {
              _showPopupMenu(
                context,
                details.globalPosition,
                ref,           // ← এখান থেকে ref পাঠাবে
                product,
              );
            },
            child: Icon(Icons.more_vert),
          ),

        ],
      ),
    );
  }

  Future<void> _showPopupMenu(
      BuildContext context,
      Offset position,
      WidgetRef ref,
      VendorProduct product,
      ) async {
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    final value = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx, // X position
        position.dy, // Y position
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: [
        PopupMenuItem(
          value: "edit",
          child: Row(
            children: [
              const Icon(Icons.edit, color: Colors.black),
              SizedBox(width: 8.w),
              const Text("Edit"),
            ],
          ),
        ),
        PopupMenuItem(
          value: "delete",
          child: Row(
            children: [
              const Icon(Icons.delete, color: Colors.black),
              SizedBox(width: 8.w),
              const Text("Delete"),
            ],
          ),
        ),
      ],
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    if (value == null) return;

    // ----------------- EDIT -----------------
    if (value == "edit") {
      context.push(
        ProductEditScreen.routeName,
        extra: product,
      );
      return;
    }

    // ----------------- DELETE -----------------
    if (value == "delete") {
      // 1) confirm dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Delete product?"),
          content: const Text("Are you sure you want to delete this product?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Delete"),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      try {
        // 2) API call
        await deleteVendorProduct(
          ref: ref,
          productId: product.id,
        );


        ref.invalidate(productNotifierProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product successfully deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }   
  }

}