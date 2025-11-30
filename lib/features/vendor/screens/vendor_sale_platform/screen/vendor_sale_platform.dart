import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/vendor/screens/vendor_sale_platform/data/vendor_sale_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_sale_platform/data/vendor_top_selle_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_sale_platform/data/vendor_weekly_sale_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_sale_platform/model/vendor_weekly_sele_modle.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

class VendorSalePlatformScreen extends ConsumerWidget {
  const VendorSalePlatformScreen({super.key});
  static const routeName = "/vendorSalePlatform";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(selectedIncomeDaysProvider);
    final selectedDays = ref.watch(
      selectedIncomeDaysProvider,
    ); // 👈 dropdown/ calendar eita change করবে
    final asyncIncome = ref.watch(vendorIncomeProvider(selectedDays));
    return Scaffold(
      backgroundColor: AllColor.white,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomBackButton(),
              SizedBox(height: 20.h),
              asyncIncome.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'Failed to load performance: $e',
                    style: TextStyle(color: AllColor.red, fontSize: 12),
                  ),
                ),
                data: (income) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomBackButton(),
                      SizedBox(height: 20.h),

                      Text(
                        'Store Performance',
                        style: TextStyle(
                          color: AllColor.black,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // subtitle – selectedDays diye
                      Text(
                        'Last $selectedDays days overview',
                        style: TextStyle(
                          color: AllColor.black54,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // 🔻 Dropdown style filter button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _DaysFilterDropdown(
                          selectedDays: selectedDays,
                          onDaysChanged: (days) {
                            ref
                                    .read(selectedIncomeDaysProvider.notifier)
                                    .state =
                                days;
                          },
                        ),
                      ),

                      SizedBox(height: 14.h),

                      // ---- KPI cards ----
                      _KpiGrid(
                        items: [
                          _KpiData(
                            title: 'Revenue',
                            value: '৳${income.totalRevenue.toStringAsFixed(0)}',
                            deltaText: '',
                          ),
                          _KpiData(
                            title: 'Orders',
                            value: income.totalOrders.toString(),
                            deltaText: '',
                          ),
                          _KpiData(
                            title: 'Clicks',
                            value: income.totalClicks.toString(),
                            deltaText: '',
                          ),
                          _KpiData(
                            title: 'Conversion rate',
                            value:
                                '${income.conversionRate.toStringAsFixed(2)}%',
                            deltaText: '',
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 14.h),

              SalesChart(),

              SizedBox(height: 18.h),
              // Top Selling table
              Text(
                'Top Selling Products',
                style: TextStyle(
                  color: AllColor.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 10.h),
              TopSellingSection(),
            ],
          ),
        ),
      ),
    );
  }
}

/* --------------------------- Filter Chip --------------------------- */

