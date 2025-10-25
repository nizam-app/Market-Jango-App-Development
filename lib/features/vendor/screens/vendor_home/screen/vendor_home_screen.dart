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

import '../../../../../core/widget/global_pagination.dart';
import '../data/vendor_product_data.dart';
import '../logic/vendor_details_riverpod.dart';
import '../model/user_details_model.dart';

class VendorHomeScreen extends ConsumerStatefulWidget {
  const VendorHomeScreen({super.key});

  static const String routeName = '/vendor_home_screen';
  @override
  ConsumerState<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends ConsumerState<VendorHomeScreen> {
  String selectedFilter = "All"; // default selected filter

  List<String> filters = ['All'];

  int currentPage = 1;
  int selectedCategoryId = 0; // 0 → All
  String selectedCategoryName = 'All';

  @override
  Widget build(BuildContext context) {
    final vendorAsync = ref.watch(vendorProvider);
    final productAsync = ref.watch(productsProvider(currentPage));

    return SafeArea(
      child: Scaffold(
        endDrawer: Drawer(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: buildDrawer(context),
        ),
        body: Builder(
          builder: (context) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 25.h),
                    Container(
                      child: Stack(
                        children: [
                          vendorAsync.when(
                            data: (vendor) => buildProfileSection(vendor),
                            loading: () => const CircularProgressIndicator(),
                            error: (err, _) => Text('Error: $err'),
                          ),
                          Positioned(
                            top: 20.h,
                            right: 10.w,
                            child: GestureDetector(
                              onTap: () {
                                Scaffold.of(context).openEndDrawer();
                              },
                              child: Container(
                                height: 46.w,
                                width: 46.w,
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.menu,
                                  size: 24.sp,
                                ), // ☰ three-line menu
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.h),
                    CustomSearchBar(),
                    SizedBox(height: 10.h),
                    buildFilter(),
                    SizedBox(height: 15.h),
                    productAsync.when(
                      data: (paginated) {
                        final uniqueCategories = paginated.products
                            .map((e) => e.categoryName)
                            .toSet();
                        filters = ['All', ...uniqueCategories];

                        final filteredProducts = selectedFilter == 'All'
                            ? paginated.products
                            : paginated.products
                                  .where(
                                    (p) => p.categoryName == selectedFilter,
                                  )
                                  .toList();
                        return Column(
                          children: [
                            _buildProductGridViewSection(filteredProducts),
                            SizedBox(height: 20.h),
                            GlobalPagination(
                              currentPage: paginated.currentPage,
                              totalPages: paginated.lastPage,
                              onPageChanged: (page) {
                                setState(() {
                                  currentPage = page;
                                });
                              },
                            ),
                            SizedBox(height: 20.h),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                    ),
                  ],
                ),
              ),
            );
          },
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

  Widget buildFilter() {
    return Row(
      children: filters.map((filter) {
        final isSelected = selectedFilter == filter;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedFilter = filter;
            });
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 6.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? AllColor.loginButtomColor : Colors.white,
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Text(
              filter,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductGridViewSection(List<Product> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 9 / 13,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 15.w,
      ),
      itemCount: products.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return buildAddUrProduct(context);
        } else {
          final prod = products[index - 1];
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
                child: Edit_Widget(height: 24.w, width: 24.w, size: 12.r),
              ),
            ],
          );
        }
      },
    );
  }
}

Widget buildAddUrProduct(BuildContext context) {
  return Card(
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
              child: Edit_Widget(height: 21.w, width: 21.w, size: 10.r),
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
