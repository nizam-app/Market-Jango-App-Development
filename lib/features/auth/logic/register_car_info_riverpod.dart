import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/car_info_model.dart';

final driverRegisterProvider =
StateNotifierProvider<DriverRegisterNotifier, AsyncValue<DriverRegisterModel?>>(
        (ref) => DriverRegisterNotifier());

class DriverRegisterNotifier extends StateNotifier<AsyncValue<DriverRegisterModel?>> {
  DriverRegisterNotifier() : super(const AsyncValue.data(null));

  Future<void> registerDriver({
    required String url,
    required String carName,
    required String carModel,
    required String location,
    required String price,
    required String routeId,
    required List<File> files,
  }) async {
    state = const AsyncValue.loading();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) throw 'Missing auth token';

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // ✅ Laravel header (same as Postman)
      request.headers.addAll({
        // 'Accept': 'application/json',
        'token': token,
      });

      // ✅ add fields
      request.fields.addAll({
        'car_name': carName,
        'car_model': carModel,
        'location': location,
        'price': price,
        'route_id': routeId,
      });

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


      final json = jsonDecode(body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          json['status'] == 'success') {
        Logger().i('🚗 Driver Register Response: $body');
        final driver = DriverRegisterModel.fromJson(json['data']);
        state = AsyncValue.data(driver);
      } else {
        throw json['message'] ?? 'Driver registration failed';
      }
    } catch (e, st) {
      Logger().e('⛔ Driver Register Error: $e');
      state = AsyncValue.error(e, st);
    }
  }
}
