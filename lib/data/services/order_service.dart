import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/order_model.dart';

class OrderService {
  static const String baseUrl = 'http://10.0.2.2:5187/api/Order';

  // =========================
  // GET ALL
  // =========================
  Future<List<OrderModel>> getOrders() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => OrderModel.fromJson(e)).toList();
    } else {
      throw Exception('Fetch orders failed');
    }
  }

  // =========================
  // GET BY ID
  // =========================
  Future<OrderModel> getOrderById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return OrderModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fetch order failed');
    }
  }

  // =========================
  // GET BY USER ID
  // =========================
  Future<List<OrderModel>> getOrdersByUserId(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => OrderModel.fromJson(e)).toList();
    } else {
      throw Exception('Fetch orders failed');
    }
  }

  // =========================
  // GET BY USER ID + STATUS (server-side filter)
  // Endpoint backend: GET /api/Order/user/{userId}/status?status=shipping
  //   - status == null/rỗng → lấy tất cả (controller xử lý)
  //   - status có giá trị → WHERE status = @status (idx_orders_user_status)
  // =========================
  Future<List<OrderModel>> getOrdersByUserIdAndStatus(
    int userId,
    String? status,
  ) async {
    final query = (status == null || status.isEmpty)
        ? <String, String>{}
        : {'status': status};

    final uri = Uri.parse(
      '$baseUrl/user/$userId/status',
    ).replace(queryParameters: query.isEmpty ? null : query);

    debugPrint('[OrderService] GET $uri');
    final response = await http.get(uri);
    debugPrint(
      '[OrderService] status=${response.statusCode} '
      'bodyLen=${response.body.length}',
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => OrderModel.fromJson(e)).toList();
    } else {
      throw Exception('Fetch orders by status failed');
    }
  }

  // =========================
  // CREATE
  // =========================
  Future<OrderModel> createOrder(OrderModel order) async {
    final body = jsonEncode(order.toJson());
    debugPrint('[OrderService] POST $baseUrl');
    debugPrint('[OrderService] body: $body');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    debugPrint('[OrderService] status=${response.statusCode}');
    debugPrint('[OrderService] response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Backend tra ve order vua tao (kem orderId)
      return OrderModel.fromJson(jsonDecode(response.body));
    }
    throw Exception(
      'Create order failed: ${response.statusCode} - ${response.body}',
    );
  }

  // =========================
  // PATCH
  // =========================
  Future<void> updateOrder(int id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Update order failed');
    }
  }

  // =========================
  // DELETE
  // =========================
  Future<void> deleteOrder(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Delete order failed');
    }
  }

  // =========================
  // CHANGE STATUS
  // =========================
  Future<void> changeStatus(int id, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/change-status/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(status),
    );

    if (response.statusCode != 200) {
      throw Exception('Change status failed');
    }
  }

  // =========================
  // CONFIRM
  // =========================
  Future<void> confirmOrder(int id) async {
    final response = await http.patch(Uri.parse('$baseUrl/confirm/$id'));

    if (response.statusCode != 200) {
      throw Exception('Confirm order failed');
    }
  }

  // =========================
  // PREPARING
  // =========================
  Future<void> preparingOrder(int id) async {
    final response = await http.patch(Uri.parse('$baseUrl/preparing/$id'));

    if (response.statusCode != 200) {
      throw Exception('Preparing order failed');
    }
  }

  // =========================
  // SHIPPING
  // =========================
  Future<void> shippingOrder(int id) async {
    final response = await http.patch(Uri.parse('$baseUrl/shipping/$id'));

    if (response.statusCode != 200) {
      throw Exception('Shipping order failed');
    }
  }

  // =========================
  // COMPLETE
  // =========================
  Future<void> completeOrder(int id) async {
    final response = await http.patch(Uri.parse('$baseUrl/complete/$id'));

    if (response.statusCode != 200) {
      throw Exception('Complete order failed');
    }
  }

  // =========================
  // CANCEL
  // =========================
  Future<void> cancelOrder(int id) async {
    final response = await http.patch(Uri.parse('$baseUrl/cancel/$id'));

    if (response.statusCode != 200) {
      throw Exception('Cancel order failed');
    }
  }
}
