import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';

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
    final selectedDays = ref.watch(selectedIncomeDaysProvider);
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
              const CustomBackButton(),
              SizedBox(height: 20.h),

              /// Title
              Text(
                ref.t(BKeys.storePerformance),
                style: TextStyle(
                  color: AllColor.black,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                ref.t(BKeys.last30DaysOverview),
                style: TextStyle(
                  color: AllColor.black54,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),

              /// Days filter dropdown
              Align(
                alignment: Alignment.centerLeft,
                child: _DaysFilterDropdown(
                  selectedDays: selectedDays,
                  onDaysChanged: (days) {
                    ref.read(selectedIncomeDaysProvider.notifier).state = days;
                  },
                ),
              ),
              SizedBox(height: 14.h),

              /// KPI cards from API
              asyncIncome.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Loading...'),
                  ),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Failed to load performance: $e',
                      style: TextStyle(color: AllColor.red, fontSize: 12.sp),
                    ),
                  ),
                ),
                data: (income) {
                  return _KpiGrid(
                    items: [
                      _KpiData(
                        title: ref.t(BKeys.revenue),
                        value: '৳${income.totalRevenue.toStringAsFixed(0)}',
                        deltaText: '', // future e change korte parba
                      ),
                      _KpiData(
                        title: ref.t(BKeys.order),
                        value: income.totalOrders.toString(),
                        deltaText: '',
                      ),
                      _KpiData(
                        title: ref.t(BKeys.clicks),
                        value: income.totalClicks.toString(),
                        deltaText: '',
                      ),
                      _KpiData(
                        title: ref.t(BKeys.conversionRate),
                        value:
                        '${income.conversionRate.toStringAsFixed(2)}%',
                        deltaText: '',
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 18.h),

              /// Sales chart
              const SalesChart(),

              SizedBox(height: 18.h),

              /// Top selling title
              Text(
                ref.t(BKeys.topSellingProducts),
                style: TextStyle(
                  color: AllColor.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),

              /// Top selling section (table + API)
              const TopSellingSection(),
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
    final hasDelta = data.deltaText.trim().isNotEmpty;

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
          if (hasDelta)
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

/* ------------------------------ Sales ------------------------------ */

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
        loading: () => SizedBox(
          height: 200.h,
          child: const Center(child: Text('Loading...')),
        ),
        error: (e, _) => SizedBox(
          height: 200.h,
          child: Center(
            child: Text(
              'Failed to load chart: $e',
              style: TextStyle(color: AllColor.red, fontSize: 12.sp),
            ),
          ),
        ),
        data: (weekly) {
          // fallback days — localization use korlam
          final fallbackDays = [
            ref.t(BKeys.mon),
            ref.t(BKeys.tue),
            ref.t(BKeys.wed),
            ref.t(BKeys.thu),
            ref.t(BKeys.fri),
            ref.t(BKeys.sat),
            ref.t(BKeys.sun),
          ];

          return _WeeklyChartContent(
            data: weekly,
            fallbackDays: fallbackDays,
            title: ref.t(BKeys.sales),
          );
        },
      ),
    );
  }
}

class _WeeklyChartContent extends StatelessWidget {
  const _WeeklyChartContent({
    required this.data,
    required this.fallbackDays,
    required this.title,
  });

  final WeeklySellData data;
  final List<String> fallbackDays;
  final String title;

  @override
  Widget build(BuildContext context) {
    final days =
    data.days.isEmpty ? fallbackDays : data.days; // backend na dile fallback

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
        /// Title + legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title, // localized "Sales"
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            Row(
              children: [
                const _LegendItem(color: Colors.orange, text: "Current Period"),
                SizedBox(width: 10.w),
                const _LegendItem(color: Colors.grey, text: "Previous Period"),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),

        /// Chart
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
                      return Text(value.toInt().toString());
                    },
                  ),
                ),
                rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                /// Current period (orange)
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

                /// Previous period (grey)
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

/* ------------------------ Top Selling Table ------------------------ */

