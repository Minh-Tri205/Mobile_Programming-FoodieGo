// lib/data/services/favorite_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/favorite_model.dart';

class FavoriteService {
  static const String baseUrl = 'http://10.0.2.2:5187/api/Favorite';

  Future<List<FavoriteModel>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => FavoriteModel.fromJson(e)).toList();
    }
    throw Exception('Fetch favorites failed: ${res.statusCode}');
  }

  Future<FavoriteModel> getById(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/$id'));
    if (res.statusCode == 200) {
      return FavoriteModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Fetch favorite failed: ${res.statusCode}');
  }

  Future<FavoriteModel> create(int userId, int foodId) async {
    final uri = Uri.parse(baseUrl);
    debugPrint('[FavoriteService] POST $uri body={userId:$userId,foodId:$foodId}');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'foodId': foodId}),
    );
    debugPrint('[FavoriteService] POST status=${res.statusCode}');
    if (res.statusCode == 201 || res.statusCode == 200) {
      return FavoriteModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Create favorite failed: ${res.statusCode} - ${res.body}');
  }

  Future<void> delete(int id) async {
    final uri = Uri.parse('$baseUrl/$id');
    debugPrint('[FavoriteService] DELETE $uri');
    final res = await http.delete(uri);
    debugPrint('[FavoriteService] DELETE status=${res.statusCode}');
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception(
        'Delete favorite failed: ${res.statusCode} - ${res.body}',
      );
    }
  }
}
