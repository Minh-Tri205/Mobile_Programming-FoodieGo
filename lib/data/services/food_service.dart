// lib/data/services/food_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
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

  // CREATE — multipart, ho tro file upload hoac imageUrl
  // Backend: [FromForm] FoodItem food, IFormFile? file
  Future<FoodModel> createFood(
    FoodModel food, {
    String? localFilePath,
  }) async {
    final uri = Uri.parse(baseUrl);
    final req = http.MultipartRequest('POST', uri);

    req.fields.addAll(_foodFields(food, includeFoodId: false));

    if (localFilePath != null && localFilePath.isNotEmpty) {
      final f = File(localFilePath);
      if (!await f.exists()) {
        throw Exception('File anh khong ton tai: $localFilePath');
      }
      req.files.add(await http.MultipartFile.fromPath('file', localFilePath));
    }

    debugPrint('[FoodService] POST $uri fields=${req.fields}');
    final streamed = await req.send();
    final response = await http.Response.fromStream(streamed);
    debugPrint('[FoodService] status=${response.statusCode} body=${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      // Backend tra: { message, food: {...} }
      final foodJson = data is Map<String, dynamic> && data['food'] != null
          ? data['food']
          : data;
      return FoodModel.fromJson(foodJson);
    }
    throw Exception(
      'Create food failed: ${response.statusCode} - ${response.body}',
    );
  }

  // PUT — replace, ho tro file upload hoac imageUrl
  // Backend: [FromForm] FoodItem dto, IFormFile? file
  Future<FoodModel> updateFood(
    int id,
    FoodModel food, {
    String? localFilePath,
  }) async {
    final uri = Uri.parse('$baseUrl/$id');
    final req = http.MultipartRequest('PUT', uri);

    req.fields.addAll(_foodFields(food, includeFoodId: true));

    if (localFilePath != null && localFilePath.isNotEmpty) {
      final f = File(localFilePath);
      if (!await f.exists()) {
        throw Exception('File anh khong ton tai: $localFilePath');
      }
      req.files.add(await http.MultipartFile.fromPath('file', localFilePath));
    }

    debugPrint('[FoodService] PUT $uri fields=${req.fields}');
    final streamed = await req.send();
    final response = await http.Response.fromStream(streamed);
    debugPrint('[FoodService] status=${response.statusCode} body=${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final foodJson = data is Map<String, dynamic> && data['food'] != null
          ? data['food']
          : data;
      return FoodModel.fromJson(foodJson);
    }
    throw Exception(
      'Update food failed: ${response.statusCode} - ${response.body}',
    );
  }

  // Build form fields tu FoodModel — tat ca value la string
  Map<String, String> _foodFields(
    FoodModel f, {
    required bool includeFoodId,
  }) {
    final m = <String, String>{
      'name': f.name,
      'price': f.price.toString(),
      'totalSold': f.totalSold.toString(),
      'stockQuantity': f.stockQuantity.toString(),
      'avgRating': f.avgRating.toString(),
      'isActive': f.isActive.toString(),
    };
    if (f.categoryId != null) m['categoryId'] = f.categoryId.toString();
    if (f.description != null && f.description!.isNotEmpty) {
      m['description'] = f.description!;
    }
    if (f.imageUrl != null && f.imageUrl!.isNotEmpty) {
      m['imageUrl'] = f.imageUrl!;
    }
    if (includeFoodId && f.foodId != null) {
      m['foodId'] = f.foodId.toString();
    }
    return m;
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
