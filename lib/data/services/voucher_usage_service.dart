// lib/data/services/voucher_usage_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/voucher_usage_model.dart';

class VoucherUsageService {
  static const String baseUrl = 'http://10.0.2.2:5187/api/VoucherUsage';

  Future<List<VoucherUsageModel>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => VoucherUsageModel.fromJson(e)).toList();
    }
    throw Exception('Fetch voucher usages failed: ${res.statusCode}');
  }

  Future<VoucherUsageModel> getById(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/$id'));
    if (res.statusCode == 200) {
      return VoucherUsageModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Fetch voucher usage failed: ${res.statusCode}');
  }

  Future<List<VoucherUsageModel>> getByUser(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl/user/$userId'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => VoucherUsageModel.fromJson(e)).toList();
    }
    throw Exception('Fetch voucher usages of user failed: ${res.statusCode}');
  }

  Future<VoucherUsageModel> create(VoucherUsageModel u) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(u.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return VoucherUsageModel.fromJson(jsonDecode(res.body));
    }
    throw Exception(
        'Create voucher usage failed: ${res.statusCode} - ${res.body}');
  }

  Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Delete voucher usage failed: ${res.statusCode}');
    }
  }
}
