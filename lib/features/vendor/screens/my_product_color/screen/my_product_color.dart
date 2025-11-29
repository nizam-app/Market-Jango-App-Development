import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:market_jango/core/constants/color_control/all_color.dart';

// API model
import '../../product_edit/model/product_attribute_response_model.dart';
import '../data/verndor_add_color_data_logic.dart';

/// ===================== SCREEN =====================

class MyProductColorScreen extends ConsumerWidget {
  const MyProductColorScreen({
    super.key,
    required this.attributeId,
  });

  static const routeName = "/myProductColorScreen";

  /// Color attribute id (e.g. 21)
  final int attributeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(attributeShowProvider(attributeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Color attribute"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.3,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (attribute) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: ColorAttributeTable(attribute: attribute),
          ),
        ),
      ),
    );
  }
}

/// ===================== LOCAL VIEW MODEL =====================
/// API model untouched থাকবে, UI er jonno alada mutable list
class _LocalColorValue {
  int id;      // attribute value id (101, 102 ...)
  String hex;  // "3B82F6"

  _LocalColorValue({
    required this.id,
    required this.hex,
  });

  factory _LocalColorValue.fromAttributeValue(AttributeValue v) {
    return _LocalColorValue(
      id: v.id,
      hex: v.name.toUpperCase(),
    );
  }
}

/// ===================== TABLE WIDGET (DESIGN SAME) =====================

class ColorAttributeTable extends ConsumerStatefulWidget {
  const ColorAttributeTable({
    super.key,
    required this.attribute,
  });

  final VendorProductAttribute attribute; // e.g. Color attribute

  @override
  ConsumerState<ColorAttributeTable> createState() =>
      _ColorAttributeTableState();
}

class _ColorAttributeTableState extends ConsumerState<ColorAttributeTable> {
  late List<_LocalColorValue> _items;

  // Presets (design-এর মতই)
  late final List<MapEntry<String, Color>> _presets = const [
    MapEntry('White', Color(0xFFFFFFFF)),
    MapEntry('Black', Color(0xFF000000)),
    MapEntry('Red', Color(0xFFFF3B30)),
    MapEntry('Green', Color(0xFF34C759)),
    MapEntry('Blue', Color(0xFF007AFF)),
    MapEntry('Yellow', Color(0xFFFFCC00)),
    MapEntry('Orange', Color(0xFFFF9500)),
    MapEntry('Brown', Color(0xFF8E5A3C)),
    MapEntry('Gray', Color(0xFF8E8E93)),
    MapEntry('Purple', Color(0xFFAF52DE)),
  ];

