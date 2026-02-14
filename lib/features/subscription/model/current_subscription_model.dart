/// Plan summary nested in current subscription response
class SubscriptionPlanSummary {
  final int id;
  final String name;
  final String price;

  SubscriptionPlanSummary({
    required this.id,
    required this.name,
    required this.price,
  });

  factory SubscriptionPlanSummary.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanSummary(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
    );
  }
}

/// One subscription record from GET /api/subscription/current or POST subscribe
class CurrentSubscriptionModel {
  final int id;
  final int userId;
  final int subscriptionPlanId;
  final String startDate;
  final String endDate;
  final String? renewalDate;
  final String status;
  final String? paymentStatus;
  final String? amountPaid;
  final String? paymentMethod;
  final String? transactionId;
  final bool autoRenew;
  final SubscriptionPlanSummary? plan;

  CurrentSubscriptionModel({
    required this.id,
    required this.userId,
    required this.subscriptionPlanId,
    required this.startDate,
    required this.endDate,
    this.renewalDate,
    required this.status,
    this.paymentStatus,
    this.amountPaid,
    this.paymentMethod,
    this.transactionId,
    this.autoRenew = false,
    this.plan,
  });

  factory CurrentSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return CurrentSubscriptionModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      subscriptionPlanId: (json['subscription_plan_id'] as num).toInt(),
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      renewalDate: json['renewal_date']?.toString(),
      status: json['status']?.toString() ?? 'active',
      paymentStatus: json['payment_status']?.toString(),
      amountPaid: json['amount_paid']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      transactionId: json['transaction_id']?.toString(),
      autoRenew: json['auto_renew'] == true,
      plan: json['plan'] != null
          ? SubscriptionPlanSummary.fromJson(
              json['plan'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

/// Usage stats from GET /api/subscription/current
class SubscriptionUsageModel {
  final int categoriesUsed;
  final int categoriesLimit;
  final int imagesUsed;
  final int imagesLimit;
  final int visibilityLocationsUsed;
  final int visibilityLimit;

  SubscriptionUsageModel({
    required this.categoriesUsed,
    required this.categoriesLimit,
    required this.imagesUsed,
    required this.imagesLimit,
    required this.visibilityLocationsUsed,
    required this.visibilityLimit,
  });

  factory SubscriptionUsageModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionUsageModel(
      categoriesUsed: (json['categories_used'] as num?)?.toInt() ?? 0,
      categoriesLimit: (json['categories_limit'] as num?)?.toInt() ?? 0,
      imagesUsed: (json['images_used'] as num?)?.toInt() ?? 0,
      imagesLimit: (json['images_limit'] as num?)?.toInt() ?? 0,
      visibilityLocationsUsed:
          (json['visibility_locations_used'] as num?)?.toInt() ?? 0,
      visibilityLimit: (json['visibility_limit'] as num?)?.toInt() ?? 0,
    );
  }
}
