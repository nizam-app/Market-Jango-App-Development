
import 'dart:convert';


import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/%20business_logic/models/categories_model.dart';
class Category {
  static final loadCategories = FutureProvider<List<CategoryModel>>((ref) async {
    final String response = await rootBundle.loadString(
        'assets/json/categories.json');
    final List<dynamic> data = json.decode(response);

    return data.map((item) => CategoryModel.fromJson(item)).toList();
  });
}