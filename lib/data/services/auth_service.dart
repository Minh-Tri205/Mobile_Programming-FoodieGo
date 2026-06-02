import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../../models/user_model.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:5187/api/User';

  // HASH PASSWORD
  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // LOGIN — goi POST /api/User/login, backend tu hash + verify
  // Tra ve UserModel khi thanh cong, null khi sai email/mat khau (401)
  Future<UserModel?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    }

    // 401 = sai email/mat khau hoac bi khoa
    if (response.statusCode == 401) {
      return null;
    }

    // Loi khac → throw de UI hien thi
    throw Exception(
      'Login failed: ${response.statusCode} - ${response.body}',
    );
  }

  // REGISTER
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    final body = {
      "fullName": fullName,
      "email": email.trim(),
      "phone": phone.trim(),
      "passwordHash": password,
      "role": "customer",
      "isActive": true,
    };

    final response = await http.post(
      Uri.parse(baseUrl),

      headers: {'Content-Type': 'application/json'},

      body: jsonEncode(body),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