class _TopRow {
  final String name;
  final int quantity;
  final double revenue;

  _TopRow(this.name, this.quantity, this.revenue);
}

class _TopSellingTable extends ConsumerWidget {
  final List<_TopRow> rows;
  const _TopSellingTable({required this.rows});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headerStyle = TextStyle(
      color: AllColor.black54,
      fontWeight: FontWeight.w700,
      fontSize: 12.sp,
    );

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
                    ref.t(BKeys.product),
                    style: headerStyle,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Qty',
                    textAlign: TextAlign.right,
                    style: headerStyle,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    ref.t(BKeys.revenues),
                    textAlign: TextAlign.right,
                    style: headerStyle,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AllColor.grey200),

          // Rows
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
                      style: TextStyle(
                        color: AllColor.black,
                        fontSize: 12.sp,
                      ),
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
            child: Center(child: Text('Loading...')),
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
                .map(
                  (p) => _TopRow(
                p.name,
                p.totalQuantity,
                p.totalRevenue,
              ),
            )
                .toList();

            return _TopSellingTable(rows: rows);
          },
        ),
      ],
    );
  }
}

/* ------------------------ Days Filter Dropdown ------------------------ */

class _DaysFilterDropdown extends StatelessWidget {
  final int selectedDays;
  final ValueChanged<int> onDaysChanged;

  const _DaysFilterDropdown({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
  });

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
        // Bottom sheet: 7 / 30 / 90 / custom
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

        // custom date
        if (result == -1) {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now(),
          );
          if (picked == null) return;

          final onlyDatePicked = DateTime(
            picked.year,
            picked.month,
            picked.day,
          );
          final onlyToday = DateTime.now();
          days = onlyToday.difference(onlyDatePicked).inDays + 1;

          if (days <= 0) {
            // future date ignore
            return;
          }
        }

        onDaysChanged(days);
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


