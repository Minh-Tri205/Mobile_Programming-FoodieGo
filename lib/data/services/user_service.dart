import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/user_model.dart';

class UserService {
  static const String baseUrl = 'http://10.0.2.2:5187/api/User';

  // GET ALL
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data.map((e) => UserModel.fromJson(e)).toList();
      } else {
        throw Exception('Fetch users failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  // GET BY ID
  Future<UserModel> getUserById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fetch user failed');
    }
  }

  // CREATE
  Future<void> createUser(UserModel user) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Create user failed');
    }
  }

  // PATCH
  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Update user failed');
    }
  }

  // DELETE
  Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Delete user failed');
    }
  }

    // =========================
  // TOGGLE STATUS
  // =========================
  Future<void> toggleStatus(int id) async {
    final response = await http.patch(Uri.parse('$baseUrl/toggle-status/$id'));

    if (response.statusCode != 200) {
      throw Exception('Toggle status failed');
    }
  }

  // =========================
  // ACTIVATE USER
  // =========================
  Future<void> activateUser(int id) async {
    final response = await http.patch(Uri.parse('$baseUrl/activate/$id'));

    if (response.statusCode != 200) {
      throw Exception('Activate user failed');
    }
  }

  // =========================
  // DEACTIVATE USER
  // =========================
  Future<void> deactivateUser(int id) async {
    final response = await http.patch(Uri.parse('$baseUrl/deactivate/$id'));

    if (response.statusCode != 200) {
      throw Exception('Deactivate user failed');
    }
  }

  // =========================
  // CHANGE ROLE
  // =========================
  Future<void> changeRole(int id, String role) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/change-role/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(role), // backend nhận string raw
    );

    if (response.statusCode != 200) {
      throw Exception('Change role failed');
    }
  }
}
