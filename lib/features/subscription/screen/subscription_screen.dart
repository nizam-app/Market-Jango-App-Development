import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/subscription/data/subscription_data.dart';
import 'package:market_jango/features/subscription/model/current_subscription_model.dart';
import 'package:market_jango/features/subscription/model/subscription_plan_model.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});
  static const String routeName = '/subscription';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ScreenBackground(
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tuppertextandbackbutton(screenName: 'Subscription'),
                SizedBox(height: 16.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _CurrentPlanSection(),
                        SizedBox(height: 24.h),
                        const _PlansSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _CurrentPlanSection extends ConsumerWidget {
  const _CurrentPlanSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAsync = ref.watch(currentSubscriptionProvider);
    return currentAsync.when(
      loading: () => _card(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: SizedBox(
              width: 24.w,
              height: 24.h,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      error: (e, _) => _card(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Text(
            'Could not load current plan: $e',
            style: TextStyle(fontSize: 14.sp, color: AllColor.red),
          ),
        ),
      ),
      data: (data) {
        final sub = data.subscription;
        if (sub == null) {
          return _card(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                children: [
                  Icon(Icons.card_membership_outlined,
                      color: AllColor.grey, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'No active subscription. Choose a plan below.',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AllColor.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return _card(
          child: _CurrentPlanContent(subscription: sub, usage: data.usage),
        );
      },
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AllColor.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CurrentPlanContent extends StatelessWidget {
  const _CurrentPlanContent({
    required this.subscription,
    this.usage,
  });
  final CurrentSubscriptionModel subscription;
  final SubscriptionUsageModel? usage;

  @override
  Widget build(BuildContext context) {
    final plan = subscription.plan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current plan',
          style: TextStyle(
            fontSize: 12.sp,
            color: AllColor.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          plan?.name ?? 'Plan #${subscription.subscriptionPlanId}',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
        if (plan != null) ...[
          SizedBox(height: 4.h),
          Text(
            plan.price,
            style: TextStyle(
              fontSize: 14.sp,
              color: AllColor.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        SizedBox(height: 8.h),
        Text(
          '${subscription.startDate} – ${subscription.endDate}',
          style: TextStyle(
            fontSize: 13.sp,
            color: AllColor.black54,
          ),
        ),
        if (usage != null) ...[
          SizedBox(height: 12.h),
          Divider(height: 1, color: AllColor.grey200),
          SizedBox(height: 8.h),
          Text(
            'Usage',
            style: TextStyle(
              fontSize: 12.sp,
              color: AllColor.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Categories: ${usage!.categoriesUsed} / ${usage!.categoriesLimit == 0 ? "∞" : usage!.categoriesLimit}  •  '
            'Images: ${usage!.imagesUsed} / ${usage!.imagesLimit == 0 ? "∞" : usage!.imagesLimit}  •  '
            'Visibility: ${usage!.visibilityLocationsUsed} / ${usage!.visibilityLimit == 0 ? "∞" : usage!.visibilityLimit}',
            style: TextStyle(fontSize: 12.sp, color: AllColor.black87),
          ),
        ],
      ],
    );
  }
}

class _PlansSection extends ConsumerWidget {
  const _PlansSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available plans',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
        SizedBox(height: 12.h),
        plansAsync.when(
          loading: () => Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: const CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Text(
              'Could not load plans: $e',
              style: TextStyle(fontSize: 14.sp, color: AllColor.red),
            ),
          ),
          data: (plans) {
            if (plans.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Text(
                  'No plans available.',
                  style: TextStyle(fontSize: 14.sp, color: AllColor.grey),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: plans.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _PlanCard(
                  plan: plans[index],
                  onSubscribe: () => _onSubscribe(context, ref, plans[index]),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _onSubscribe(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPlanModel plan,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Subscribe'),
        content: Text(
          'Subscribe to "${plan.name}" (${plan.priceLabel})? '
          'In a real app you would complete payment here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final token = await ref.read(authTokenProvider.future);
    try {
      await subscribeToPlan(
        token,
        subscriptionPlanId: plan.id,
        paymentMethod: 'stripe',
        transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        invalidateCurrentSubscription: () =>
            ref.invalidate(currentSubscriptionProvider),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription activated')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.onSubscribe,
  });
  final SubscriptionPlanModel plan;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AllColor.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AllColor.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      plan.priceLabel,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AllColor.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: onSubscribe,
                style: FilledButton.styleFrom(
                  backgroundColor: AllColor.orange,
                  foregroundColor: AllColor.white,
                ),
                child: const Text('Subscribe'),
              ),
            ],
          ),
          if (plan.description.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              plan.description,
              style: TextStyle(
                fontSize: 13.sp,
                color: AllColor.black87,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: [
              if (plan.categoryLimit > 0)
                _Chip(text: '${plan.categoryLimit} categories'),
              if (plan.imageLimit > 0)
                _Chip(text: '${plan.imageLimit} images'),
              if (plan.visibilityLimit > 0)
                _Chip(text: '${plan.visibilityLimit} visibility'),
              if (plan.hasAffiliate) _Chip(text: 'Affiliate'),
              if (plan.hasPriorityRanking)
                _Chip(text: 'Priority ranking'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AllColor.orange50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: AllColor.orange700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
