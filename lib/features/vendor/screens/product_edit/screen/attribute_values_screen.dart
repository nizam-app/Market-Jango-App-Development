import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';

import '../../my_product_color/data/verndor_add_color_data_logic.dart';

/// Generic screen to manage attribute values (e.g., Color values, Size values, etc.)
class AttributeValuesScreen extends ConsumerStatefulWidget {
  const AttributeValuesScreen({
    super.key,
    required this.attributeId,
    required this.attributeName,
  });

  final int attributeId;
  final String attributeName;
  static const String routeName = '/attributeValuesScreen';

  @override
  ConsumerState<AttributeValuesScreen> createState() =>
      _AttributeValuesScreenState();
}

class _AttributeValuesScreenState
    extends ConsumerState<AttributeValuesScreen> {
  final TextEditingController _addController = TextEditingController();
  final Map<int, TextEditingController> _editControllers = {};

  @override
  void dispose() {
    _addController.dispose();
    _editControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<void> _addValue() async {
    final name = _addController.text.trim();
    if (name.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: 'Validation',
        message: 'Please enter a value name',
      );
      return;
    }

    try {
      await addAttributeValue(
        ref: ref,
        name: name,
        attributeId: widget.attributeId,
      );
      _addController.clear();
      ref.invalidate(attributeShowProvider(widget.attributeId));
      GlobalSnackbar.show(
        context,
        title: 'Success',
        message: 'Value added successfully',
        type: CustomSnackType.success,
      );
    } catch (e) {
      GlobalSnackbar.show(
        context,
        title: 'Error',
        message: 'Failed to add value: ${e.toString()}',
        type: CustomSnackType.error,
      );
    }
  }

  Future<void> _updateValue(int valueId, String currentName) async {
    final controller = _editControllers[valueId];
    if (controller == null) return;

    final newName = controller.text.trim();
    if (newName.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: 'Validation',
        message: 'Value name cannot be empty',
      );
      return;
    }

    if (newName == currentName) {
      // No change, just close edit mode
      setState(() {
        _editControllers[valueId]?.dispose();
        _editControllers.remove(valueId);
      });
      return;
    }

    try {
      await updateAttributeValue(
        ref: ref,
        valueId: valueId,
        name: newName,
      );
      setState(() {
        _editControllers[valueId]?.dispose();
        _editControllers.remove(valueId);
      });
      ref.invalidate(attributeShowProvider(widget.attributeId));
      GlobalSnackbar.show(
        context,
        title: 'Success',
        message: 'Value updated successfully',
        type: CustomSnackType.success,
      );
    } catch (e) {
      GlobalSnackbar.show(
        context,
        title: 'Error',
        message: 'Failed to update value: ${e.toString()}',
        type: CustomSnackType.error,
      );
    }
  }

  Future<void> _deleteValue(int valueId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Value'),
        content: const Text('Are you sure you want to delete this value?'),
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
      await deleteAttributeValue(ref: ref, valueId: valueId);
      ref.invalidate(attributeShowProvider(widget.attributeId));
      GlobalSnackbar.show(
        context,
        title: 'Success',
        message: 'Value deleted successfully',
        type: CustomSnackType.success,
      );
    } catch (e) {
      GlobalSnackbar.show(
        context,
        title: 'Error',
        message: 'Failed to delete value: ${e.toString()}',
        type: CustomSnackType.error,
      );
    }
  }

  void _startEdit(int valueId, String currentName) {
    setState(() {
      _editControllers[valueId] = TextEditingController(text: currentName);
    });
  }

  void _cancelEdit(int valueId) {
    setState(() {
      _editControllers[valueId]?.dispose();
      _editControllers.remove(valueId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final attributeAsync = ref.watch(attributeShowProvider(widget.attributeId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.attributeName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.3,
      ),
      body: attributeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: ${e.toString()}')),
        data: (attribute) => SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add new value section
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
                        controller: _addController,
                        decoration: InputDecoration(
                          hintText: 'Enter new ${widget.attributeName.toLowerCase()} value',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                        ),
                        onSubmitted: (_) => _addValue(),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      onPressed: _addValue,
                      icon: Icon(Icons.add_circle, color: AllColor.blue),
                      iconSize: 28.r,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Values list
              Text(
                '${widget.attributeName} Values:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AllColor.black,
                ),
              ),
              SizedBox(height: 12.h),

              if (attribute.attributeValues.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Center(
                    child: Text(
                      'No values added yet',
                      style: TextStyle(
                        color: AllColor.grey,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                )
              else
                ...attribute.attributeValues.map((value) {
                  final isEditing = _editControllers.containsKey(value.id);
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
                                  controller: _editControllers[value.id],
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 8.w),
                                  ),
                                  autofocus: true,
                                  onSubmitted: (_) => _updateValue(
                                      value.id, value.name),
                                )
                              : Text(
                                  value.name,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AllColor.black,
                                  ),
                                ),
                        ),
                        SizedBox(width: 8.w),
                        if (isEditing)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _updateValue(value.id, value.name),
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                iconSize: 20.r,
                              ),
                              IconButton(
                                onPressed: () => _cancelEdit(value.id),
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
                                onPressed: () => _startEdit(value.id, value.name),
                                icon: Icon(Icons.edit,
                                    color: AllColor.blue),
                                iconSize: 20.r,
                              ),
                              IconButton(
                                onPressed: () => _deleteValue(value.id),
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                iconSize: 20.r,
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

