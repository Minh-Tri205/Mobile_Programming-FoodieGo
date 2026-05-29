// lib/data/services/food_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/food_model.dart';

class FoodService {
  static const String baseUrl = 'http://10.0.2.2:5187/api/FoodItem';

  // GET ALL
  Future<List<FoodModel>> getFoods() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => FoodModel.fromJson(e)).toList();
    } else {
      throw Exception('Fetch foods failed: ${response.statusCode}');
    }
  }

  // GET BY ID
  Future<FoodModel> getFoodById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return FoodModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fetch food failed: ${response.statusCode}');
    }
  }

  // CREATE
  Future<FoodModel> createFood(FoodModel food) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(food.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return FoodModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Create food failed: ${response.statusCode}');
    }
  }

  // PUT — replace toàn bộ
  Future<FoodModel> updateFood(int id, FoodModel food) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(food.toJson()),
    );
    if (response.statusCode == 200) {
      return FoodModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Update food failed: ${response.statusCode}');
    }
  }

  // PATCH — chỉ field có giá trị
  Future<FoodModel> patchFood(int id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return FoodModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Patch food failed: ${response.statusCode}');
    }
  }

  // DELETE
  Future<void> deleteFood(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Delete food failed: ${response.statusCode}');
    }
  }

  // SEARCH client-side (vì controller chưa có endpoint search)
  Future<List<FoodModel>> searchFoods(String query) async {
    final all = await getFoods();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((f) {
      return f.name.toLowerCase().contains(q) ||
          (f.description?.toLowerCase().contains(q) ?? false) ||
          f.categoryName.toLowerCase().contains(q);
    }).toList();
  }
}
