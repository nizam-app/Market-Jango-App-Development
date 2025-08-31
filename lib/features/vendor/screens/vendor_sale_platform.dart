import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

class VendorSalePlatformScreen extends StatelessWidget {
  const VendorSalePlatformScreen({super.key});
  static const routeName = "/vendorSalePlatform";

  get sp => null;

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

              _SalesCard(),

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

class _SalesCard extends StatelessWidget {
  _SalesCard({super.key});

  // two series (Mon..Sun)
  final List<double> _current = const [120, 180, 140, 200, 220, 240, 260];
  final List<double> _previous = const [100, 150, 130, 180, 200, 210, 230];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AllColor.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Sales',
                style: TextStyle(
                  color: AllColor.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 70.w),

              _LegendDot(color: AllColor.yellow500),
              SizedBox(width: 4.w),
              Text(
                'Previous Period',
                style: TextStyle(color: AllColor.black54, fontSize: 12.sp),
              ),
              const SizedBox(width: 16),
              _LegendDot(color: AllColor.yellow700),
              SizedBox(width: 4.w),
              Text(
                'Previous Period',
                style: TextStyle(color: AllColor.black54, fontSize: 12.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 170,
            child: _AreaChart(
              current: _current,
              previous: _previous,
              yLabels: const ['\$300', '\$200', '\$100', '\$00'],
              xLabels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10.h,
      width: 10.w,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Simple custom area chart with two series (no packages).
class _AreaChart extends StatelessWidget {
  final List<double> current;
  final List<double> previous;
  final List<String> xLabels;
  final List<String> yLabels;
  const _AreaChart({
    required this.current,
    required this.previous,
    required this.xLabels,
    required this.yLabels,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AreaChartPainter(
        current: current,
        previous: previous,
        xLabels: xLabels,
        yLabels: yLabels,
      ),
      size: Size.infinite,
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  final List<double> current, previous;
  final List<String> xLabels, yLabels;

  _AreaChartPainter({
    required this.current,
    required this.previous,
    required this.xLabels,
    required this.yLabels,
  });

  final _axis = Paint()
    ..color = Colors.black12
    ..strokeWidth = 1;
  final _grid = Paint()
    ..color = Colors.black12
    ..strokeWidth = 0.5;
  final _line1 = Paint()
    ..color = AllColor.yellow700
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final _line2 = Paint()
    ..color = AllColor.yellow500
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final _fill1 = Paint()..color = AllColor.yellow50;
  final _fill2 = Paint()..color = AllColor.yellow500.withOpacity(.12);

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 36.0;
    const rightPad = 10.0;
    const topPad = 8.0;
    const bottomPad = 28.0;

    final chart = Rect.fromLTWH(
      leftPad,
      topPad,
      size.width - leftPad - rightPad,
      size.height - topPad - bottomPad,
    );

    // Y grid (4 rows)
    for (int i = 0; i < 4; i++) {
      final dy = chart.top + chart.height * (i / 3);
      canvas.drawLine(
        Offset(chart.left, dy),
        Offset(chart.right, dy),
        i == 3 ? _axis : _grid,
      );
    }

    // X grid baseline
    canvas.drawLine(
      Offset(chart.left, chart.bottom),
      Offset(chart.right, chart.bottom),
      _axis,
    );

    // Scale
    final maxY = ([
      ...current,
      ...previous,
      300, // to match labels
    ]).reduce((a, b) => a > b ? a : b);

    Path pathFor(List<double> data) {
      final path = Path();
      for (int i = 0; i < data.length; i++) {
        final t = i / (data.length - 1);
        final dx = chart.left + chart.width * t;
        final dy = chart.bottom - (data[i] / maxY) * chart.height;
        if (i == 0) {
          path.moveTo(dx, dy);
        } else {
          path.lineTo(dx, dy);
        }
      }
      return path;
    }

    // Lines
    final p1 = pathFor(previous);
    final p2 = pathFor(current);

    // Fills (close to bottom)
    final area1 = Path.from(p1)
      ..lineTo(chart.right, chart.bottom)
      ..lineTo(chart.left, chart.bottom)
      ..close();
    final area2 = Path.from(p2)
      ..lineTo(chart.right, chart.bottom)
      ..lineTo(chart.left, chart.bottom)
      ..close();

    canvas.drawPath(area2, _fill2);
    canvas.drawPath(area1, _fill1);

    canvas.drawPath(p1, _line2);
    canvas.drawPath(p2, _line1);

    // Y labels
    final tpStyle = TextStyle(color: AllColor.black54, fontSize: 10);
    for (int i = 0; i < yLabels.length; i++) {
      final dy = chart.top + chart.height * (i / (yLabels.length - 1));
      final tp = TextPainter(
        text: TextSpan(text: yLabels[i], style: tpStyle),
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: leftPad - 6);
      tp.paint(canvas, Offset(0, dy - tp.height / 2));
    }

    // X labels
    for (int i = 0; i < xLabels.length; i++) {
      final t = i / (xLabels.length - 1);
      final dx = chart.left + chart.width * t;
      final tp = TextPainter(
        text: TextSpan(text: xLabels[i], style: tpStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 40);
      tp.paint(canvas, Offset(dx - tp.width / 2, chart.bottom + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter old) {
    return old.current != current || old.previous != previous;
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
