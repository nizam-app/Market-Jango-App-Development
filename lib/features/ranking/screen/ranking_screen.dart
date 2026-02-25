import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/utils/get_user_type.dart';
import 'package:market_jango/features/ranking/data/ranking_data.dart';
import 'package:market_jango/features/ranking/model/ranking_model.dart';

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  static const String routeName = '/ranking';

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userTypeAsync = ref.watch(getUserTypeProvider);
    final myRankAsync = ref.watch(myRankProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Rankings',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: AllColor.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.r, color: AllColor.black),
          onPressed: () => context.pop(),
        ),
        bottom: userTypeAsync.when(
          data: (userType) {
            // Vendor or driver: no tabs, show single section
            if (userType == 'vendor' || userType == 'driver') {
              return null;
            }
            // Buyer/transport/other: show both tabs
            _tabController ??= TabController(length: 2, vsync: this);
            return PreferredSize(
              preferredSize: Size.fromHeight(48.h),
              child: Container(
                color: AllColor.white,
                child: TabBar(
                  controller: _tabController!,
                  labelColor: AllColor.loginButtomColor,
                  unselectedLabelColor: AllColor.grey500,
                  indicatorColor: AllColor.loginButtomColor,
                  indicatorWeight: 3,
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Vendors'),
                    Tab(text: 'Drivers'),
                  ],
                ),
              ),
            );
          },
          loading: () => null,
          error: (_, __) => null,
        ),
      ),
      body: userTypeAsync.when(
        data: (userType) {
          // My Rank card: only for vendor or driver
          final myRankWidget = (userType == 'vendor' || userType == 'driver')
              ? myRankAsync.when(
                  data: (myRank) {
                    if (myRank == null) return const SizedBox.shrink();
                    return _MyRankCard(myRank: myRank);
                  },
                  loading: () => Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Center(
                      child: SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                )
              : const SizedBox.shrink();

          // Content: vendor → only vendors, driver → only drivers, else → both tabs
          Widget content;
          if (userType == 'vendor') {
            content = const _RankedVendorsTab();
          } else if (userType == 'driver') {
            content = const _RankedDriversTab();
          } else {
            _tabController ??= TabController(length: 2, vsync: this);
            content = TabBarView(
              controller: _tabController!,
              children: const [
                _RankedVendorsTab(),
                _RankedDriversTab(),
              ],
            );
          }

          return Column(
            children: [
              myRankWidget,
              Expanded(child: content),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Could not load user type')),
      ),
    );
  }
}

class _MyRankCard extends StatelessWidget {
  final MyRankModel myRank;

  const _MyRankCard({required this.myRank});

  @override
  Widget build(BuildContext context) {
    final typeLabel = myRank.userType == 'vendor' ? 'Vendor' : 'Driver';
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AllColor.loginButtomColor,
            AllColor.loginButtomColor.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AllColor.loginButtomColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'My rank',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                typeLabel,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '#${myRank.rank}',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ScoreRow('Priority score', myRank.priorityScore),
                    SizedBox(height: 4.h),
                    _ScoreRow('Organic', myRank.organicScore),
                    SizedBox(height: 4.h),
                    _ScoreRow('Boost', myRank.boostValue),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final int value;

  const _ScoreRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white70,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _RankedVendorsTab extends ConsumerWidget {
  const _RankedVendorsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = const RankedVendorsParams();
    final async = ref.watch(rankedVendorsProvider(params));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(rankedVendorsProvider(params));
      },
      child: async.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 48.h),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
        error: (e, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 48.h),
            Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48.sp, color: AllColor.grey500),
                    SizedBox(height: 12.h),
                    Text(
                      e.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.sp, color: AllColor.grey500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        data: (result) {
          if (result.vendors.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 48.h),
                Center(
                  child: Text(
                    'No ranked vendors',
                    style: TextStyle(fontSize: 14.sp, color: AllColor.grey500),
                  ),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: result.vendors.length,
            itemBuilder: (context, index) {
              return _VendorRankCard(vendor: result.vendors[index]);
            },
          );
        },
      ),
    );
  }
}

class _VendorRankCard extends StatelessWidget {
  final RankedVendorModel vendor;

  const _VendorRankCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _RankBadge(rank: vendor.rank),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.businessName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AllColor.black,
                  ),
                ),
                if (vendor.address != null && vendor.address!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    vendor.address!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AllColor.grey500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 6.h),
                Row(
                    children: [
                      Icon(Icons.star, size: 14.r, color: AllColor.orange),
                      SizedBox(width: 4.w),
                      Text(
                        vendor.avgRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AllColor.black87,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Score: ${vendor.priorityScore}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AllColor.grey500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RankedDriversTab extends ConsumerWidget {
  const _RankedDriversTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const params = RankedDriversParams();
    final async = ref.watch(rankedDriversProvider(params));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(rankedDriversProvider(params));
      },
      child: async.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 48.h),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
        error: (e, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 48.h),
            Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48.sp, color: AllColor.grey500),
                    SizedBox(height: 12.h),
                    Text(
                      e.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.sp, color: AllColor.grey500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        data: (result) {
          if (result.drivers.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 48.h),
                Center(
                  child: Text(
                    'No ranked drivers',
                    style: TextStyle(fontSize: 14.sp, color: AllColor.grey500),
                  ),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: result.drivers.length,
            itemBuilder: (context, index) {
              return _DriverRankCard(driver: result.drivers[index]);
            },
          );
        },
      ),
    );
  }
}

class _DriverRankCard extends StatelessWidget {
  final RankedDriverModel driver;

  const _DriverRankCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _RankBadge(rank: driver.rank),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.displayName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AllColor.black,
                  ),
                ),
                if (driver.location != null && driver.location!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    driver.location!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AllColor.grey500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.star, size: 14.r, color: AllColor.orange),
                    SizedBox(width: 4.w),
                    Text(
                      driver.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AllColor.black87,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Score: ${driver.priorityScore}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AllColor.grey500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: rank <= 3
            ? AllColor.loginButtomColor.withOpacity(0.15)
            : AllColor.grey100,
        shape: BoxShape.circle,
        border: Border.all(
          color: rank <= 3 ? AllColor.loginButtomColor : AllColor.grey200,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '#$rank',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: rank <= 3 ? AllColor.loginButtomColor : AllColor.black87,
        ),
      ),
    );
  }
}
