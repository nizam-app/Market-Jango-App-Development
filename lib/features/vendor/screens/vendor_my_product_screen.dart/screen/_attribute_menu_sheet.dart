import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/product_edit/data/product_attribute_data.dart';
import 'package:market_jango/features/vendor/screens/product_edit/model/product_attribute_response_model.dart';

class AttributeMenuSheet extends ConsumerStatefulWidget {
  const AttributeMenuSheet({
    super.key,
    required this.vendorId,
    required this.onAttributeTapped,
  });

  final int vendorId;
  final Function(VendorProductAttribute) onAttributeTapped;

  @override
  ConsumerState<AttributeMenuSheet> createState() =>
      _AttributeMenuSheetState();
}

class _AttributeMenuSheetState extends ConsumerState<AttributeMenuSheet> {
  final TextEditingController _nameController = TextEditingController();
  final Map<int, TextEditingController> _editControllers = {};

  @override
  void dispose() {
    _nameController.dispose();
    _editControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<void> _createAttribute() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: 'Validation',
        message: 'Please enter attribute name',
      );
      return;
    }

    try {
      await createAttribute(
        name: name,
        vendorId: widget.vendorId,
      );
      _nameController.clear();
      ref.invalidate(productAttributesProvider);
      GlobalSnackbar.show(
        context,
        title: 'Success',
        message: 'Attribute created successfully',
        type: CustomSnackType.success,
      );
    } catch (e) {
      GlobalSnackbar.show(
        context,
        title: 'Error',
        message: 'Failed to create attribute: ${e.toString()}',
        type: CustomSnackType.error,
      );
    }
  }

  Future<void> _updateAttribute(int attributeId, String currentName) async {
    final controller = _editControllers[attributeId];
    if (controller == null) return;

    final newName = controller.text.trim();
    if (newName.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: 'Validation',
        message: 'Attribute name cannot be empty',
      );
      return;
    }

    if (newName == currentName) {
      setState(() {
        _editControllers[attributeId]?.dispose();
        _editControllers.remove(attributeId);
      });
      return;
    }

    try {
      await updateAttribute(
        attributeId: attributeId,
        name: newName,
      );
      setState(() {
        _editControllers[attributeId]?.dispose();
        _editControllers.remove(attributeId);
      });
      ref.invalidate(productAttributesProvider);
      GlobalSnackbar.show(
        context,
        title: 'Success',
        message: 'Attribute updated successfully',
        type: CustomSnackType.success,
      );
    } catch (e) {
      GlobalSnackbar.show(
        context,
        title: 'Error',
        message: 'Failed to update attribute: ${e.toString()}',
        type: CustomSnackType.error,
      );
    }
  }

  Future<void> _deleteAttribute(int attributeId, String attributeName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Attribute'),
        content: Text('Are you sure you want to delete "$attributeName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await deleteAttribute(attributeId: attributeId);
      ref.invalidate(productAttributesProvider);
      GlobalSnackbar.show(
        context,
        title: 'Success',
        message: 'Attribute deleted successfully',
        type: CustomSnackType.success,
      );
    } catch (e) {
      GlobalSnackbar.show(
        context,
        title: 'Error',
        message: 'Failed to delete attribute: ${e.toString()}',
        type: CustomSnackType.error,
      );
    }
  }

  void _startEdit(int attributeId, String currentName) {
    setState(() {
      _editControllers[attributeId] = TextEditingController(text: currentName);
    });
  }

  void _cancelEdit(int attributeId) {
    setState(() {
      _editControllers[attributeId]?.dispose();
      _editControllers.remove(attributeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final attributesAsync = ref.watch(productAttributesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      
      builder: (ctx, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Modern handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              width: 50.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AllColor.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            
            // Header section with gradient
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AllColor.blue.withOpacity(0.1),
                    AllColor.blue50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AllColor.blue,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.category_outlined,
                      color: Colors.white,
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Attributes',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AllColor.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Manage your product attributes',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AllColor.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Add new attribute section - Exact same design
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AllColor.grey.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          color: AllColor.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add your custom attribute',
                          hintStyle: TextStyle(
                            color: AllColor.grey.shade400,
                            fontSize: 15.sp,
                          ),
                          fillColor: AllColor.white,
                          filled: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                        ),
                        onSubmitted: (_) => _createAttribute(),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 12.w),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _createAttribute,
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            child: Icon(
                              Icons.add_rounded,
                              color: AllColor.black,
                              size: 24.r,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Section header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: AllColor.blue,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Existing Attributes',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AllColor.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  attributesAsync.when(
                    data: (response) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AllColor.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${response.data.length}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AllColor.blue,
                        ),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Attributes list
            Expanded(
              child: attributesAsync.when(
                loading: () => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AllColor.blue),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Loading attributes...',
                        style: TextStyle(
                          color: AllColor.grey.shade600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48.r,
                        color: Colors.red.shade300,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Error loading attributes',
                        style: TextStyle(
                          color: AllColor.grey.shade700,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        e.toString(),
                        style: TextStyle(
                          color: AllColor.grey.shade500,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                data: (response) {
                  final attrs = response.data;
                  if (attrs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(24.r),
                            decoration: BoxDecoration(
                              color: AllColor.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 64.r,
                              color: AllColor.blue,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'No attributes yet',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AllColor.black87,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Create your first attribute to get started',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AllColor.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: attrs.length,
                    itemBuilder: (ctx, index) {
                      final attr = attrs[index];
                      final isEditing = _editControllers.containsKey(attr.id);
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AllColor.grey.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isEditing
                                ? null
                                : () => widget.onAttributeTapped(attr),
                            borderRadius: BorderRadius.circular(16.r),
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    padding: EdgeInsets.all(10.r),
                                    decoration: BoxDecoration(
                                      color: AllColor.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Icon(
                                      Icons.label,
                                      color: AllColor.blue,
                                      size: 20.r,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  
                                  // Attribute name
                                  Expanded(
                                    child: isEditing
                                        ? TextField(
                                            controller: _editControllers[attr.id],
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AllColor.black,
                                            ),
                                            decoration: InputDecoration(
                                              fillColor: AllColor.white,
                                              filled: true,
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              isDense: true,
                                            ),
                                            autofocus: true,
                                            onSubmitted: (_) =>
                                                _updateAttribute(attr.id, attr.name),
                                          )
                                        : Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                attr.name,
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: AllColor.black,
                                                ),
                                              ),
                                              if (attr.attributeValues.isNotEmpty)
                                                Padding(
                                                  padding: EdgeInsets.only(top: 4.h),
                                                  child: Text(
                                                    '${attr.attributeValues.length} value${attr.attributeValues.length > 1 ? 's' : ''}',
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: AllColor.grey.shade600,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                  ),
                                  SizedBox(width: 8.w),
                                  
                                  // Action buttons
                                  if (isEditing)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: IconButton(
                                            onPressed: () =>
                                                _updateAttribute(attr.id, attr.name),
                                            icon: const Icon(
                                              Icons.check_rounded,
                                              color: Colors.green,
                                            ),
                                            iconSize: 22.r,
                                            tooltip: 'Save',
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: IconButton(
                                            onPressed: () => _cancelEdit(attr.id),
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              color: Colors.red,
                                            ),
                                            iconSize: 22.r,
                                            tooltip: 'Cancel',
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AllColor.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: IconButton(
                                            onPressed: () => _startEdit(attr.id, attr.name),
                                            icon: Icon(
                                              Icons.edit_rounded,
                                              color: AllColor.blue,
                                            ),
                                            iconSize: 20.r,
                                            tooltip: 'Edit',
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: IconButton(
                                            onPressed: () =>
                                                _deleteAttribute(attr.id, attr.name),
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.red,
                                            ),
                                            iconSize: 20.r,
                                            tooltip: 'Delete',
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

