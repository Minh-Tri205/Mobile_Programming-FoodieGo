// lib/data/services/cart_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/cart_remote_model.dart';

class CartService {
  static const String baseUrl = 'http://10.0.2.2:5187/api/Cart';

  Future<List<CartRemoteModel>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => CartRemoteModel.fromJson(e)).toList();
    }
    throw Exception('Fetch carts failed: ${res.statusCode}');
  }

  Future<CartRemoteModel?> getById(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/$id'));
    if (res.statusCode == 200) {
      return CartRemoteModel.fromJson(jsonDecode(res.body));
    }
    if (res.statusCode == 404) return null;
    throw Exception('Fetch cart failed: ${res.statusCode}');
  }

  Future<CartRemoteModel> create(int userId) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return CartRemoteModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Create cart failed: ${res.statusCode}');
  }

  Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Delete cart failed: ${res.statusCode}');
    }
  }
}
