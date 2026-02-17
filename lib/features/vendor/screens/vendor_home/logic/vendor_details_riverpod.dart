import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/auth_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';

import '../model/user_details_model.dart';

final vendorProvider = FutureProvider<VendorDetailsModel>((ref) async {
  final authStorage = AuthLocalStorage();
  final user_token = await authStorage.getToken();
  final userId = await authStorage.getUserId();
  
  if (user_token == null) {
    throw Exception("Auth token not found");
  }
  
  if (userId == null) {
    throw Exception("User ID not found");
  }
  
  // Use user/show API instead of vendor/show
  final uri = Uri.parse("${AuthAPIController.user_show}?id=$userId");
  final response = await http.get(
    uri,
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "token": user_token,
    },
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>?;
    
    if (data == null) {
      throw Exception("Invalid response: data is null");
    }
    
    // Extract user object from response
    final userJson = data['user'] as Map<String, dynamic>?;
    
    if (userJson == null) {
      throw Exception("Invalid response: user is null");
    }
    
    // Extract vendor data from user object
    final vendorJson = userJson['vendor'] as Map<String, dynamic>?;
    
    // Build the data structure that VendorDetailsModel expects
    // Map user fields and vendor fields together
    final vendorData = <String, dynamic>{
      'id': userJson['id'] ?? vendorJson?['id'],
      'name': userJson['name'] ?? '',
      'image': userJson['image'] ?? 'https://i.pravatar.cc/150',
      'public_id': userJson['public_id'],
      // Cover image can be in user object or vendor object
      'cover_image': userJson['cover_image'] ?? vendorJson?['cover_image'],
    };
    
    return VendorDetailsModel.fromJson(vendorData);
  } else {
    throw Exception("Failed to load vendor data: ${response.statusCode}");
  }
});
