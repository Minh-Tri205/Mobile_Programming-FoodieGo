// lib/data/services/review_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/review_model.dart';

class ReviewService {
  static const String baseUrl = 'http://10.0.2.2:5187/api/Review';

  Future<List<ReviewModel>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ReviewModel.fromJson(e)).toList();
    }
    throw Exception('Fetch reviews failed: ${res.statusCode}');
  }

  Future<ReviewModel> getById(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/$id'));
    if (res.statusCode == 200) {
      return ReviewModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Fetch review failed: ${res.statusCode}');
  }

  Future<ReviewModel> create(ReviewModel review) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(review.toJson()),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return ReviewModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Create review failed: ${res.statusCode} - ${res.body}');
  }

  Future<ReviewModel> update(int id, ReviewModel review) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(review.toJson()),
    );
    if (res.statusCode == 200) return ReviewModel.fromJson(jsonDecode(res.body));
    throw Exception('Update review failed: ${res.statusCode}');
  }

  Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Delete review failed: ${res.statusCode}');
    }
  }
}
