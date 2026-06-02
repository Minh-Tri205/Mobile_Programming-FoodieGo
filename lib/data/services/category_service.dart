import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/category_model.dart';


class CategoryService {
  static const String baseUrl = 'http://10.0.2.2:5187/api/Category';
  // GET ALL
  Future<List<CategoryModel>> getCategories() async {
    try {
      print("CALL API");

      final response = await http.get(Uri.parse(baseUrl));

      print("DONE API");

      print(response.statusCode);

      print(response.body);

      final List data = jsonDecode(response.body);

      return data.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      print("ERROR API");

      print(e);

      rethrow;
    }
  }

  // GET BY ID
  Future<CategoryModel> getCategoryById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return CategoryModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed');
    }
  }

  // POST
  Future<void> createCategory(CategoryModel category) async {
    final response = await http.post(
      Uri.parse(baseUrl),

      headers: {'Content-Type': 'application/json'},

      body: jsonEncode(category.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Create failed');
    }
  }

  // PATCH
  Future<void> updateCategory(int id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id'),

      headers: {'Content-Type': 'application/json'},

      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Update failed');
    }
  }

  // DELETE
  Future<void> deleteCategory(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Delete failed');
    }
  }
}