// import 'dart:math' as math;
//
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:market_jango/core/constants/color_control/all_color.dart';
// <<<<<<< HEAD
// import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
// import 'package:market_jango/core/localization/tr.dart';
// =======
// import 'package:market_jango/features/vendor/screens/vendor_sale_platform/data/vendor_sale_data.dart';
// import 'package:market_jango/features/vendor/screens/vendor_sale_platform/data/vendor_top_selle_data.dart';
// import 'package:market_jango/features/vendor/screens/vendor_sale_platform/data/vendor_weekly_sale_data.dart';
// import 'package:market_jango/features/vendor/screens/vendor_sale_platform/model/vendor_weekly_sele_modle.dart';
// >>>>>>> c7b9ac4f4e9464cbd43272dedff7d98d819593c4
// import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';
//
// class VendorSalePlatformScreen extends ConsumerWidget {
//   const VendorSalePlatformScreen({super.key});
//   static const routeName = "/vendorSalePlatform";
//
//   @override
// <<<<<<< HEAD
//   Widget build(BuildContext context, ref) {
// =======
//   Widget build(BuildContext context, WidgetRef ref) {
//     final days = ref.watch(selectedIncomeDaysProvider);
//     final selectedDays = ref.watch(
//       selectedIncomeDaysProvider,
//     ); // 👈 dropdown/ calendar eita change করবে
//     final asyncIncome = ref.watch(vendorIncomeProvider(selectedDays));
// >>>>>>> c7b9ac4f4e9464cbd43272dedff7d98d819593c4
//     return Scaffold(
//       backgroundColor: AllColor.white,
//
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CustomBackButton(),
//               SizedBox(height: 20.h),
// <<<<<<< HEAD
//               Text(
//                // 'Store Performance',
//                ref.t(BKeys.storePerformance),
//                 style: TextStyle(
//                   color: AllColor.black,
//                   fontSize: 24.sp,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               SizedBox(height: 4.h),
//               Text(
//                // 'Last 30 days overview',
//                 ref.t(BKeys.last30DaysOverview),
//                 style: TextStyle(
//                   color: AllColor.black54,
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               SizedBox(height: 12.h),
// =======
//               asyncIncome.when(
//                 loading: () => const Center(child: CircularProgressIndicator()),
//                 error: (e, _) => Center(
//                   child: Text(
//                     'Failed to load performance: $e',
//                     style: TextStyle(color: AllColor.red, fontSize: 12),
//                   ),
//                 ),
//                 data: (income) {
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       CustomBackButton(),
//                       SizedBox(height: 20.h),
// >>>>>>> c7b9ac4f4e9464cbd43272dedff7d98d819593c4
//
//                       Text(
//                         'Store Performance',
//                         style: TextStyle(
//                           color: AllColor.black,
//                           fontSize: 24.sp,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                       SizedBox(height: 4.h),
//
//                       // subtitle – selectedDays diye
//                       Text(
//                         'Last $selectedDays days overview',
//                         style: TextStyle(
//                           color: AllColor.black54,
//                           fontSize: 13.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       SizedBox(height: 12.h),
//
//                       // 🔻 Dropdown style filter button
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: _DaysFilterDropdown(
//                           selectedDays: selectedDays,
//                           onDaysChanged: (days) {
//                             ref
//                                     .read(selectedIncomeDaysProvider.notifier)
//                                     .state =
//                                 days;
//                           },
//                         ),
//                       ),
//
//                       SizedBox(height: 14.h),
//
//                       // ---- KPI cards ----
//                       _KpiGrid(
//                         items: [
//                           _KpiData(
//                             title: 'Revenue',
//                             value: '৳${income.totalRevenue.toStringAsFixed(0)}',
//                             deltaText: '',
//                           ),
// <<<<<<< HEAD
//                           child: child!,
//                         );
//                       },
//                     );
//
//                     if (picked != null) {
//                       debugPrint("Selected date: $picked");
//                       // এখানে filter apply করতে পারবেন
//                     }
//                   },
//                 ),
//               ),
//
//               SizedBox(height: 14.h),
//
//               // KPI cards 2 x 2
//               _KpiGrid(
//                 items:  [
//                   _KpiData(
//                     title:
//                     //'Revenue',
//                     ref.t(BKeys.revenue),
//                     value: '\$3,490',
//                     deltaText: '38% vs previous',
//                   ),
//                   _KpiData(
//                     title:
//                     //'Orders',
//                     ref.t(BKeys.order),
//                     value: '280',
//                     deltaText: '24% vs previous',
//                   ),
//                   _KpiData(
//                     title:
//                    // 'Clicks',
//                     ref.t(BKeys.clicks),
//                     value: '4,280',
//                     deltaText: '9% vs previous',
//                   ),
//                   _KpiData(
//                     title:
//                     //'conversion rate',
//                     ref.t(BKeys.conversionRate),
//                     value: '1.2%',
//                     deltaText: '13% vs previous',
//                   ),
//                 ],
// =======
//                           _KpiData(
//                             title: 'Orders',
//                             value: income.totalOrders.toString(),
//                             deltaText: '',
//                           ),
//                           _KpiData(
//                             title: 'Clicks',
//                             value: income.totalClicks.toString(),
//                             deltaText: '',
//                           ),
//                           _KpiData(
//                             title: 'Conversion rate',
//                             value:
//                                 '${income.conversionRate.toStringAsFixed(2)}%',
//                             deltaText: '',
//                           ),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
// >>>>>>> c7b9ac4f4e9464cbd43272dedff7d98d819593c4
//               ),
//
//               SizedBox(height: 14.h),
//
//               SalesChart(),
//
//               SizedBox(height: 18.h),
//               // Top Selling table
//               Text(
//                 //'Top Selling Products',
//                 ref.t(BKeys.topSellingProducts),
//                 style: TextStyle(
//                   color: AllColor.black,
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               SizedBox(height: 10.h),
// <<<<<<< HEAD
//               _TopSellingTable(
//                 rows: const [
//                   _TopRow(
//                       'T-shirt'
//                       , 780, 1200),
//                   _TopRow(
//                       'Sneakers'
//                       , 280, 1400),
//                   _TopRow(
//                       'Backpack'
//                       , 250, 1400),
//                 ],
//               ),
// =======
//               TopSellingSection(),
// >>>>>>> c7b9ac4f4e9464cbd43272dedff7d98d819593c4
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /* --------------------------- Filter Chip --------------------------- */
//
// class _FilterChipButton extends StatelessWidget {
//   final String text;
//   final IconData icon;
//   final VoidCallback onTap;
//   const _FilterChipButton({
//     required this.text,
//     required this.icon,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: AllColor.white,
//       borderRadius: BorderRadius.circular(10),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(10),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
//           decoration: BoxDecoration(
//             color: AllColor.white,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: AllColor.grey200),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, size: 16.sp, color: AllColor.black),
//               SizedBox(width: 8.w),
//               Text(
//                 text,
//                 style: TextStyle(
//                   color: AllColor.black,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               SizedBox(width: 6.w),
//               Icon(
//                 Icons.keyboard_arrow_down_rounded,
//                 color: AllColor.black54,
//                 size: 18.sp,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /* ----------------------------- KPI GRID ---------------------------- */
//
// class _KpiData {
//   final String title;
//   final String value;
//   final String deltaText;
//   const _KpiData({
//     required this.title,
//     required this.value,
//     required this.deltaText,
//   });
// }
//
// class _KpiGrid extends StatelessWidget {
//   final List<_KpiData> items;
//   const _KpiGrid({required this.items});
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, c) {
//         return Wrap(
//           spacing: 12,
//           runSpacing: 12,
//           children: items
//               .map(
//                 (e) => SizedBox(
//                   width: (c.maxWidth - 12) / 2,
//                   child: _KpiCard(data: e),
//                 ),
//               )
//               .toList(),
//         );
//       },
//     );
//   }
// }
//
// class _KpiCard extends StatelessWidget {
//   final _KpiData data;
//   const _KpiCard({required this.data});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
//       decoration: BoxDecoration(
//         color: AllColor.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: AllColor.grey200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             data.title,
//             style: TextStyle(
//               color: AllColor.black54,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           SizedBox(height: 6.h),
//           Text(
//             data.value,
//             style: TextStyle(
//               color: AllColor.black,
//               fontSize: 22.sp,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           SizedBox(height: 6.sp),
//           Row(
//             children: [
//               Icon(
//                 Icons.arrow_upward_rounded,
//                 size: 16.sp,
//                 color: Colors.green,
//               ),
//               SizedBox(width: 4.w),
//               Text(
//                 data.deltaText,
//                 style: TextStyle(
//                   color: Colors.green,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 12.sp,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// <<<<<<< HEAD
// /* ------------------------------ Sales ------------------------------ */
//
// =======
// >>>>>>> c7b9ac4f4e9464cbd43272dedff7d98d819593c4
// class SalesChart extends ConsumerWidget {
//   const SalesChart({super.key});
//
//   @override
// <<<<<<< HEAD
//   Widget build(BuildContext context,ref ) {
// =======
//   Widget build(BuildContext context, WidgetRef ref) {
//     final asyncWeekly = ref.watch(vendorWeeklySellProvider);
//
// >>>>>>> c7b9ac4f4e9464cbd43272dedff7d98d819593c4
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(6),
//       ),
// <<<<<<< HEAD
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Title
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//              ref.t(BKeys.sales),
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
//               ),
//               SizedBox(width: 40.w),
//               _LegendItem(color: Colors.orange, text: "Previous Period"),
//               SizedBox(width: 10.w),
//               _LegendItem(color: Colors.grey, text: "Previous Period"),
//             ],
//           ),
//           SizedBox(height: 12.h),
//
//           // Chart
//           SizedBox(
//             height: 200.h,
//             child: LineChart(
//               LineChartData(
//                 gridData: FlGridData(show: true, drawVerticalLine: false),
//                 titlesData: FlTitlesData(
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 40,
//                       getTitlesWidget: (value, _) {
//                         if (value % 100 != 0) return Container();
//                         return Text("\$${value.toInt()}");
//                       },
//                     ),
//                   ),
//                   rightTitles: AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                   topTitles: AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       interval: 1, // 🔹 Add this line
//                       getTitlesWidget: (value, _) {
//                        final  days = [
//                           // "Mon",
//                           // "Tue",
//                           // "Wed",
//                           // "Thu",
//                           // "Fri",
//                           // "Sat",
//                           // "Sun",
//                            ref.t(BKeys.mon),
//                            ref.t(BKeys.tue),
//                            ref.t(BKeys.wed),
//                            ref.t(BKeys.thu),
//                            ref.t(BKeys.fri),
//                            ref.t(BKeys.sat),
//                            ref.t(BKeys.sun),
//
//
//                          ];
//                         if (value.toInt() >= 0 && value.toInt() < days.length) {
//                           return Text(days[value.toInt()]);
//                         }
//                         return Container();
//                       },
//                     ),
//                   ),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 minX: 0,
//                 maxX: 6,
//                 minY: 0,
//                 maxY: 400,
//                 lineBarsData: [
//                   // Yellow line
//                   LineChartBarData(
//                     spots: const [
//                       FlSpot(0, 300),
//                       FlSpot(1, 320),
//                       FlSpot(2, 360),
//                       FlSpot(3, 330),
//                       FlSpot(4, 350),
//                       FlSpot(5, 370),
//                       FlSpot(6, 340),
//                     ],
//                     isCurved: true,
//                     color: Colors.orange,
//                     barWidth: 2,
//                     belowBarData: BarAreaData(
//                       show: true,
//                       color: Colors.orange.withOpacity(0.2),
//                     ),
//                     dotData: FlDotData(show: false),
//                   ),
//                   // Grey line
//                   LineChartBarData(
//                     spots: const [
//                       FlSpot(0, 200),
//                       FlSpot(1, 210),
//                       FlSpot(2, 220),
//                       FlSpot(3, 215),
//                       FlSpot(4, 225),
//                       FlSpot(5, 230),
//                       FlSpot(6, 220),
//                     ],
//                     isCurved: true,
//                     color: Colors.grey,
//                     barWidth: 2,
//                     belowBarData: BarAreaData(
//                       show: true,
//                       color: Colors.grey.withOpacity(0.1),
//                     ),
//                     dotData: FlDotData(show: false),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
// =======
//       child: asyncWeekly.when(
//         loading: () => const SizedBox(
//           height: 200,
//           child: Center(child: CircularProgressIndicator()),
//         ),
//         error: (e, _) => SizedBox(
//           height: 200,
//           child: Center(child: Text('Failed to load chart: $e')),
//         ),
//         data: (weekly) => _WeeklyChartContent(data: weekly),
// >>>>>>> c7b9ac4f4e9464cbd43272dedff7d98d819593c4
//       ),
//     );
//   }
// }
//
// class _WeeklyChartContent extends StatelessWidget {
//   const _WeeklyChartContent({required this.data});
//
//   final WeeklySellData data;
//
//   @override
//   Widget build(BuildContext context) {
//     final days = data.days.isEmpty
//         ? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
//         : data.days;
//
//     final currentSpots = _toSpots(data.currentPeriod);
//     final previousSpots = _toSpots(data.previousPeriod);
//
//     final maxVal = [
//       ...data.currentPeriod,
//       ...data.previousPeriod,
//     ].fold<double>(0, (prev, v) => math.max(prev, v));
//
//     final maxY = maxVal == 0 ? 10.0 : maxVal * 1.2;
//     final maxX = (days.length - 1).toDouble();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ------- Title + legend -------
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "Sales",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
//             ),
//             SizedBox(width: 40.w),
//             _LegendItem(color: Colors.orange, text: "Current Period"),
//             SizedBox(width: 10.w),
//             _LegendItem(color: Colors.grey, text: "Previous Period"),
//           ],
//         ),
//         SizedBox(height: 12.h),
//
//         // ------- Chart -------
//         SizedBox(
//           height: 200.h,
//           child: LineChart(
//             LineChartData(
//               gridData: FlGridData(show: true, drawVerticalLine: false),
//               titlesData: FlTitlesData(
//                 leftTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     reservedSize: 40,
//                     getTitlesWidget: (value, _) {
//                       if (maxY <= 0) return const SizedBox.shrink();
//                       // simple step
//                       return Text(value.toInt().toString());
//                     },
//                   ),
//                 ),
//                 rightTitles: AxisTitles(
//                   sideTitles: SideTitles(showTitles: false),
//                 ),
//                 topTitles: AxisTitles(
//                   sideTitles: SideTitles(showTitles: false),
//                 ),
//                 bottomTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     interval: 1,
//                     getTitlesWidget: (value, _) {
//                       final index = value.toInt();
//                       if (index >= 0 && index < days.length) {
//                         return Text(
//                           days[index],
//                           style: TextStyle(fontSize: 12.sp),
//                         );
//                       }
//                       return const SizedBox.shrink();
//                     },
//                   ),
//                 ),
//               ),
//               borderData: FlBorderData(show: false),
//               minX: 0,
//               maxX: maxX,
//               minY: 0,
//               maxY: maxY,
//               lineBarsData: [
//                 // 🔶 Current period (orange)
//                 LineChartBarData(
//                   spots: currentSpots,
//                   isCurved: true,
//                   color: Colors.orange,
//                   barWidth: 2,
//                   belowBarData: BarAreaData(
//                     show: true,
//                     color: Colors.orange.withOpacity(0.2),
//                   ),
//                   dotData: FlDotData(show: false),
//                 ),
//                 // ⚪ Previous period (grey)
//                 LineChartBarData(
//                   spots: previousSpots,
//                   isCurved: true,
//                   color: Colors.grey,
//                   barWidth: 2,
//                   belowBarData: BarAreaData(
//                     show: true,
//                     color: Colors.grey.withOpacity(0.1),
//                   ),
//                   dotData: FlDotData(show: false),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   List<FlSpot> _toSpots(List<double> values) {
//     return values
//         .asMap()
//         .entries
//         .map((e) => FlSpot(e.key.toDouble(), e.value))
//         .toList();
//   }
// }
//
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
//
// // class _LegendItem extends StatelessWidget {
// //   final Color color;
// //   final String text;
// //   const _LegendItem({required this.color, required this.text});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Row(
// //       children: [
// //         CircleAvatar(radius: 4, backgroundColor: color),
// //         SizedBox(width: 4.w),
// //         Text(text, style: TextStyle(fontSize: 12.sp)),
// //       ],
// //     );
// //   }
// // }
//
// /* ------------------------ Top Selling Table ------------------------ */
//
// class _TopRow {
//   final String name;
//   final int quantity;
//   final double revenue;
//
//   _TopRow(this.name, this.quantity, this.revenue);
// }
//
// class _TopSellingTable extends ConsumerWidget {
//   final List<_TopRow> rows;
//   const _TopSellingTable({super.key, required this.rows});
//
//   @override
// <<<<<<< HEAD
//   Widget build(BuildContext context, ref ) {
//     final headerStyle = TextStyle(
//       color: AllColor.black54,
//       fontWeight: FontWeight.w700,
//     );
//     final rowStyle = TextStyle(
//       color: AllColor.black,
//       fontWeight: FontWeight.w600,
//     );
//
// =======
//   Widget build(BuildContext context) {
// >>>>>>> c7b9ac4f4e9464cbd43272dedff7d98d819593c4
//     return Container(
//       decoration: BoxDecoration(
//         color: AllColor.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: AllColor.grey200),
//       ),
//       child: Column(
//         children: [
//           // Header row
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//             child: Row(
//               children: [
// <<<<<<< HEAD
//                 Expanded(flex: 6, child: Text(
//                    // 'Product',
//                   ref.t(BKeys.product),
//                     style: headerStyle)),
//                 Expanded(flex: 2, child: Text('units', style: headerStyle)),
//                 Expanded(
//                   flex: 3,
//                   child: Align(
//                     alignment: Alignment.centerRight,
//                     child: Text(
//                         //'Revenues',
//                       ref.t(BKeys.revenues),
//                         style: headerStyle),
// =======
//                 Expanded(
//                   flex: 4,
//                   child: Text(
//                     'Product',
//                     style: TextStyle(
//                       color: AllColor.black,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 12.sp,
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Text(
//                     'Qty',
//                     textAlign: TextAlign.right,
//                     style: TextStyle(
//                       color: AllColor.black,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 12.sp,
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 3,
//                   child: Text(
//                     'Revenue',
//                     textAlign: TextAlign.right,
//                     style: TextStyle(
//                       color: AllColor.black,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 12.sp,
//                     ),
// >>>>>>> c7b9ac4f4e9464cbd43272dedff7d98d819593c4
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Divider(height: 1, color: AllColor.grey200),
//
//           // Data rows
//           ...rows.map(
//             (r) => Padding(
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: 4,
//                     child: Text(
//                       r.name,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(color: AllColor.black, fontSize: 12.sp),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 2,
//                     child: Text(
//                       r.quantity.toString(),
//                       textAlign: TextAlign.right,
//                       style: TextStyle(
//                         color: AllColor.black87,
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 3,
//                     child: Text(
//                       r.revenue.toStringAsFixed(2),
//                       textAlign: TextAlign.right,
//                       style: TextStyle(
//                         color: AllColor.black87,
//                         fontSize: 12.sp,
//                         fontWeight: FontWeight.w600,
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
// //
// // class _TopSellingTable extends StatelessWidget {
// //   final List<_TopRow> rows;
// //   const _TopSellingTable({required this.rows});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final headerStyle = TextStyle(
// //       color: AllColor.black54,
// //       fontWeight: FontWeight.w700,
// //     );
// //     final rowStyle = TextStyle(
// //       color: AllColor.black,
// //       fontWeight: FontWeight.w600,
// //     );
// //
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: AllColor.white,
// //         borderRadius: BorderRadius.circular(10),
// //         border: Border.all(color: AllColor.grey200),
// //       ),
// //       child: Column(
// //         children: [
// //           // header
// //           Container(
// //             padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 10.w),
// //             decoration: BoxDecoration(
// //               color: AllColor.grey100,
// //               borderRadius: const BorderRadius.vertical(
// //                 top: Radius.circular(10),
// //               ),
// //             ),
// //             child: Row(
// //               children: [
// //                 Expanded(flex: 6, child: Text('Product', style: headerStyle)),
// //                 Expanded(flex: 2, child: Text('units', style: headerStyle)),
// //                 Expanded(
// //                   flex: 3,
// //                   child: Align(
// //                     alignment: Alignment.centerRight,
// //                     child: Text('Revenues', style: headerStyle),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           // rows
// //           ...rows.map(
// //             (r) => Container(
// //               padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 12.w),
// //               decoration: BoxDecoration(
// //                 border: Border(top: BorderSide(color: AllColor.grey200)),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Expanded(flex: 6, child: Text(r.product, style: rowStyle)),
// //                   Expanded(flex: 2, child: Text('${r.units}', style: rowStyle)),
// //                   Expanded(
// //                     flex: 3,
// //                     child: Align(
// //                       alignment: Alignment.centerRight,
// //                       child: Text(
// //                         '\$${r.revenue.toStringAsFixed(2)}',
// //                         style: rowStyle,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// // ui_top_selling_products.dart
//
// class TopSellingSection extends ConsumerWidget {
//   const TopSellingSection({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final asyncTop = ref.watch(vendorTopProductsProvider);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 10.h),
//
//         asyncTop.when(
//           loading: () => const Padding(
//             padding: EdgeInsets.all(16),
//             child: Center(child: CircularProgressIndicator()),
//           ),
//           error: (e, _) => Padding(
//             padding: const EdgeInsets.all(16),
//             child: Text(
//               'Failed to load products: $e',
//               style: TextStyle(color: AllColor.red, fontSize: 12.sp),
//             ),
//           ),
//           data: (data) {
//             final products = data.products;
//
//             if (products.isEmpty) {
//               return Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Text(
//                   'No top products found yet',
//                   style: TextStyle(color: AllColor.black54, fontSize: 13.sp),
//                 ),
//               );
//             }
//
//             final rows = products
//                 .map((p) => _TopRow(p.name, p.totalQuantity, p.totalRevenue))
//                 .toList();
//
//             return _TopSellingTable(rows: rows);
//           },
//         ),
//       ],
//     );
//   }
// }
//
// class _DaysFilterDropdown extends StatelessWidget {
//   final int selectedDays;
//   final ValueChanged<int> onDaysChanged;
//
//   const _DaysFilterDropdown({
//     Key? key,
//     required this.selectedDays,
//     required this.onDaysChanged,
//   }) : super(key: key);
//
//   String _labelForDays(int days) {
//     if (days == 7) return 'Last 7 days';
//     if (days == 30) return 'Last 30 days';
//     if (days == 90) return 'Last 90 days';
//     return 'Last $days days';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(20.r),
//       onTap: () async {
//         // 1) bottom sheet theke 7/30/90 ba "custom" select হবে
//         final result = await showModalBottomSheet<int>(
//           context: context,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
//           ),
//           builder: (ctx) {
//             return SafeArea(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   SizedBox(height: 8.h),
//                   Container(
//                     width: 40.w,
//                     height: 4.h,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade400,
//                       borderRadius: BorderRadius.circular(2.r),
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//
//                   ListTile(
//                     title: const Text('Last 7 days'),
//                     onTap: () => Navigator.pop(ctx, 7),
//                   ),
//                   ListTile(
//                     title: const Text('Last 30 days'),
//                     onTap: () => Navigator.pop(ctx, 30),
//                   ),
//                   ListTile(
//                     title: const Text('Last 90 days'),
//                     onTap: () => Navigator.pop(ctx, 90),
//                   ),
//                   const Divider(),
//
//                   // 👇 Custom date → calendar
//                   ListTile(
//                     leading: const Icon(Icons.date_range),
//                     title: const Text('Custom date (choose from calendar)'),
//                     onTap: () => Navigator.pop(ctx, -1),
//                   ),
//                   SizedBox(height: 8.h),
//                 ],
//               ),
//             );
//           },
//         );
//
//         if (result == null) return;
//
//         int days = result;
//
//         // 2) Custom select করলে calendar খুলবে
//         if (result == -1) {
//           final picked = await showDatePicker(
//             context: context,
//             initialDate: DateTime.now(),
//             firstDate: DateTime.now().subtract(const Duration(days: 365)),
//             lastDate: DateTime.now(),
//           );
//           if (picked == null) return;
//
//           // today - picked = kotodin er range
//           final onlyDatePicked = DateTime(
//             picked.year,
//             picked.month,
//             picked.day,
//           );
//           final onlyToday = DateTime.now();
//           days = onlyToday.difference(onlyDatePicked).inDays + 1;
//
//           if (days <= 0) {
//             // jodi future date choose kore, ignore kore felbo
//             return;
//           }
//         }
//
//         onDaysChanged(days); // 🔥 provider update → API abar call hobe
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20.r),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.calendar_today_rounded,
//               size: 14.sp,
//               color: Colors.black54,
//             ),
//             SizedBox(width: 8.w),
//             Text(
//               _labelForDays(selectedDays),
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             SizedBox(width: 4.w),
//             Icon(
//               Icons.keyboard_arrow_down_rounded,
//               size: 18.sp,
//               color: Colors.black54,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
