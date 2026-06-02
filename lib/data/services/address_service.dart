// lib/data/services/address_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/address_model.dart';

class AddressService {
  static const String baseUrl = 'http://10.0.2.2:5187/api/Address';

  Future<List<AddressModel>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => AddressModel.fromJson(e)).toList();
    }
    throw Exception('Fetch addresses failed: ${res.statusCode}');
  }

  Future<AddressModel> getById(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/$id'));
    if (res.statusCode == 200) {
      return AddressModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Fetch address failed: ${res.statusCode}');
  }

  Future<List<AddressModel>> getByUser(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl/user/$userId'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => AddressModel.fromJson(e)).toList();
    }
    throw Exception('Fetch addresses of user failed: ${res.statusCode}');
  }

  Future<AddressModel> create(AddressModel address) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(address.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return AddressModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Create address failed: ${res.statusCode} - ${res.body}');
  }

  Future<void> update(int id, AddressModel address) async {
    final body = address.toJson();
    body['addressId'] = id;
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Update address failed: ${res.statusCode} - ${res.body}');
    }
  }

  Future<void> patch(int id, Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Patch address failed: ${res.statusCode}');
    }
  }

  Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Delete address failed: ${res.statusCode}');
    }
  }
}
