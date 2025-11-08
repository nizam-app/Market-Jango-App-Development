// categories_pagination_notifier.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/buyer/model/buyer_category_model.dart';

class CategoryRepository {
  final String baseUrl;
  final String token;

  CategoryRepository({required this.baseUrl, required this.token});

  Future<CategoryResponse> fetchCategories({int page = 1}) async {
    final uri = Uri.parse('$baseUrl?page=$page');
    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'token': token,
      },
    );

    if (res.statusCode == 200) {
      return CategoryResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception(
      'Failed to fetch categories: ${res.statusCode} ${res.reasonPhrase}',
    );
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, CategoryResponse?>(
      CategoriesNotifier.new,
    );

class CategoriesNotifier extends AsyncNotifier<CategoryResponse?> {
  int _page = 1;
  int get currentPage => _page;

  @override
  Future<CategoryResponse?> build() async => _fetch();

  Future<void> changePage(int newPage) async {
    if (newPage == _page) return;
    _page = newPage;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> nextPage() async {
    final last = state.value?.data.lastPage ?? _page + 1;
    if (_page < last) await changePage(_page + 1);
  }

  Future<void> prevPage() async {
    if (_page > 1) await changePage(_page - 1);
  }

  Future<CategoryResponse> _fetch() async {
    final token = await ref.read(authTokenProvider.future) ?? '';
    final repo = CategoryRepository(
      baseUrl: BuyerAPIController.category, // e.g. /api/category
      token: token,
    );
    return repo.fetchCategories(page: _page);
  }
}
