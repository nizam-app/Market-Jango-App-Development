// import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// final searchQueryProvider = StateProvider<String>((ref) => '');
//
// final searchDebouncerProvider =
// Provider.autoDispose<SearchDebouncer>((ref) => SearchDebouncer(ref));
//
// class SearchDebouncer {
//   final Ref ref;
//   Timer? _timer;
//   SearchDebouncer(this.ref);
//
//   void onQueryChanged(String query) {
//     _timer?.cancel();
//     _timer = Timer(const Duration(milliseconds: 500), () {
//       ref.read(searchQueryProvider.notifier).state = query;
//     });
//   }
//
//   void dispose() {
//     _timer?.cancel();
//   }
// }