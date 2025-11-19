import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/vendor/screens/my_product_color/data/verndor_add_color_data_logic.dart';
import '../../product_edit/model/product_attribute_response_model.dart';
class SizeRow {
  final int id;      // attribute_values.id  (API theke ashe)
  String name;       // left column label
  String value;      // real size value (S, M, L, XL... – API te ei ta jai)

  SizeRow({
    required this.id,
    required this.name,
    required this.value,
  });

  factory SizeRow.fromAttributeValue(AttributeValue v) {
    return SizeRow(
      id: v.id,
      name: v.name,
      value: v.name,
    );
  }
}

/// ------------------------------------------------------------------
/// MAIN SCREEN
/// ------------------------------------------------------------------
class MyProductSizeScreen extends ConsumerStatefulWidget {
  const MyProductSizeScreen({
    super.key,
    required this.attributeId,
  });

  static const routeName = '/myProductSizeScreen';

  /// Color er moto:  Size er attribute id (eg: 22)
  final int attributeId;

  @override
  ConsumerState<MyProductSizeScreen> createState() =>
      _MyProductSizeScreenState();
}

class _MyProductSizeScreenState
    extends ConsumerState<MyProductSizeScreen> {
  final _presetSizes = const <String>[
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    '3XL',
    '4XL',
  ];

  @override
  Widget build(BuildContext context) {
    // same provider use hocche jeita Color screen e use korcho
    final async = ref.watch(attributeShowProvider(widget.attributeId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Size attribute',
            style: TextStyle(color: AllColor.black)),
        backgroundColor: AllColor.white,
        foregroundColor: AllColor.black,
        elevation: 0.3,
      ),
      body: async.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (VendorProductAttribute attribute) {
          // API -> local SizeRow list
          final rows = attribute.attributeValues
              .map(SizeRow.fromAttributeValue)
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: SizeAttributeTable(
                attributeId: attribute.id,
                items: rows,
                presetSizes: _presetSizes,
                onChanged: (list) {
                  // optional: parent e dorkar hole use korte paro
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ------------------------------------------------------------------
/// TABLE + ACTIONS (same design as tomar code)
/// ------------------------------------------------------------------
class SizeAttributeTable extends ConsumerStatefulWidget {
  const SizeAttributeTable({
    super.key,
    required this.attributeId,
    required this.items,
    this.presetSizes = const ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
    this.onChanged,
    this.title = '',
    this.label = 'Size',
  });

  final int attributeId;                    // product_attribute_id (eg: 22)
  final List<SizeRow> items;
  final List<String> presetSizes;
  final ValueChanged<List<SizeRow>>? onChanged;
  final String title;
  final String label;

  @override
  ConsumerState<SizeAttributeTable> createState() =>
      _SizeAttributeTableState();
}

class _SizeAttributeTableState
    extends ConsumerState<SizeAttributeTable> {
  late List<SizeRow> _items = List<SizeRow>.from(widget.items);

  void _notify() => widget.onChanged?.call(_items);

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
        if (widget.title.isNotEmpty)
          Text(
            widget.title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
              fontWeight: FontWeight.w600,
              color: AllColor.black,
              fontSize: 16.sp,
            ),
          ),
        if (widget.title.isNotEmpty) SizedBox(height: 8.h),
        Text(
          widget.label,
          style:
          Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AllColor.black.withOpacity(0.7),
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 10.h),

        // Actions row (Add size + Add from presets)
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _addRow,
              icon: Icon(Icons.add,
                  size: 16.sp, color: AllColor.black),
              label: Text('Add size',
                  style: TextStyle(
                      color: AllColor.black, fontSize: 13.sp)),
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
              onPressed: _showAddFromPresets,
              child: Text('Add from presets',
                  style: TextStyle(
                      fontSize: 13.sp, color: AllColor.black)),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // Table (same layout)
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(6.r),
            color: AllColor.white,
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2), // Name
              1: FlexColumnWidth(1),   // Value
              2: FlexColumnWidth(0.4), // Actions
            },
            border: TableBorder.symmetric(
              inside:
              BorderSide(color: borderColor, width: 1),
            ),
            defaultVerticalAlignment:
            TableCellVerticalAlignment.middle,
            children: [
              _headerRow(),
              for (int i = 0; i < _items.length; i++)
                _dataRow(i),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _headerRow() => TableRow(
    decoration: BoxDecoration(
      color: AllColor.grey.withOpacity(0.08),
    ),
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

  TableRow _dataRow(int i) {
    final item = _items[i];

    return TableRow(
      children: [
        // ----- editable NAME (local only) -----
        _Cell(
          pad: 12.w,
          child: TextFormField(
            key: ValueKey('name_${i}_${item.name.hashCode}'),
            initialValue: item.name,
            style: TextStyle(
                color: AllColor.black, fontSize: 14.sp),
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
              setState(() => _items[i].name = v);
              _notify();
            },
          ),
        ),

        // ----- VALUE (size) : tap -> picker + UPDATE API -----
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
                    color: AllColor.grey.withOpacity(0.28),
                    width: 1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  // small square – just like color box place
                  Container(
                    width: 18.w,
                    height: 18.w,
                    decoration: BoxDecoration(
                      color: AllColor.grey.withOpacity(0.15),
                      border: Border.all(
                          color:
                          AllColor.grey.withOpacity(0.6),
                          width: 1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.value.length > 2
                          ? item.value.substring(0, 2)
                          : item.value,
                      style: TextStyle(
                          fontSize: 9.sp,
                          color: AllColor.black),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    item.value,
                    style: TextStyle(
                      letterSpacing: 0.5,
                      color: AllColor.black,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ----- DELETE (DELETE API) -----
        _Cell(
          pad: 6.w,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Remove',
              splashRadius: 20.r,
              onPressed: () => _removeRow(i),
              icon: Icon(
                Icons.delete_outline,
                size: 20.sp,
                color: AllColor.grey.withOpacity(0.9),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- ADD (create API) ----------------
  Future<void> _addRow() async {
    String input = '';

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add size'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Size (e.g. S, M, XL)',
          ),
          onChanged: (v) =>
          input = v.trim().toUpperCase(),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(ctx,
                    input.isEmpty ? null : input),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    try {
      final created = await addAttributeValue(
        ref: ref,
        name: result,
        attributeId: widget.attributeId,
      );

      setState(() {
        _items.add(
          SizeRow.fromAttributeValue(created),
        );
      });
      _notify();
      _showSnack('Size added');
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  // ---------------- DELETE (destroy API) ----------------
  Future<void> _removeRow(int index) async {
    final row = _items[index];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete size?'),
        content: const Text(
            'Are you sure you want to delete this size?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final ok = await deleteAttributeValue(
        ref: ref,
        valueId: row.id,
      );
      if (ok) {
        setState(() => _items.removeAt(index));
        _notify();
        _showSnack('Size deleted');
      }
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  // ---------------- UPDATE (update API) ----------------
  Future<void> _openPicker(int index) async {
    String current = _items[index].value;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AllColor.white,
        contentPadding: EdgeInsets.all(12.w),
        title: Text(
          'Select size',
          style: TextStyle(
            color: AllColor.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: StatefulBuilder(
          builder: (_, setSB) => Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.presetSizes.map((s) {
              final selected = s == current;
              return ChoiceChip(
                label: Text(
                  s,
                  style: TextStyle(color: AllColor.black),
                ),
                selected: selected,
                selectedColor:
                AllColor.grey.withOpacity(0.15),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: selected
                        ? AllColor.black
                        : AllColor.grey.withOpacity(0.35),
                  ),
                ),
                onSelected: (_) {
                  setSB(() => current = s);
                  _updateSizeValue(index, s);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: TextStyle(
                  color: AllColor.black,
                  fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSizeValue(
      int index, String newVal) async {
    final row = _items[index];

    try {
      final updated = await updateAttributeValue(
        ref: ref,
        valueId: row.id,
        name: newVal,
      );

      setState(() {
        _items[index].value = updated.name;
        _items[index].name = updated.name;
      });
      _notify();
      _showSnack('Size updated');
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  // ---------------- ADD from presets (create API for each) ----------------
  Future<void> _showAddFromPresets() async {
    final selected = <int>{};

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AllColor.white,
        title: Text(
          'Select sizes',
          style: TextStyle(
              color: AllColor.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700),
        ),
        content: StatefulBuilder(
          builder: (_, setSB) => Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(
                widget.presetSizes.length, (i) {
              final s = widget.presetSizes[i];
              final isSel = selected.contains(i);
              return FilterChip(
                selected: isSel,
                onSelected: (v) => setSB(() =>
                v ? selected.add(i)
                    : selected.remove(i)),
                label: Text(
                  s,
                  style: TextStyle(color: AllColor.black),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: AllColor.black,
                  fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final toCreate = selected
                  .map((i) => widget.presetSizes[i])
                  .toList();

              for (final s in toCreate) {
                final exists = _items.any(
                        (r) =>
                    r.value.toUpperCase() ==
                        s.toUpperCase());
                if (exists) continue;

                try {
                  final created =
                  await addAttributeValue(
                    ref: ref,
                    name: s,
                    attributeId: widget.attributeId,
                  );
                  _items.add(
                    SizeRow.fromAttributeValue(
                        created),
                  );
                } catch (e) {
                  _showSnack(e.toString());
                }
              }

              setState(() {});
              _notify();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AllColor.black,
              foregroundColor: AllColor.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(6.r),
              ),
            ),
            child: Text('Add',
                style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.child, this.pad = 12});
  final Widget child;
  final double pad;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: EdgeInsets.all(pad), child: child);
}