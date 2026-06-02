// lib/data/services/voucher_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/voucher_model.dart';

class VoucherService {
  static const String baseUrl = 'http://10.0.2.2:5187/api/Voucher';

  Future<List<VoucherModel>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => VoucherModel.fromJson(e)).toList();
    }
    throw Exception('Fetch vouchers failed: ${res.statusCode}');
  }

  Future<VoucherModel> getById(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/$id'));
    if (res.statusCode == 200) {
      return VoucherModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Fetch voucher failed: ${res.statusCode}');
  }

  Future<VoucherModel> create(VoucherModel v) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(v.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return VoucherModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Create voucher failed: ${res.statusCode} - ${res.body}');
  }

  Future<VoucherModel> update(int id, VoucherModel v) async {
    final body = v.toJson();
    body['voucherId'] = id;
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) {
      return VoucherModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Update voucher failed: ${res.statusCode} - ${res.body}');
  }

  Future<void> patch(int id, Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Patch voucher failed: ${res.statusCode}');
    }
  }

  Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Delete voucher failed: ${res.statusCode}');
    }
  }
}
