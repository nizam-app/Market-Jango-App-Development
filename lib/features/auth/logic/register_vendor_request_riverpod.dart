import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/vendor_request_model.dart';

final vendorRegisterProvider =
StateNotifierProvider<VendorRegisterNotifier, AsyncValue<VendorModel?>>(
      (ref) => VendorRegisterNotifier(),
);

class VendorRegisterNotifier extends StateNotifier<AsyncValue<VendorModel?>> {
  VendorRegisterNotifier() : super(const AsyncData(null));

  Future<void> registerVendor({
    required String url,
    required String country,
    required String businessName,
    required String businessType,
    required String address,
    required List<File> files, // ✅ any file type (image, pdf, doc, etc.)
  }) async {
    state = const AsyncLoading();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) throw 'Missing auth token';

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Accept': 'application/json',
        'token': token,
      });

      // ✅ Add text fields
      request.fields['country'] = country;
      request.fields['business_name'] = businessName;
      request.fields['business_type'] = businessType;
      request.fields['address'] = address;

      // ✅ Add any type of file (jpg, png, pdf, doc, docx etc.)
      for (var file in files) {
        final filename = file.path.split('/').last;
        final fileStream = await http.MultipartFile.fromPath(
          'files[]',
          file.path,
          filename: filename,
          // contentType optional — http automatically detects mime type
        );
        request.files.add(fileStream);
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();
      Logger().i('Vendor Register Response: $body');

      final json = jsonDecode(body);
      if (response.statusCode == 201 && json['status'] == 'success') {
        final vendor = VendorModel.fromJson(json['data']);
        state = AsyncData(vendor);
      } else {
        throw json['message'] ?? 'Vendor registration failed';
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
