/// Single vendor in ranked vendors list.
class RankedVendorModel {
  final int id;
  final String businessName;
  final String? country;
  final String? address;
  final double avgRating;
  final int click;
  final int boostValue;
  final int organicScore;
  final int priorityScore;
  final int rank;

  const RankedVendorModel({
    required this.id,
    required this.businessName,
    this.country,
    this.address,
    this.avgRating = 0,
    this.click = 0,
    this.boostValue = 0,
    this.organicScore = 0,
    this.priorityScore = 0,
    required this.rank,
  });

  factory RankedVendorModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, {int def = 0}) {
      if (v == null) return def;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? def;
    }

    double toDouble(dynamic v, {double def = 0}) {
      if (v == null) return def;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? def;
    }

    return RankedVendorModel(
      id: toInt(json['id']),
      businessName: json['business_name']?.toString() ?? '',
      country: json['country']?.toString(),
      address: json['address']?.toString(),
      avgRating: toDouble(json['avg_rating']),
      click: toInt(json['click']),
      boostValue: toInt(json['boost_value']),
      organicScore: toInt(json['organic_score']),
      priorityScore: toInt(json['priority_score']),
      rank: toInt(json['rank']),
    );
  }
}

/// Single driver in ranked drivers list.
class RankedDriverModel {
  final int id;
  final String? carName;
  final String? carModel;
  final String? location;
  final double rating;
  final int boostValue;
  final int organicScore;
  final int priorityScore;
  final int rank;

  const RankedDriverModel({
    required this.id,
    this.carName,
    this.carModel,
    this.location,
    this.rating = 0,
    this.boostValue = 0,
    this.organicScore = 0,
    this.priorityScore = 0,
    required this.rank,
  });

  String get displayName {
    final parts = [carName, carModel].where((e) => e != null && e.toString().isNotEmpty);
    return parts.isEmpty ? 'Driver #$id' : parts.join(' ');
  }

  factory RankedDriverModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, {int def = 0}) {
      if (v == null) return def;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? def;
    }

    double toDouble(dynamic v, {double def = 0}) {
      if (v == null) return def;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? def;
    }

    return RankedDriverModel(
      id: toInt(json['id']),
      carName: json['car_name']?.toString(),
      carModel: json['car_model']?.toString(),
      location: json['location']?.toString(),
      rating: toDouble(json['rating']),
      boostValue: toInt(json['boost_value']),
      organicScore: toInt(json['organic_score']),
      priorityScore: toInt(json['priority_score']),
      rank: toInt(json['rank']),
    );
  }
}

/// My rank response (Vendor or Driver).
class MyRankModel {
  final String userType;
  final int rank;
  final int organicScore;
  final int boostValue;
  final int priorityScore;

  const MyRankModel({
    required this.userType,
    required this.rank,
    required this.organicScore,
    required this.boostValue,
    required this.priorityScore,
  });

  factory MyRankModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, {int def = 0}) {
      if (v == null) return def;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? def;
    }

    return MyRankModel(
      userType: json['user_type']?.toString() ?? '',
      rank: toInt(json['rank']),
      organicScore: toInt(json['organic_score']),
      boostValue: toInt(json['boost_value']),
      priorityScore: toInt(json['priority_score']),
    );
  }
}
