import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_new_product.dart';
import 'package:market_jango/core/widget/custom_search_bar.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/model/vendor_product_model.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';
import 'package:market_jango/features/vendor/widgets/edit_widget.dart';

import '../../../../../core/constants/api_control/vendor_api.dart';
import '../../../../../core/widget/global_pagination.dart';
import '../../vendor_product_add_page/screen/product_add_page.dart';
import '../data/vendor_product_category_riverpod.dart';
import '../data/vendor_product_data.dart';
import '../logic/vendor_details_riverpod.dart';
import '../model/user_details_model.dart';

class VendorHomeScreen extends ConsumerWidget {
  const VendorHomeScreen({super.key});
  static const String routeName = '/vendor_home_screen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorAsync = ref.watch(vendorProvider);
    final productAsync = ref.watch(productNotifierProvider);

    final productNotifier = ref.read(productNotifierProvider.notifier);

    return SafeArea(
      child: Scaffold(
        backgroundColor: AllColor.white70,
        endDrawer: Drawer(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: buildDrawer(context),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25.h),
              vendorAsync.when(
                data: (vendor) => buildProfileSection(vendor),
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => Text('Error: $err'),
              ),
              SizedBox(height: 30.h),
              CustomSearchBar(
              ),
              SizedBox(height: 15.h),
              // Category bar
              CategoryBar(
                endpoint: VendorAPIController.vendor_category,
                onCategorySelected: (categoryId) {
                  productNotifier.changeCategory(categoryId);
                },
              ),
              SizedBox(height: 20.h),

              // Products with pagination
              productAsync.when(
                data: (paginated) {
                  if (paginated == null) {
                    return const Center(child: Text("No products found"));
                  }
                  final products = paginated.products;
                  return Column(
                    children: [
                      _buildProductGridViewSection(products),
                      SizedBox(height: 20.h),
                      GlobalPagination(
                        currentPage: paginated.currentPage,
                        totalPages: paginated.lastPage,
                        onPageChanged: (page) {
                          productNotifier.changePage(page);
                        },
                      ),
                      SizedBox(height: 20.h),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildDrawer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          CustomBackButton(),
          SizedBox(height: 10.h),
          InkWell(
            onTap: () {
              context.push("/vendorOrderPending");
            },
            child: ListTile(
              leading: ImageIcon(
                const AssetImage("assets/icon/bag.png"),
                size: 20.r,
              ),
              title: Text(
                "Order",
                style: TextStyle(color: Colors.black, fontSize: 14.sp),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_outlined,
                color: Colors.black,
              ),
            ),
          ),
          Divider(color: Colors.grey.shade300),
          InkWell(
            onTap: () {
              context.push("/vendorSalePlatform");
            },
            child: ListTile(
              leading: ImageIcon(
                const AssetImage("assets/icon/sale.png"),
                size: 20.r,
              ),
              title: Text(
                "Sale",
                style: TextStyle(color: Colors.black, fontSize: 14.sp),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_outlined,
                color: Colors.black,
              ),
            ),
          ),
          Divider(color: Colors.grey.shade300),
          InkWell(
            onTap: () {
              context.push("/language");
            },
            child: ListTile(
              leading: ImageIcon(
                const AssetImage("assets/icon/language.png"),
                size: 20.r,
              ),
              title: Text(
                "Language",
                style: TextStyle(color: Colors.black, fontSize: 14.sp),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_outlined,
                color: Colors.black,
              ),
            ),
          ),
          Divider(color: Colors.grey.shade300),
          InkWell(
            onTap: () {},
            child: ListTile(
              leading: ImageIcon(
                const AssetImage("assets/icon/logout.png"),
                size: 20.r,
                color: const Color(0xffFF3B3B),
              ),
              title: Text(
                "Log Out",
                style: TextStyle(
                  color: const Color(0xffFF3B3B),
                  fontSize: 14.sp,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_outlined,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //

  // filters = ['Quasi', 'Electronics', 'Grocery', ...]  // API থেকে সেট করবে

  Widget _buildProductGridViewSection(List<Product> products) {
    final safeProducts = products.whereType<Product>().toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 9 / 13,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 15.w,
      ),
      itemCount: safeProducts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return buildAddUrProduct(context);
        }

        final prod = safeProducts.elementAtOrNull(index - 1);
        if (prod == null) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: [
            CustomNewProduct(
              width: 161.w,
              height: 168.h,
              text: prod.name,
              text2: prod.description,
              image: prod.image,
            ),
            Positioned(
              top: 20.h,
              right: 20.w,
              child: Edit_Widget(
                height: 24.w,
                width: 24.w,
                size: 12.r,
                product: prod,
              ),
            )
          ],
        );
      },
    );
  }

}

Widget buildAddUrProduct(BuildContext context) {
  return InkWell(
    onTap: () {
      context.push(ProductAddPage.routeName);
    },
    child: Card(
      elevation: 1.r,
      child: Container(
        height: 244.h,
        width: 169.w,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 70.sp, color: Color(0xff575757)),
            SizedBox(height: 10.h),
            Text(
              "Add your\nProduct",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                // color: Color(0xff2F2F2F),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildProfileSection(VendorDetailsModel vendor) {
  return Column(
    children: [
      Center(
        child: Stack(
          children: [
            Container(
              height: 82.w,
              width: 82.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 1.w,
                  color: AllColor.loginButtomColor,
                ),
                image: DecorationImage(
                  image: NetworkImage(vendor.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 15.h,
              left: 4.w,
              child: Container(
                height: 10.w,
                width: 10.w,
                decoration: BoxDecoration(
                  color: AllColor.activityColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 10.h,
              right: 0.w,
              child: CircleAvatar(radius: 10.r, child: Icon(Icons.edit)),
            ),
          ],
        ),
      ),
      SizedBox(height: 20.h),
      Text(
        vendor.name,
        style: TextStyle(fontSize: 16.sp, color: AllColor.loginButtomColor),
      ),
    ],
  );
}

class CategoryBar extends ConsumerStatefulWidget {
  const CategoryBar({
    super.key,
    required this.endpoint,
    required this.onCategorySelected,
  });

  final String endpoint;
  final Function(int categoryId) onCategorySelected;

  @override
  ConsumerState<CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends ConsumerState<CategoryBar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final categoryAsync = ref.watch(vendorCategoryProvider(widget.endpoint));

    return categoryAsync.when(
      data: (categories) {
        final names = ['All', ...categories.map((e) => e.name).toList()];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(names.length, (index) {
              final isSelected = selectedIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() => selectedIndex = index);

                  int selectedId = 0;
                  if (index > 0) {
                    selectedId = categories[index - 1].id;
                  }

                  widget.onCategorySelected(selectedId);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AllColor.orange : Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Text(
                    names[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('Category load error: $e'),
    );
  }
}