  @override
  void initState() {
    super.initState();
    // API theke asha attribute_values -> local list
    _items = widget.attribute.attributeValues
        .map(_LocalColorValue.fromAttributeValue)
        .toList();
  }

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('0xFF$clean'));
      } else if (clean.length == 8) {
        return Color(int.parse('0x$clean'));
      }
    } catch (_) {}
    return Colors.grey;
  }

  String _hex(Color c) =>
      c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = AllColor.grey.withOpacity(0.25);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + label same design
        Text(
          widget.attribute.name, // e.g. "Color"
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AllColor.black,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          widget.attribute.name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AllColor.black.withOpacity(0.7),
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 10.h),

        // Action row (unchanged)
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _addColor, // <- API সহ নতুন function
              icon: Icon(Icons.add, size: 16.sp, color: AllColor.black),
              label: Text(
                'Add color',
                style: TextStyle(color: AllColor.black, fontSize: 13.sp),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r)),
                padding: EdgeInsets.symmetric(
                    horizontal: 12.w, vertical: 8.h),
              ),
            ),
            SizedBox(width: 10.w),
            TextButton(
              onPressed: _showAddFromPresets, // <- presets theke API create
              child: Text(
                'Add from presets',
                style:
                TextStyle(fontSize: 13.sp, color: AllColor.black),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // Table (same design)
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(6.r),
            color: AllColor.white,
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2), // Name
              1: FlexColumnWidth(1), // Value
              2: FlexColumnWidth(0.4), // Actions
            },
            border: TableBorder.symmetric(
              inside: BorderSide(color: borderColor, width: 1),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              _headerRow(),
              for (int i = 0; i < _items.length; i++) _dataRow(i),
            ],
          ),
        ),
      ],
    );
  }

  /// ---------- Header row (unchanged design) ----------
  TableRow _headerRow() => TableRow(
    decoration:
    BoxDecoration(color: AllColor.grey.withOpacity(0.08)),
    children: [
      _Cell(
        pad: 12.w,
        child: Text(
          'Name',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AllColor.black,
              fontSize: 14.sp),
        ),
      ),
      _Cell(
        pad: 12.w,
        child: Text(
          'Value',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AllColor.black,
              fontSize: 14.sp),
        ),
      ),
      const _Cell(pad: 12, child: SizedBox.shrink()),
    ],
  );

  /// ---------- Data row (unchanged layout, শুধু logic বদলানো) ----------
  TableRow _dataRow(int i) {
    final item = _items[i];
    final color = _parseHex(item.hex);

    return TableRow(
      children: [
        // Editable name (actually HEX) – শুধু local state update
        _Cell(
          pad: 12.w,
          child: TextFormField(
            key: ValueKey('name_${i}_${item.id}'),
            initialValue: item.hex,
            style:
            TextStyle(color: AllColor.black, fontSize: 14.sp),
            decoration: const InputDecoration(
              isDense: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) {
              setState(() => _items[i].hex = v.trim());
            },
          ),
        ),

        // Color value (tap to pick & UPDATE API)
        _Cell(
          pad: 8.w,
          child: InkWell(
            onTap: () => _openPicker(i),
            borderRadius: BorderRadius.circular(6.r),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AllColor.white,
                border: Border.all(
                    color: AllColor.grey.withOpacity(0.28), width: 1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                          color: AllColor.grey.withOpacity(0.6),
                          width: 1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _items[i].hex,
                    style: TextStyle(
                        letterSpacing: 0.5,
                        color: AllColor.black,
                        fontSize: 14.sp),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Delete action (DELETE API)
        _Cell(
          pad: 6.w,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Remove',
              onPressed: () => _deleteRow(i),
              icon: Icon(Icons.delete_outline,
                  size: 20.sp,
                  color: AllColor.grey.withOpacity(0.9)),
              splashRadius: 20.r,
            ),
          ),
        ),
      ],
    );
  }

  /// ================== ACTIONS ==================

  /// --- Add color (picker + CREATE API) ---
  Future<void> _addColor() async {
    Color picked = Colors.white;

    final Color? result = await showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AllColor.white,
        title: const Text("Pick new color"),
        content: StatefulBuilder(
          builder: (_, setSB) => ColorPicker(
            pickerColor: picked,
            onColorChanged: (c) => setSB(() => picked = c),
            enableAlpha: false,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, picked),
            child: const Text("Add"),
          ),
        ],
      ),
    );

    if (result == null) return;

    final hex = _hex(result);

    try {
      final created = await addAttributeValue(
        ref: ref,
        name: hex,
        attributeId: widget.attribute.id,
      );

      setState(() {
        _items.add(
          _LocalColorValue.fromAttributeValue(created),
        );
      });

      _showSnack("Color added");
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  /// --- Delete row (DELETE API) ---
  Future<void> _deleteRow(int index) async {
    final item = _items[index];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete color?"),
        content: const Text("Are you sure you want to delete this color?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final ok =
      await deleteAttributeValue(ref: ref, valueId: item.id);
      if (ok) {
        setState(() => _items.removeAt(index));
        _showSnack("Color deleted");
      }
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  /// --- Update color (picker + UPDATE API) ---
  Future<void> _openPicker(int index) async {
    final currentHex = _items[index].hex;
    Color current = _parseHex(currentHex);

    final Color? result = await showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AllColor.white,
        title: const Text("Update color"),
        content: StatefulBuilder(
          builder: (_, setSB) => ColorPicker(
            pickerColor: current,
            onColorChanged: (c) => setSB(() => current = c),
            enableAlpha: false,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, current),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result == null) return;

    final newHex = _hex(result);

    try {
      final updated = await updateAttributeValue(
        ref: ref,
        valueId: _items[index].id,
        name: newHex,
      );

      setState(() {
        _items[index].hex = updated.name.toUpperCase();
      });

      _showSnack("Color updated");
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  /// --- Add from presets (multi create API) ---
  Future<void> _showAddFromPresets() async {
    final selected = <int>{};

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AllColor.white,
        title: Text(
          'Select presets',
          style: TextStyle(
              color: AllColor.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700),
        ),
        content: StatefulBuilder(
          builder: (_, setSB) => SingleChildScrollView(
            child: Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: List.generate(_presets.length, (i) {
                final entry = _presets[i];
                final isSel = selected.contains(i);
                return FilterChip(
                  selected: isSel,
                  onSelected: (v) => setSB(() {
                    v ? selected.add(i) : selected.remove(i);
                  }),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14.w,
                        height: 14.w,
                        decoration: BoxDecoration(
                          color: entry.value,
                          borderRadius: BorderRadius.circular(3.r),
                          border: Border.all(
                              color: AllColor.grey.withOpacity(0.5)),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(entry.key,
                          style: TextStyle(
                              color: AllColor.black, fontSize: 12.sp)),
                    ],
                  ),
                  selectedColor:
                  AllColor.grey.withOpacity(0.15),
                  backgroundColor: AllColor.white,
                  shape: StadiumBorder(
                    side: BorderSide(
                        color: AllColor.grey.withOpacity(0.3)),
                  ),
                );
              }),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(
                    color: AllColor.black, fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AllColor.black,
              foregroundColor: AllColor.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r)),
            ),
            child: Text('Add', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );

    if (ok != true || selected.isEmpty) return;

    try {
      final List<_LocalColorValue> newlyCreated = [];

      for (final i in selected) {
        final entry = _presets[i];
        final hex = _hex(entry.value);

        final exists = _items.any(
                (r) => r.hex.toLowerCase() == hex.toLowerCase());
        if (exists) continue;

        final created = await addAttributeValue(
          ref: ref,
          name: hex,
          attributeId: widget.attribute.id,
        );

        newlyCreated.add(
            _LocalColorValue.fromAttributeValue(created));
      }

      if (newlyCreated.isNotEmpty) {
        setState(() => _items.addAll(newlyCreated));
        _showSnack("Preset colors added");
      }
    } catch (e) {
      _showSnack(e.toString());
    }
  }
}

/// Simple cell wrapper (unchanged)
class _Cell extends StatelessWidget {
  const _Cell({required this.child, this.pad = 12});
  final Widget child;
  final double pad;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: EdgeInsets.all(pad), child: child);
}