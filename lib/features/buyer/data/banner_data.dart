import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/features/buyer/model/banner_model.dart';
import '../../../../../core/utils/get_token_sharedpefarens.dart';
import '../../../../../core/constants/api_control/vendor_api.dart';

final bannerNotifierProvider =
AsyncNotifierProvider<BannerNotifier, PaginatedBanners?>(BannerNotifier.new);

class BannerNotifier extends AsyncNotifier<PaginatedBanners?> {
  int _page = 1;

  int get currentPage => _page;

  @override
  Future<PaginatedBanners?> build() async {
    return _fetchBanners();
  }

  Future<void> changePage(int newPage) async {
    _page = newPage;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchBanners);
  }

  Future<PaginatedBanners> _fetchBanners() async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null) throw Exception('Token not found');

    final baseUrl = BuyerAPIController.banner; // তোমার API route constant
    final uri = Uri.parse('$baseUrl?page=$_page');

    final response = await http.get(uri, headers: {'token': token});

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'];
      if (data == null) {
        return PaginatedBanners(
          currentPage: 1,
          lastPage: 1,
          total: 0,
          banners: [],
        );
      }
      return PaginatedBanners.fromJson(data);
    } else {
      throw Exception('Failed to fetch banners: ${response.statusCode}');
    }
  }
}