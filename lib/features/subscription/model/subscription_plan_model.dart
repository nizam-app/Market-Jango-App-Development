/// Model for one subscription plan from GET /api/subscription/plans
class SubscriptionPlanModel {
  final int id;
  final String name;
  final String description;
  final String price;
  final String currency;
  final String billingPeriod;
  final int categoryLimit;
  final int imageLimit;
  final int visibilityLimit;
  final bool hasAffiliate;
  final bool hasPriorityRanking;
  final int priorityBoost;
  final String forUserType;
  final String status;
  final int sortOrder;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.billingPeriod,
    required this.categoryLimit,
    required this.imageLimit,
    required this.visibilityLimit,
    required this.hasAffiliate,
    required this.hasPriorityRanking,
    required this.priorityBoost,
    required this.forUserType,
    required this.status,
    required this.sortOrder,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      currency: json['currency']?.toString() ?? 'USD',
      billingPeriod: json['billing_period']?.toString() ?? 'monthly',
      categoryLimit: (json['category_limit'] as num?)?.toInt() ?? 0,
      imageLimit: (json['image_limit'] as num?)?.toInt() ?? 0,
      visibilityLimit: (json['visibility_limit'] as num?)?.toInt() ?? 0,
      hasAffiliate: json['has_affiliate'] == true,
      hasPriorityRanking: json['has_priority_ranking'] == true,
      priorityBoost: (json['priority_boost'] as num?)?.toInt() ?? 0,
      forUserType: json['for_user_type']?.toString() ?? 'vendor',
      status: json['status']?.toString() ?? 'active',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  String get priceLabel => '$currency $price/${billingPeriod == 'monthly' ? 'mo' : 'yr'}';
}
