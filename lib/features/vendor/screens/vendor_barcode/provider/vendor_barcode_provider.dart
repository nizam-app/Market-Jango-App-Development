import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/features/vendor/screens/vendor_barcode/data/vendor_barcode_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_barcode/model/vendor_barcode_models.dart';

class VendorBarcodeListParams {
  final int page;
  final String search;

  const VendorBarcodeListParams({this.page = 1, this.search = ''});

  VendorBarcodeListParams copyWith({int? page, String? search}) {
    return VendorBarcodeListParams(
      page: page ?? this.page,
      search: search ?? this.search,
    );
  }
}

final vendorBarcodeListParamsProvider =
    StateProvider<VendorBarcodeListParams>((ref) => const VendorBarcodeListParams());

final vendorBarcodeListProvider =
    FutureProvider.autoDispose<VendorBarcodeListPage>((ref) async {
  final p = ref.watch(vendorBarcodeListParamsProvider);
  return VendorBarcodeApi.instance.fetchBarcodeList(
    search: p.search.isEmpty ? null : p.search,
    page: p.page,
  );
});