class _FilterChipButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const _FilterChipButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AllColor.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: AllColor.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AllColor.grey200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.sp, color: AllColor.black),
              SizedBox(width: 8.w),
              Text(
                text,
                style: TextStyle(
                  color: AllColor.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AllColor.black54,
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ----------------------------- KPI GRID ---------------------------- */

class _KpiData {
  final String title;
  final String value;
  final String deltaText;
  const _KpiData({
    required this.title,
    required this.value,
    required this.deltaText,
  });
}

class _KpiGrid extends StatelessWidget {
  final List<_KpiData> items;
  const _KpiGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (e) => SizedBox(
                  width: (c.maxWidth - 12) / 2,
                  child: _KpiCard(data: e),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AllColor.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: TextStyle(
              color: AllColor.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            data.value,
            style: TextStyle(
              color: AllColor.black,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.sp),
          Row(
            children: [
              Icon(
                Icons.arrow_upward_rounded,
                size: 16.sp,
                color: Colors.green,
              ),
              SizedBox(width: 4.w),
              Text(
                data.deltaText,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SalesChart extends ConsumerWidget {
  const SalesChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWeekly = ref.watch(vendorWeeklySellProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: asyncWeekly.when(
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => SizedBox(
          height: 200,
          child: Center(child: Text('Failed to load chart: $e')),
        ),
        data: (weekly) => _WeeklyChartContent(data: weekly),
      ),
    );
  }
}

class _WeeklyChartContent extends StatelessWidget {
  const _WeeklyChartContent({required this.data});

  final WeeklySellData data;

  @override
  Widget build(BuildContext context) {
    final days = data.days.isEmpty
        ? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : data.days;

    final currentSpots = _toSpots(data.currentPeriod);
    final previousSpots = _toSpots(data.previousPeriod);

    final maxVal = [
      ...data.currentPeriod,
      ...data.previousPeriod,
    ].fold<double>(0, (prev, v) => math.max(prev, v));

    final maxY = maxVal == 0 ? 10.0 : maxVal * 1.2;
    final maxX = (days.length - 1).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------- Title + legend -------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Sales",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            SizedBox(width: 40.w),
            _LegendItem(color: Colors.orange, text: "Current Period"),
            SizedBox(width: 10.w),
            _LegendItem(color: Colors.grey, text: "Previous Period"),
          ],
        ),
        SizedBox(height: 12.h),

        // ------- Chart -------
        SizedBox(
          height: 200.h,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, _) {
                      if (maxY <= 0) return const SizedBox.shrink();
                      // simple step
                      return Text(value.toInt().toString());
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index >= 0 && index < days.length) {
                        return Text(
                          days[index],
                          style: TextStyle(fontSize: 12.sp),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: maxX,
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                // 🔶 Current period (orange)
                LineChartBarData(
                  spots: currentSpots,
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 2,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.orange.withOpacity(0.2),
                  ),
                  dotData: FlDotData(show: false),
                ),
                // ⚪ Previous period (grey)
                LineChartBarData(
                  spots: previousSpots,
                  isCurved: true,
                  color: Colors.grey,
                  barWidth: 2,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.grey.withOpacity(0.1),
                  ),
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _toSpots(List<double> values) {
    return values
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        SizedBox(width: 4.w),
        Text(text, style: TextStyle(fontSize: 12.sp)),
      ],
    );
  }
}

// class _LegendItem extends StatelessWidget {
//   final Color color;
//   final String text;
//   const _LegendItem({required this.color, required this.text});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         CircleAvatar(radius: 4, backgroundColor: color),
//         SizedBox(width: 4.w),
//         Text(text, style: TextStyle(fontSize: 12.sp)),
//       ],
//     );
//   }
// }

/* ------------------------ Top Selling Table ------------------------ */

class _TopRow {
  final String name;
  final int quantity;
  final double revenue;

  _TopRow(this.name, this.quantity, this.revenue);
}

class _TopSellingTable extends StatelessWidget {
  final List<_TopRow> rows;
  const _TopSellingTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AllColor.grey200),
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Product',
                    style: TextStyle(
                      color: AllColor.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Qty',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AllColor.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Revenue',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AllColor.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AllColor.grey200),

          // Data rows
          ...rows.map(
            (r) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      r.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AllColor.black, fontSize: 12.sp),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      r.quantity.toString(),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AllColor.black87,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      r.revenue.toStringAsFixed(2),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AllColor.black87,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//
// class _TopSellingTable extends StatelessWidget {
//   final List<_TopRow> rows;
//   const _TopSellingTable({required this.rows});
//
//   @override
//   Widget build(BuildContext context) {
//     final headerStyle = TextStyle(
//       color: AllColor.black54,
//       fontWeight: FontWeight.w700,
//     );
//     final rowStyle = TextStyle(
//       color: AllColor.black,
//       fontWeight: FontWeight.w600,
//     );
//
//     return Container(
//       decoration: BoxDecoration(
//         color: AllColor.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: AllColor.grey200),
//       ),
//       child: Column(
//         children: [
//           // header
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 10.w),
//             decoration: BoxDecoration(
//               color: AllColor.grey100,
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(10),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(flex: 6, child: Text('Product', style: headerStyle)),
//                 Expanded(flex: 2, child: Text('units', style: headerStyle)),
//                 Expanded(
//                   flex: 3,
//                   child: Align(
//                     alignment: Alignment.centerRight,
//                     child: Text('Revenues', style: headerStyle),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // rows
//           ...rows.map(
//             (r) => Container(
//               padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 12.w),
//               decoration: BoxDecoration(
//                 border: Border(top: BorderSide(color: AllColor.grey200)),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(flex: 6, child: Text(r.product, style: rowStyle)),
//                   Expanded(flex: 2, child: Text('${r.units}', style: rowStyle)),
//                   Expanded(
//                     flex: 3,
//                     child: Align(
//                       alignment: Alignment.centerRight,
//                       child: Text(
//                         '\$${r.revenue.toStringAsFixed(2)}',
//                         style: rowStyle,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// ui_top_selling_products.dart

class TopSellingSection extends ConsumerWidget {
  const TopSellingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTop = ref.watch(vendorTopProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),

        asyncTop.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Failed to load products: $e',
              style: TextStyle(color: AllColor.red, fontSize: 12.sp),
            ),
          ),
          data: (data) {
            final products = data.products;

            if (products.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No top products found yet',
                  style: TextStyle(color: AllColor.black54, fontSize: 13.sp),
                ),
              );
            }

            final rows = products
                .map((p) => _TopRow(p.name, p.totalQuantity, p.totalRevenue))
                .toList();

            return _TopSellingTable(rows: rows);
          },
        ),
      ],
    );
  }
}

class _DaysFilterDropdown extends StatelessWidget {
  final int selectedDays;
  final ValueChanged<int> onDaysChanged;

  const _DaysFilterDropdown({
    Key? key,
    required this.selectedDays,
    required this.onDaysChanged,
  }) : super(key: key);

  String _labelForDays(int days) {
    if (days == 7) return 'Last 7 days';
    if (days == 30) return 'Last 30 days';
    if (days == 90) return 'Last 90 days';
    return 'Last $days days';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: () async {
        // 1) bottom sheet theke 7/30/90 ba "custom" select হবে
        final result = await showModalBottomSheet<int>(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          builder: (ctx) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8.h),
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  ListTile(
                    title: const Text('Last 7 days'),
                    onTap: () => Navigator.pop(ctx, 7),
                  ),
                  ListTile(
                    title: const Text('Last 30 days'),
                    onTap: () => Navigator.pop(ctx, 30),
                  ),
                  ListTile(
                    title: const Text('Last 90 days'),
                    onTap: () => Navigator.pop(ctx, 90),
                  ),
                  const Divider(),

                  // 👇 Custom date → calendar
                  ListTile(
                    leading: const Icon(Icons.date_range),
                    title: const Text('Custom date (choose from calendar)'),
                    onTap: () => Navigator.pop(ctx, -1),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            );
          },
        );

        if (result == null) return;

        int days = result;

        // 2) Custom select করলে calendar খুলবে
        if (result == -1) {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now(),
          );
          if (picked == null) return;

          // today - picked = kotodin er range
          final onlyDatePicked = DateTime(
            picked.year,
            picked.month,
            picked.day,
          );
          final onlyToday = DateTime.now();
          days = onlyToday.difference(onlyDatePicked).inDays + 1;

          if (days <= 0) {
            // jodi future date choose kore, ignore kore felbo
            return;
          }
        }

        onDaysChanged(days); // 🔥 provider update → API abar call hobe
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14.sp,
              color: Colors.black54,
            ),
            SizedBox(width: 8.w),
            Text(
              _labelForDays(selectedDays),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18.sp,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
