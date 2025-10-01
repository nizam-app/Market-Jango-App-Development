import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

class VendorSalePlatformScreen extends StatelessWidget {
  const VendorSalePlatformScreen({super.key});
  static const routeName = "/vendorSalePlatform";

  @override
  Widget build(BuildContext context) {
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
              Text(
                'Store Performance',
                style: TextStyle(
                  color: AllColor.black,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Last 30 days overview',
                style: TextStyle(
                  color: AllColor.black54,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),

              // Last 7 days chip
              Align(
                alignment: Alignment.centerLeft,
                child: _FilterChipButton(
                  text: 'Last 7 days',
                  icon: Icons.calendar_today_rounded,
                  onTap: () async {
                    final now = DateTime.now();
                    final firstDate = now.subtract(const Duration(days: 7));
                    final lastDate = now;

                    final picked = await showDatePicker(
                      context: context,
                      initialDate: lastDate,
                      firstDate: firstDate,
                      lastDate: lastDate,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Colors.deepPurple, // header color
                              onPrimary: Colors.white, // header text color
                              onSurface: Colors.black, // body text color
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (picked != null) {
                      debugPrint("Selected date: $picked");
                      // এখানে filter apply করতে পারবেন
                    }
                  },
                ),
              ),

              SizedBox(height: 14.h),

              // KPI cards 2 x 2
              _KpiGrid(
                items: const [
                  _KpiData(
                    title: 'Revenue',
                    value: '\$3,490',
                    deltaText: '38% vs previous',
                  ),
                  _KpiData(
                    title: 'Orders',
                    value: '280',
                    deltaText: '24% vs previous',
                  ),
                  _KpiData(
                    title: 'Clicks',
                    value: '4,280',
                    deltaText: '9% vs previous',
                  ),
                  _KpiData(
                    title: 'conversion rate',
                    value: '1.2%',
                    deltaText: '13% vs previous',
                  ),
                ],
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
              _TopSellingTable(
                rows: const [
                  _TopRow('T-shirt', 780, 1200),
                  _TopRow('Sneakers', 280, 1400),
                  _TopRow('Backpack', 250, 1400),
                ],
              ),
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

/* ------------------------------ Sales ------------------------------ */

class SalesChart extends StatelessWidget {
  const SalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sales",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              SizedBox(width: 40.w),
              _LegendItem(color: Colors.orange, text: "Previous Period"),
              SizedBox(width: 10.w),
              _LegendItem(color: Colors.grey, text: "Previous Period"),
            ],
          ),
          SizedBox(height: 12.h),

          // Chart
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
                        if (value % 100 != 0) return Container();
                        return Text("\$${value.toInt()}");
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
                      interval: 1, // 🔹 Add this line
                      getTitlesWidget: (value, _) {
                        const days = [
                          "Mon",
                          "Tue",
                          "Wed",
                          "Thu",
                          "Fri",
                          "Sat",
                          "Sun",
                        ];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(days[value.toInt()]);
                        }
                        return Container();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 400,
                lineBarsData: [
                  // Yellow line
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 300),
                      FlSpot(1, 320),
                      FlSpot(2, 360),
                      FlSpot(3, 330),
                      FlSpot(4, 350),
                      FlSpot(5, 370),
                      FlSpot(6, 340),
                    ],
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 2,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.orange.withOpacity(0.2),
                    ),
                    dotData: FlDotData(show: false),
                  ),
                  // Grey line
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 200),
                      FlSpot(1, 210),
                      FlSpot(2, 220),
                      FlSpot(3, 215),
                      FlSpot(4, 225),
                      FlSpot(5, 230),
                      FlSpot(6, 220),
                    ],
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
      ),
    );
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
  final String product;
  final int units;
  final double revenue;

  const _TopRow(this.product, this.units, this.revenue);
}

class _TopSellingTable extends StatelessWidget {
  final List<_TopRow> rows;
  const _TopSellingTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(
      color: AllColor.black54,
      fontWeight: FontWeight.w700,
    );
    final rowStyle = TextStyle(
      color: AllColor.black,
      fontWeight: FontWeight.w600,
    );

    return Container(
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AllColor.grey200),
      ),
      child: Column(
        children: [
          // header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 10.w),
            decoration: BoxDecoration(
              color: AllColor.grey100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 6, child: Text('Product', style: headerStyle)),
                Expanded(flex: 2, child: Text('units', style: headerStyle)),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Revenues', style: headerStyle),
                  ),
                ),
              ],
            ),
          ),
          // rows
          ...rows.map(
            (r) => Container(
              padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 12.w),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AllColor.grey200)),
              ),
              child: Row(
                children: [
                  Expanded(flex: 6, child: Text(r.product, style: rowStyle)),
                  Expanded(flex: 2, child: Text('${r.units}', style: rowStyle)),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '\$${r.revenue.toStringAsFixed(2)}',
                        style: rowStyle,
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