import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/product_edit/data/product_attribute_data.dart';
import 'package:market_jango/features/vendor/screens/product_edit/logic/delete_image_riverpod.dart';
import 'package:market_jango/features/vendor/screens/product_edit/logic/update_product_riverpod.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/data/vendor_product_category_riverpod.dart';
import 'package:market_jango/features/vendor/screens/vendor_product_add_page/data/selecd_color_size_list.dart';
import 'package:market_jango/features/vendor/screens/vendor_product_add_page/widget/custom_variant_picker.dart';

import '../../../widgets/custom_back_button.dart';
import '../../vendor_home/model/vendor_product_model.dart';
import '../model/product_attribute_response_model.dart';

class ProductEditScreen extends ConsumerStatefulWidget {
  const ProductEditScreen({super.key, required this.product});

  final Product product;

  static const String routeName = '/vendor_product_edit';

  @override
  ConsumerState<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends ConsumerState<ProductEditScreen> {
  int? _selectedCategoryId;
  List<File> _newFiles = [];

  @override
  Widget build(BuildContext context) {
    final categoryAsync = ref.watch(
      vendorCategoryProvider(VendorAPIController.vendor_category),
    );
    final attributeAsync = ref.watch(productAttributesProvider);
    final selectedColors = ref.watch(selectedColorsProvider);
    final selectedSizes = ref.watch(selectedSizesProvider);
    final saving = ref.watch(updateProductProvider).isLoading;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 439.h,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: mainImage != null
                              ? FileImage(mainImage!)
                              : NetworkImage(widget.product.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      right: 15,
                      child: GestureDetector(
                        onTap: () {
                          _askImageSource(isMain: true);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(top: 50, left: 30, child: CustomBackButton()),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 15.h),
                  // ProductEditScreen এর ভিতরে
                  ProductImageCarousel(
                    product: widget.product,
                    onLocalAddedChanged: (files) {
                      setState(() => _newFiles = files);
                    },
                  ),
                  SizedBox(height: 10.h),

                  /// Category Dropdown
                  categoryAsync.when(
                    data: (categories) {
                      final categoryNames = categories
                          .map((e) => e.name)
                          .toList();
                      return Theme(
                        data: dropTheme,
                        child: Container(
                          height: 56.h,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: AllColor.white,
                            // borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 14.r,
                                offset: Offset(0, 6.h),
                                color: Colors.black.withOpacity(0.06),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedCategory,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                              ),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.black87,
                              ),
                              items: categoryNames.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                    ),
                                    child: Text(e),
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) {
                                setState(() => _selectedCategory = v);
                                final selected = categories.firstWhere(
                                  (e) => e.name == v,
                                );
                                _selectedCategoryId = selected.id;
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                  ),

                  SizedBox(height: 10.h),

                  /// Product Name
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      fillColor: AllColor.white,
                      enabledBorder: OutlineInputBorder().copyWith(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedBorder: OutlineInputBorder().copyWith(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  /// Description
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      fillColor: AllColor.white,
                      enabledBorder: OutlineInputBorder().copyWith(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedBorder: OutlineInputBorder().copyWith(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),

                  /// Color & Size Dropdown
                  attributeAsync.when(
                    data: (data) {
                      final colorAttr = data.data.firstWhere(
                        (attr) => attr.name.toLowerCase() == 'color',
                        orElse: () => ProductAttribute(
                          id: 0,
                          name: '',
                          vendorId: 0,
                          attributeValues: [],
                        ),
                      );
                      final List<String> colorNames = colorAttr.attributeValues
                          .map((v) => v.name ?? "")
                          .toList();

                      final sizeAttr = data.data.firstWhere(
                        (attr) => attr.name.toLowerCase() == 'size',
                        orElse: () => ProductAttribute(
                          id: 0,
                          name: '',
                          vendorId: 0,
                          attributeValues: [],
                        ),
                      );
                      final List<String> sizeNames = sizeAttr.attributeValues
                          .map((v) => v.name ?? "")
                          .toList();

                      return CustomVariantPicker(
                        colors: colorNames,
                        sizes: sizeNames,
                        selectedColors: selectedColors,
                        selectedSizes: selectedSizes,
                        onColorsChanged: (list) {
                          ref.read(selectedColorsProvider.notifier).state = [
                            ...list,
                          ];
                        },
                        onSizesChanged: (list) {
                          ref.read(selectedSizesProvider.notifier).state = [
                            ...list,
                          ];
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                  ),

                  SizedBox(height: 15.h),

                  /// Price
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      fillColor: AllColor.white,
                      enabledBorder: OutlineInputBorder().copyWith(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedBorder: OutlineInputBorder().copyWith(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  /// Save Button
                  Align(
                    alignment: Alignment.topLeft,
                    child: ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              String? _nn(String s) =>
                                  s.trim().isEmpty ? null : s.trim();

                              await ref
                                  .read(updateProductProvider.notifier)
                                  .updateProduct(
                                    id: widget.product.id,
                                    name: _nn(nameController.text),
                                    description: _nn(
                                      descriptionController.text,
                                    ),
                                    currentPrice: _nn(priceController.text),
                                    // previousPrice দরকার হলে আলাদা ফিল্ড নিন
                                    categoryId: _selectedCategoryId,
                                    colors:
                                        ref.read(selectedColorsProvider).isEmpty
                                        ? null
                                        : ref.read(selectedColorsProvider),
                                    sizes:
                                        ref.read(selectedSizesProvider).isEmpty
                                        ? null
                                        : ref.read(selectedSizesProvider),

                                    image: mainImage,
                                    // nullable ok
                                    newFiles: _newFiles,
                                  );

                              final res = ref.read(updateProductProvider);
                              res.when(
                                data: (_) {
                                  context.pop();
                                  GlobalSnackbar.show(context, title: "Success", message: "Product updated successfully");
                                  ref.invalidate(updateProductProvider);
                                },
                                loading: () {},
                                error: (e, _) {
                                  GlobalSnackbar.show(context, title: "Error", message: "Product updated failed",type: CustomSnackType.error);
                                }
                              );
                            },
                      child: Text(saving ? 'Saving...' : 'Save'),
                    ),
                  ),
                  SizedBox(height: 15.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _selectedCategory;

  final ImagePicker _picker = ImagePicker();

  File? mainImage;
  List<File> extraImages = [];

  late TextEditingController nameController;

  late TextEditingController descriptionController;

  late TextEditingController priceController;

  final ThemeData dropTheme = ThemeData(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
  );

  @override
  void initState() {
    nameController = TextEditingController(text: widget.product.name);
    descriptionController = TextEditingController(
      text: widget.product.description,
    );
    priceController = TextEditingController(
      text: widget.product.sellPrice.toString(),
    );
    _selectedCategory = widget.product.categoryName;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedColorsProvider.notifier).state = [
        ...widget.product.colors,
      ];
      ref.read(selectedSizesProvider.notifier).state = [
        ...widget.product.sizes,
      ];
    });
  }

  Future<void> pickMainImage(source) async {
    final xFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (xFile != null) {
      setState(() => mainImage = File(xFile.path));
    }
  }

  Future<void> pickExtraImage(source) async {
    final xFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (xFile != null) {
      setState(() => extraImages.add(File(xFile.path)));
    }
  }

  void _askImageSource({required bool isMain}) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  isMain
                      ? pickMainImage(ImageSource.camera)
                      : pickExtraImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  isMain
                      ? pickMainImage(ImageSource.gallery)
                      : pickExtraImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    ref.invalidate(selectedColorsProvider);
    ref.invalidate(selectedSizesProvider);
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();

    // TODO: implement dispose
    super.dispose();
  }
}

class ProductImageCarousel extends ConsumerStatefulWidget {
  const ProductImageCarousel({
    super.key,
    required this.product,
    this.onLocalAddedChanged, // parent-এ লোকাল ফাইলের লিস্ট দিতে চাইলে
  });

  final Product product;
  final ValueChanged<List<File>>? onLocalAddedChanged;

  @override
  ConsumerState<ProductImageCarousel> createState() =>
      _ProductImageCarouselState();
}

class _ProductImageCarouselState extends ConsumerState<ProductImageCarousel> {
  final ImagePicker _picker = ImagePicker();

  int? _deletingId; // কোন টাইল স্পিন করবে
  final Set<int> _removedIds =
      <int>{}; // সার্ভার ইমেজ যেগুলো মুছে গেছে (UI থেকে লুকানো)
  final List<File> _localAdded = <File>[];

  Future<void> _askImageSource() async {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAndAdd(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAndAdd(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndAdd(ImageSource source) async {
    final x = await _picker.pickImage(source: source, imageQuality: 85);
    if (x == null) return;
    if (!mounted) return;
    setState(() => _localAdded.add(File(x.path)));
    widget.onLocalAddedChanged?.call(List<File>.from(_localAdded));
  }

  @override
  Widget build(BuildContext context) {
    // সার্ভারের ইমেজ (যেগুলো মুছে ফেলিনি)
    final serverImages = widget.product.images
        .where((e) => !_removedIds.contains(e.id))
        .toList();

    final asyncDel = ref.watch(deleteProductImageProvider);

    return SizedBox(
      height: 86.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        // সার্ভার + লোকাল + শেষে Add বক্স
        itemCount: serverImages.length + _localAdded.length + 1,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          // --- Add new image box (last item)
          final lastIndex = serverImages.length + _localAdded.length;
          if (index == lastIndex) {
            return _AddBox(onTap: _askImageSource);
          }

          // --- কোন স্লটে আছি? (server / local)
          if (index < serverImages.length) {
            final img = serverImages[index];
            final imageUrl = img.imagePath.isNotEmpty
                ? img.imagePath
                : widget.product.image;
            final spinning = _deletingId == img.id && asyncDel.isLoading;

            return _ImageTile(
              size: 76.w,
              child: Image.network(imageUrl, fit: BoxFit.cover),
              overlay: spinning
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : const Icon(Icons.clear, color: Colors.white),
              onTap: spinning
                  ? null
                  : () async {
                      setState(() => _deletingId = img.id);
                      final ok = await ref
                          .read(deleteProductImageProvider.notifier)
                          .deleteById(img.id);
                      if (!mounted) return;
                      setState(() => _deletingId = null);

                      if (ok) {
                        setState(() => _removedIds.add(img.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Image deleted')),
                        );
                        // চাইলে এখানেই রিফেচ করতে পারেন:
                        // ref.invalidate(yourImagesFetchProvider(widget.product.id));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to delete image'),
                          ),
                        );
                      }
                    },
            );
          } else {
            // Local added tile
            final localIdx = index - serverImages.length;
            final file = _localAdded[localIdx];

            return _ImageTile(
              size: 76.w,
              child: Image.file(file, fit: BoxFit.cover),
              overlay: const Icon(Icons.clear, color: Colors.white),
              onTap: () {
                setState(() => _localAdded.removeAt(localIdx));
                widget.onLocalAddedChanged?.call(List<File>.from(_localAdded));
              },
            );
          }
        },
      ),
    );
  }
}

class _AddBox extends StatelessWidget {
  const _AddBox({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 76.w,
        width: 76.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6.r,
              offset: Offset(0, 3.h),
            ),
          ],
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Icon(
          Icons.add_a_photo_outlined,
          color: Colors.blueAccent,
          size: 24.sp,
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    required this.child,
    required this.overlay,
    required this.onTap,
    required this.size,
  });

  final Widget child;
  final Widget overlay; // spinner or ❌
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: size,
          width: size,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: child,
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.28),
                    shape: BoxShape.circle,
                  ),
                  child: overlay,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}