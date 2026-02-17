import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/Keys/vendor_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/models/global_search_model.dart';
import 'package:market_jango/core/screen/profile_screen/logic/user_data_update_riverpod.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/custom_new_product.dart';
import 'package:market_jango/core/widget/global_pagination.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/core/widget/global_search_bar.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/data/global_search_riverpod.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/model/vendor_product_model.dart';
import 'package:market_jango/features/vendor/screens/vendor_track_shipment/screen/vendor_track_shipment.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';
import 'package:market_jango/features/vendor/widgets/edit_widget.dart';
import 'package:market_jango/features/buyer/screens/review/review_screen.dart';

import '../../../../../core/constants/api_control/vendor_api.dart';
import '../../vendor_product_add_page/screen/product_add_page.dart';
import '../../visibility/screen/visibility_management_screen.dart';
import 'package:market_jango/features/affiliate/screen/affiliate_screen.dart';
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
        endDrawer: Drawer(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: buildDrawer(context, ref),
        ),
        body: Builder(
          builder: (innerContext) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(vendorProvider);
                ref.invalidate(productNotifierProvider);
                ref.invalidate(vendorCategoryProvider(VendorAPIController.vendor_category));
                await ref.read(vendorProvider.future);
                await ref.read(productNotifierProvider.future);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    vendorAsync.when(
                      data: (vendor) => buildCoverAndProfileSection(innerContext, ref, vendor),
                      loading: () => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 5.h),
                        child: const Center(child: Text('Loading...')),
                      ),
                      error: (err, _) => Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Text('Error: $err'),
                      ),
                    ),
                    // SizedBox(height: 1.h),
                    // // Document Upload Section
                    // Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 20.w),
                    //   child: DocumentUploadSection(),
                    // ),
                    SizedBox(height: 20.h),
                    GlobalSearchBar<GlobalSearchResponse, GlobalSearchProduct>(
                      provider: searchProvider,
                      itemsSelector: (res) => res.products,
                      itemBuilder: (context, p) => ProductSuggestionTile(p: p),
                      onItemSelected: (p) {},

                      hintText: ref.t(VKeys.searchProducts),

                      debounce: const Duration(seconds: 1),
                      minChars: 1,
                      showResults: true,
                      resultsMaxHeight: 380,
                      autofocus: false,
                    ),
                    SizedBox(height: 15.h),
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
                      loading: () =>
                          const Center(child: Text('Loading...')),
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

  Widget buildDrawer(BuildContext context, WidgetRef ref) {
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
              context.push(VendorShipmentsScreen.routeName);
            },
            child: ListTile(
              leading: ImageIcon(
                const AssetImage("assets/icon/bag.png"),
                size: 20.r,
              ),
              title: Text(
                ref.t(BKeys.order),
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
                // "Sale",
                ref.t(BKeys.sales),
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
              final vendorAsync = ref.read(vendorProvider);
              vendorAsync.maybeWhen(
                data: (vendor) {
                  context.push(ReviewScreen.routeName, extra: vendor.id);
                },
                orElse: () {
                  // Handle case when vendor data is not available
                  GlobalSnackbar.show(
                    context,
                    title: "Error",
                    message: "Vendor information not available",
                    type: CustomSnackType.error,
                  );
                },
              );
            },
            child: ListTile(
              leading: const Icon(
                Icons.star_outline,
                size: 20,
                color: Colors.black,
              ),
              title: Text(
                ref.t(BKeys.review),
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
              context.push(VisibilityManagementScreen.routeName);
            },
            child: ListTile(
              leading: Icon(
                Icons.visibility_outlined,
                size: 20.r,
                color: Colors.black,
              ),
              title: Text(
                'Visibility',
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
              context.push(AffiliateScreen.routeName);
            },
            child: ListTile(
              leading: Icon(
                Icons.link,
                size: 20.r,
                color: Colors.black,
              ),
              title: Text(
                'Affiliate Links',
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
                // "Language",
                ref.t(BKeys.language),
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
                // "Log Out",
                ref.t(BKeys.logOut),
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

  Widget _buildProductGridViewSection(List<VendorProduct> products) {
    final safeProducts = products.whereType<VendorProduct>().toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 9 / 13,
        mainAxisSpacing: 10,
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
              width: 161,
              height: 168,
              productPrices: prod.sellPrice,
              productName: prod.name,
              image: prod.image,
              viewCount: prod.viewCount,
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
            ),
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

Widget buildProfileSection(BuildContext context, WidgetRef ref, VendorDetailsModel vendor) {
  // Check if image is null or empty
  final bool hasImage = vendor.image.isNotEmpty && vendor.image.trim().isNotEmpty;
  
  return Row(
    children: [
      Spacer(),
      Column(
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
                  ),
                  child: ClipOval(
                    child: hasImage
                        ? FirstTimeShimmerImage(
                            imageUrl: vendor.image,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.person,
                              size: 40.r,
                              color: Colors.grey.shade400,
                            ),
                          ),
                  ),
                ),

                // online dot
                Positioned(
                  top: 8.h,
                  left: 2.w,
                  child: Container(
                    height: 12.w,
                    width: 12.w,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.w, color: AllColor.grey100),
                      color: AllColor.activityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Profile image edit icon
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () => _handleProfileImageEdit(context, ref),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AllColor.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AllColor.loginButtomColor, width: 1.w),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 14.r,
                        color: AllColor.loginButtomColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Text(
            vendor.name,
            style: TextStyle(fontSize: 16.sp, color: AllColor.loginButtomColor),
          ),
        ],
      ),
      Spacer(),
      InkWell(
        onTap: () {
          Scaffold.of(context).openEndDrawer();
        },
        child: Icon(Icons.menu, size: 20.r, color: Colors.black),
      ),
    ],
  );
}

Widget buildCoverAndProfileSection(BuildContext context, WidgetRef ref, VendorDetailsModel vendor) {
  final bool hasCoverImage = vendor.coverImage != null && vendor.coverImage!.isNotEmpty;
  
  return Column(
    children: [
      // Cover image section (Facebook style - at the top, no padding)
      Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
            child: Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: hasCoverImage
                  ? FirstTimeShimmerImage(
                      imageUrl: vendor.coverImage!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 50.r,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
            ),
          ),
          Positioned(
            bottom: 10.h,
            right: 10.w,
            child: InkWell(
              onTap: () => _handleCoverImageEdit(context, ref),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AllColor.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, size: 16.r, color: AllColor.loginButtomColor),
                    SizedBox(width: 6.w),
                    Text(
                      hasCoverImage ? 'Edit Cover' : 'Add Cover',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AllColor.loginButtomColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Profile section positioned below cover image (overlapping like Facebook)
      Transform.translate(
        offset: Offset(0, -41.w), // Move profile image up to overlap cover
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: buildProfileSection(context, ref, vendor),
        ),
      ),
      SizedBox(height: 20.h), // Add spacing after profile section
    ],
  );
}

Widget buildCoverImageSection(BuildContext context, WidgetRef ref, VendorDetailsModel vendor) {
  final bool hasCoverImage = vendor.coverImage != null && vendor.coverImage!.isNotEmpty;
  
  return Consumer(
    builder: (context, ref, child) {
      return Stack(
        children: [
          Container(
            height: 180.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: hasCoverImage
                  ? FirstTimeShimmerImage(
                      imageUrl: vendor.coverImage!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 50.r,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
            ),
          ),
          Positioned(
            bottom: 10.h,
            right: 10.w,
            child: InkWell(
              onTap: () => _handleCoverImageEdit(context, ref),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AllColor.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, size: 16.r, color: AllColor.loginButtomColor),
                    SizedBox(width: 6.w),
                    Text(
                      hasCoverImage ? 'Edit Cover' : 'Add Cover',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AllColor.loginButtomColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> _handleProfileImageEdit(BuildContext context, WidgetRef ref) async {
  final ImagePicker picker = ImagePicker();
  
  showModalBottomSheet(
    context: context,
    builder: (builder) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 85,
                );
                if (image != null) {
                  await _updateProfileImage(context, ref, File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                );
                if (image != null) {
                  await _updateProfileImage(context, ref, File(image.path));
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _updateProfileImage(BuildContext context, WidgetRef ref, File imageFile) async {
  try {
    final notifier = ref.read(updateUserProvider.notifier);
    final success = await notifier.updateUser(
      userType: 'vendor',
      image: imageFile,
    );
    
    if (success) {
      if (context.mounted) {
        ref.invalidate(vendorProvider);
        GlobalSnackbar.show(
          context,
          title: "Success",
          message: "Profile image updated successfully",
        );
      }
    } else {
      if (context.mounted) {
        GlobalSnackbar.show(
          context,
          title: "Error",
          message: "Failed to update profile image",
          type: CustomSnackType.error,
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      GlobalSnackbar.show(
        context,
        title: "Error",
        message: e.toString(),
        type: CustomSnackType.error,
      );
    }
  }
}

Future<void> _handleCoverImageEdit(BuildContext context, WidgetRef ref) async {
  final ImagePicker picker = ImagePicker();
  
  showModalBottomSheet(
    context: context,
    builder: (builder) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 85,
                );
                if (image != null) {
                  await _updateCoverImage(context, ref, File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                );
                if (image != null) {
                  await _updateCoverImage(context, ref, File(image.path));
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _updateCoverImage(BuildContext context, WidgetRef ref, File imageFile) async {
  try {
    final notifier = ref.read(updateUserProvider.notifier);
    final success = await notifier.updateUser(
      userType: 'vendor',
      coverImage: imageFile,
    );
    
    if (success) {
      if (context.mounted) {
        // Invalidate vendorProvider to refetch from user/show API
        ref.invalidate(vendorProvider);
        // Wait for the provider to refresh
        await ref.read(vendorProvider.future);
        GlobalSnackbar.show(
          context,
          title: "Success",
          message: "Cover image updated successfully",
        );
      }
    } else {
      if (context.mounted) {
        // Wait a bit to ensure error state is set
        await Future.delayed(const Duration(milliseconds: 100));
        // Get error message from provider state
        final errorMsg = ref.read(updateUserProvider).maybeWhen(
          error: (error, _) => error.toString(),
          orElse: () => "Failed to update cover image. Please try again.",
        );
        GlobalSnackbar.show(
          context,
          title: "Error",
          message: errorMsg,
          type: CustomSnackType.error,
        );
      }
    }
  } catch (e, stackTrace) {
    if (context.mounted) {
      // Log the full error for debugging
      debugPrint('Cover image update error: $e');
      debugPrint('Stack trace: $stackTrace');
      GlobalSnackbar.show(
        context,
        title: "Error",
        message: "Failed to update cover image: ${e.toString()}",
        type: CustomSnackType.error,
      );
    }
  }
}

class DocumentUploadSection extends ConsumerStatefulWidget {
  const DocumentUploadSection({super.key});

  @override
  ConsumerState<DocumentUploadSection> createState() => _DocumentUploadSectionState();
}

class _DocumentUploadSectionState extends ConsumerState<DocumentUploadSection> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedImages = await _picker.pickMultiImage(
        imageQuality: 85,
      );

      if (pickedImages.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedImages);
        });
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: "Error",
          message: "Failed to pick images: ${e.toString()}",
          type: CustomSnackType.error,
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        setState(() {
          _selectedImages.add(pickedImage);
        });
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: "Error",
          message: "Failed to capture image: ${e.toString()}",
          type: CustomSnackType.error,
        );
      }
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery (Multiple)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Text(
            "Upload your driving license & other documents",
            style: TextStyle(fontSize: 14.sp, color: AllColor.black),
          ),
        ),
        SizedBox(height: 12.h),
        InkWell(
          onTap: _showImageSourceOptions,
          child: Container(
            height: 60.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              border: Border.all(
                  color: AllColor.textBorderColor, width: 0.5.sp),
              borderRadius: BorderRadius.circular(30.r),
              color: AllColor.orange50,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedImages.isEmpty
                      ? 'Upload Multiple Files'
                      : '${_selectedImages.length} file(s) selected',
                  style: TextStyle(
                    color: AllColor.textHintColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Stack(
                  children: [
                    Icon(
                      Icons.description,
                      color: AllColor.textHintColor,
                      size: 24.sp,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AllColor.loginButtomColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Display selected images
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(height: 15.h),
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: 10.w),
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AllColor.textBorderColor,
                      width: 0.5.sp,
                    ),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Image.file(
                          File(_selectedImages[index].path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 5.h,
                        right: 5.w,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
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
        final names = ['All', ...categories.map((e) => e.name)];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(names.length, (index) {
              final isSelected = selectedIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() => selectedIndex = index);

                  int selectedId = 0;
                  if (index > 0 && index - 1 < categories.length) {
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
                    color: isSelected ? AllColor.orange : AllColor.grey100,
                    borderRadius: BorderRadius.circular(5.r),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black12,
                    //     blurRadius: 2.r,
                    //     offset: Offset(5, 2.h),
                    //   ),
                    // ],
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
        child: Center(child: Text('Loading...')),
      ),
      error: (e, _) => Text('Category load error: $e'),
    );
  }
}
