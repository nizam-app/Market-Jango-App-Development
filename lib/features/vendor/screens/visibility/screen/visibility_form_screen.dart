import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';
import 'package:market_jango/features/vendor/screens/visibility/data/visibility_data.dart';
import 'package:market_jango/features/vendor/screens/visibility/model/visibility_model.dart';

class VisibilityFormScreen extends ConsumerStatefulWidget {
  const VisibilityFormScreen({super.key, this.visibility});

  static const String routeName = '/vendor_visibility_form';

  final VisibilityModel? visibility;

  @override
  ConsumerState<VisibilityFormScreen> createState() =>
      _VisibilityFormScreenState();
}

class _VisibilityFormScreenState extends ConsumerState<VisibilityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _townController = TextEditingController();

  int? _selectedProductId;
  bool _isActive = true;
  bool _loading = false;

  bool get isEdit => widget.visibility != null;

  @override
  void initState() {
    super.initState();
    if (widget.visibility != null) {
      final v = widget.visibility!;
      _countryController.text = v.country ?? '';
      _stateController.text = v.state ?? '';
      _townController.text = v.town ?? '';
      _isActive = v.isActive;
      _selectedProductId = v.productId;
    }
  }

  @override
  void dispose() {
    _countryController.dispose();
    _stateController.dispose();
    _townController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(vendorProductsForVisibilityProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AllColor.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: const CustomBackButton(),
        ),
        title: Text(
          isEdit ? 'Edit visibility' : 'Add visibility',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderSection(isEdit: isEdit),
              SizedBox(height: 28.h),
              if (!isEdit) ...[
                _ProductSection(
                  productsAsync: productsAsync,
                  selectedProductId: _selectedProductId,
                  onChanged: (v) => setState(() => _selectedProductId = v),
                ),
                SizedBox(height: 24.h),
              ],
              _LocationSection(
                countryController: _countryController,
                stateController: _stateController,
                townController: _townController,
              ),
              SizedBox(height: 24.h),
              _ActiveSwitch(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              SizedBox(height: 32.h),
              _SubmitButton(
                isEdit: isEdit,
                loading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!isEdit && (_selectedProductId == null || _selectedProductId == 0)) {
      GlobalSnackbar.show(
        context,
        title: 'Error',
        message: 'Select a product',
        type: CustomSnackType.error,
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final token = await ref.read(authTokenProvider.future);
      final country = _countryController.text.trim();
      final state = _stateController.text.trim();
      final town = _townController.text.trim();

      if (isEdit) {
        await visibilityUpdate(
          token,
          visibilityId: widget.visibility!.id,
          country: country.isEmpty ? null : country,
          state: state.isEmpty ? null : state,
          town: town.isEmpty ? null : town,
          isActive: _isActive,
          onSuccess: () {
            ref.read(visibilityDashboardProvider.notifier).refresh();
          },
        );
        if (mounted) {
          GlobalSnackbar.show(
            context,
            title: 'Done',
            message: 'Visibility updated',
            type: CustomSnackType.success,
          );
          context.pop();
        }
      } else {
        await visibilitySet(
          token,
          productId: _selectedProductId!,
          country: country.isEmpty ? null : country,
          state: state.isEmpty ? null : state,
          town: town.isEmpty ? null : town,
          isActive: _isActive,
          onSuccess: () {
            ref.read(visibilityDashboardProvider.notifier).refresh();
          },
        );
        if (mounted) {
          GlobalSnackbar.show(
            context,
            title: 'Done',
            message: 'Visibility added',
            type: CustomSnackType.success,
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Error',
          message: e.toString(),
          type: CustomSnackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _HeaderSection extends StatelessWidget {
  final bool isEdit;

  const _HeaderSection({required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AllColor.loginButtomColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(
            isEdit ? Icons.edit_location_alt_rounded : Icons.add_location_alt_rounded,
            size: 28.r,
            color: AllColor.loginButtomColor,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit visibility' : 'Set where product is visible',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AllColor.black,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                isEdit
                    ? 'Update location or active status'
                    : 'Choose product and location (empty = global)',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AllColor.grey500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductSection extends StatelessWidget {
  final AsyncValue<List<ProductOption>> productsAsync;
  final int? selectedProductId;
  final ValueChanged<int?> onChanged;

  const _ProductSection({
    required this.productsAsync,
    required this.selectedProductId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AllColor.grey500,
          ),
        ),
        SizedBox(height: 10.h),
        productsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AllColor.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AllColor.grey200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 24.r, color: AllColor.grey500),
                    SizedBox(width: 12.w),
                    Text(
                      'No products. Add products first.',
                      style: TextStyle(fontSize: 14.sp, color: AllColor.grey500),
                    ),
                  ],
                ),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: AllColor.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AllColor.grey200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<int>(
                      value: selectedProductId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AllColor.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      ),
                      hint: _ProductTile(
                        option: ProductOption(id: 0, name: 'Select product', image: null),
                        isHint: true,
                      ),
                      items: products
                          .map((p) => DropdownMenuItem<int>(
                                value: p.id,
                                child: _ProductTile(option: p, isHint: false),
                              ))
                          .toList(),
                      onChanged: onChanged,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: AllColor.grey500, size: 24.r),
                      validator: (v) {
                        if (v == null || v == 0) return 'Select a product';
                        return null;
                      },
                    ),
                  ),
                );
              },
            );
          },
          loading: () => Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: AllColor.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (e, _) => Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AllColor.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Text(
              e.toString().replaceFirst('Exception: ', ''),
              style: TextStyle(fontSize: 13.sp, color: AllColor.red),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  final ProductOption option;
  final bool isHint;

  const _ProductTile({required this.option, this.isHint = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 44.w,
          height: 44.w,
          child: option.id == 0 && isHint
              ? _ProductImagePlaceholder(size: 40.w)
              : _ProductImage(imageUrl: option.image, size: 44.w),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            option.name,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: isHint ? AllColor.grey500 : AllColor.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const _ProductImage({this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: SizedBox(
          width: size,
          height: size,
          child: FirstTimeShimmerImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return _ProductImagePlaceholder(size: size);
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  final double size;

  const _ProductImagePlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AllColor.grey200,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(Icons.image_outlined, size: size * 0.5, color: AllColor.grey500),
    );
  }
}

class _LocationSection extends StatelessWidget {
  final TextEditingController countryController;
  final TextEditingController stateController;
  final TextEditingController townController;

  const _LocationSection({
    required this.countryController,
    required this.stateController,
    required this.townController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location (leave empty for global)',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AllColor.grey500,
          ),
        ),
        SizedBox(height: 12.h),
        _LocationField(
          controller: countryController,
          label: 'Country',
          hint: 'e.g. USA',
          icon: Icons.public_rounded,
        ),
        SizedBox(height: 14.h),
        _LocationField(
          controller: stateController,
          label: 'State',
          hint: 'e.g. California',
          icon: Icons.map_rounded,
        ),
        SizedBox(height: 14.h),
        _LocationField(
          controller: townController,
          label: 'Town',
          hint: 'e.g. Los Angeles',
          icon: Icons.location_city_rounded,
        ),
      ],
    );
  }
}

class _LocationField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  const _LocationField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: TextStyle(fontSize: 15.sp),
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        prefixIcon: Icon(icon, size: 22.r, color: AllColor.grey500),
        filled: true,
        fillColor: AllColor.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: AllColor.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: AllColor.loginButtomColor, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }
}

class _ActiveSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ActiveSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          'Active',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AllColor.black),
        ),
        subtitle: Text(
          value ? 'This visibility rule is active' : 'Visibility is paused',
          style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AllColor.loginButtomColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isEdit;
  final bool loading;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isEdit,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.h,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AllColor.loginButtomColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        child: loading
            ? SizedBox(
                height: 24.h,
                width: 24.w,
                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isEdit ? Icons.check_rounded : Icons.add_rounded, size: 22.r),
                  SizedBox(width: 8.w),
                  Text(
                    isEdit ? 'Update' : 'Add visibility',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}
