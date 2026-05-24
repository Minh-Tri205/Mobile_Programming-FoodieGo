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

  // LOGIN
  Future<UserModel?> login(String email, String password) async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      final users = data.map((e) => UserModel.fromJson(e)).toList();

      final hashedPassword = hashPassword(password);

      try {
        final user = users.firstWhere(
          (u) =>
              u.email == email &&
              u.passwordHash == hashedPassword &&
              u.isActive != false,
        );
        return user;
      } catch (e) {
        return null;
      }
    }

    return null;
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
