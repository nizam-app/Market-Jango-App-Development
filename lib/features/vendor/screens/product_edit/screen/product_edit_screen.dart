import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/product_edit/data/product_attribute_data.dart';
import 'package:market_jango/features/vendor/screens/product_edit/logic/delete_image_riverpod.dart';
import 'package:market_jango/features/vendor/screens/product_edit/logic/update_product_riverpod.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/data/vendor_product_category_riverpod.dart';
import 'package:market_jango/features/vendor/screens/vendor_product_add_page/data/selecd_color_size_list.dart';
import 'package:market_jango/features/vendor/screens/vendor_product_add_page/widget/generic_attribute_picker.dart';

import '../../../widgets/custom_back_button.dart';
import '../../vendor_home/model/vendor_product_model.dart';

class ProductEditScreen extends ConsumerStatefulWidget {
  const ProductEditScreen({super.key, required this.product});

  final VendorProduct product;

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
    final selectedAttributes = ref.watch(selectedAttributesProvider);
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
                      child: mainImage != null
                          ? Image.file(mainImage!, fit: BoxFit.cover)
                          : FirstTimeShimmerImage(
                              imageUrl: widget.product.image,
                              fit: BoxFit.cover,
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  _Label('Category', color: const Color(0xFF436AA0)),
                  SizedBox(height: 6.h),

                  /// --- state ---
                  //  int? _selectedCategoryId; // ✅ use id, not name
                  categoryAsync.when(
                    data: (categories) {
                      if (categories.isEmpty)
                        return const Text("No category found");

                      // ✅ ensure selected id exists
                      final bool selectedExists =
                          _selectedCategoryId != null &&
                          categories.any((c) => c.id == _selectedCategoryId);

                      // ✅ set default only if null OR not exists
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        if (_selectedCategoryId == null || !selectedExists) {
                          final match = categories
                              .where(
                                (c) => c.name == widget.product.categoryName,
                              )
                              .toList();

                          setState(() {
                            _selectedCategoryId = match.isNotEmpty
                                ? match.first.id
                                : categories.first.id;
                          });
                        }
                      });

                      return DropdownButton<int>(
                        isExpanded: true,
                        value: selectedExists ? _selectedCategoryId : null,
                        hint: const Text("Select category"),
                        items: categories.map((c) {
                          return DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(c.name),
                          );
                        }).toList(),
                        onChanged: (id) {
                          setState(() => _selectedCategoryId = id);
                        },
                      );
                    },
                    loading: () => const Text("Loading..."),
                    error: (e, _) => Text("Error: $e"),
                  ),

                  SizedBox(height: 10.h),

                  /// Product Name
                  _Label(
                    ref.t(BKeys.product_title),
                    color: const Color(0xFF436AA0),
                  ),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      fillColor: AllColor.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AllColor.grey,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AllColor.grey,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  /// Description
                  _Label(
                    ref.t(BKeys.destination),
                    color: const Color(0xFF436AA0),
                  ),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      fillColor: AllColor.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AllColor.grey,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AllColor.grey,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),

                  /// Attributes Dropdown
                  attributeAsync.when(
                    data: (data) {
                      return GenericAttributePicker(attributes: data.data);
                    },
                    loading: () => const Center(child: Text('Loading...')),
                    error: (err, _) => Center(child: Text('Error: $err')),
                  ),

                  SizedBox(height: 15.h),

                  /// Price
                  _Label('Current price', color: const Color(0xFF2B6CB0)),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      fillColor: AllColor.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AllColor.grey,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AllColor.grey,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  /// Stock
                  _Label('Stock', color: const Color(0xFF2B6CB0)),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      fillColor: AllColor.white,
                      hintText: 'Enter Stock Quantity',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AllColor.grey,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AllColor.grey,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  Align(
                    alignment: Alignment.topLeft,
                    child: ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              String? nn(String s) =>
                                  s.trim().isEmpty ? null : s.trim();

                              await ref
                                  .read(updateProductProvider.notifier)
                                  .updateProduct(
                                    id: widget.product.id,
                                    name: nn(nameController.text),
                                    description: nn(descriptionController.text),

                                    // ✅ map to API keys
                                    regularPrice: nn(
                                      widget.product.regularPrice.toString(),
                                    ), // or controller থাকলে controller.text
                                    sellPrice: nn(priceController.text),

                                    categoryId: _selectedCategoryId,
                                    attributes:
                                        ref
                                            .read(selectedAttributesProvider)
                                            .isEmpty
                                        ? null
                                        : ref.read(selectedAttributesProvider),
                                    stock: nn(stockController.text),
                                    image: mainImage,
                                    newFiles: _newFiles,
                                  );

                              final res = ref.read(updateProductProvider);
                              res.when(
                                data: (_) {
                                  context.pop();
                                  GlobalSnackbar.show(
                                    context,
                                    title: "Success",
                                    message: "Product updated successfully",
                                  );
                                  ref.invalidate(updateProductProvider);
                                },
                                loading: () {},
                                error: (e, _) {
                                  GlobalSnackbar.show(
                                    context,
                                    title: "Error",
                                    message: "Product updated failed",
                                    type: CustomSnackType.error,
                                  );
                                },
                              );
                            },
                      child: Text(saving ? 'Saving...' : ref.t(BKeys.save)),
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

  late TextEditingController stockController;

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
    stockController = TextEditingController();
    _selectedCategory = widget.product.categoryName;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Parse attributes from JSON string if available
      Map<String, List<String>> parsedAttributes = {};
      if (widget.product.attributes != null &&
          widget.product.attributes!.isNotEmpty) {
        try {
          final decoded = jsonDecode(widget.product.attributes!);
          if (decoded is Map) {
            decoded.forEach((key, value) {
              if (value is List) {
                parsedAttributes[key.toString()] = value
                    .map((e) => e.toString())
                    .toList();
              }
            });
          }
        } catch (e) {
          // If parsing fails, fall back to color/size
          if (widget.product.colors.isNotEmpty) {
            parsedAttributes['color'] = widget.product.colors;
          }
          if (widget.product.sizes.isNotEmpty) {
            parsedAttributes['size'] = widget.product.sizes;
          }
        }
      } else {
        // Fallback to color/size if attributes is null
        if (widget.product.colors.isNotEmpty) {
          parsedAttributes['color'] = widget.product.colors;
        }
        if (widget.product.sizes.isNotEmpty) {
          parsedAttributes['size'] = widget.product.sizes;
        }
      }
      ref.read(selectedAttributesProvider.notifier).state = parsedAttributes;
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
    ref.invalidate(selectedAttributesProvider);
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();

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

  final VendorProduct product;
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
              overlay: spinning
                  ? const Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white),
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
              child: FirstTimeShimmerImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
              ),
            );
          } else {
            // Local added tile
            final localIdx = index - serverImages.length;
            final file = _localAdded[localIdx];

            return _ImageTile(
              size: 76.w,
              overlay: const Icon(Icons.clear, color: Colors.white),
              onTap: () {
                setState(() => _localAdded.removeAt(localIdx));
                widget.onLocalAddedChanged?.call(List<File>.from(_localAdded));
              },
              child: Image.file(file, fit: BoxFit.cover),
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

class _Label extends StatelessWidget {
  const _Label(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
