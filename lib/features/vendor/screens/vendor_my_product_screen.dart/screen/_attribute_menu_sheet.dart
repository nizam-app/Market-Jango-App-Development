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
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Attributes',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Add new attribute section
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: AllColor.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'Enter attribute name',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                            ),
                            onSubmitted: (_) => _createAttribute(),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        IconButton(
                          onPressed: _createAttribute,
                          icon: Icon(Icons.add_circle, color: AllColor.blue),
                          iconSize: 28.r,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Attributes list
                  Text(
                    'Existing Attributes:',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),

            // Attributes list
            Expanded(
              child: attributesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Error: ${e.toString()}'),
                ),
                data: (response) {
                  final attrs = response.data;
                  if (attrs.isEmpty) {
                    return Center(
                      child: Text(
                        'No attributes found',
                        style: TextStyle(color: AllColor.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: attrs.length,
                    itemBuilder: (ctx, index) {
                      final attr = attrs[index];
                      final isEditing = _editControllers.containsKey(attr.id);
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: AllColor.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: isEditing
                                  ? TextField(
                                      controller: _editControllers[attr.id],
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.symmetric(horizontal: 8.w),
                                      ),
                                      autofocus: true,
                                      onSubmitted: (_) =>
                                          _updateAttribute(attr.id, attr.name),
                                    )
                                  : GestureDetector(
                                      onTap: () => widget.onAttributeTapped(attr),
                                      child: Text(
                                        attr.name,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AllColor.black,
                                        ),
                                      ),
                                    ),
                            ),
                            SizedBox(width: 8.w),
                            if (isEditing)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _updateAttribute(attr.id, attr.name),
                                    icon: const Icon(Icons.check, color: Colors.green),
                                    iconSize: 20.r,
                                  ),
                                  IconButton(
                                    onPressed: () => _cancelEdit(attr.id),
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    iconSize: 20.r,
                                  ),
                                ],
                              )
                            else
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _startEdit(attr.id, attr.name),
                                    icon: Icon(Icons.edit, color: AllColor.blue),
                                    iconSize: 20.r,
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _deleteAttribute(attr.id, attr.name),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    iconSize: 20.r,
                                  ),
                                ],
                              ),
                          ],
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

