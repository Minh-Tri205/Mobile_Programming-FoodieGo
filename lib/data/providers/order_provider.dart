import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository repository;

  OrderProvider(this.repository);

  List<OrderModel> orders = [];

  // Đơn hàng đang xem chi tiết
  OrderModel? selectedOrder;

  bool isLoading = false;

  String? error;

  // =========================
  // GET ALL
  // =========================
  Future<void> fetchOrders() async {
    try {
      isLoading = true;

      notifyListeners();

      orders = await repository.getOrders();

      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  // =========================
  // GET BY ID — load chi tiết một đơn vào selectedOrder
  // =========================
  Future<void> getOrderById(int id) async {
    try {
      isLoading = true;
      selectedOrder = null;
      notifyListeners();

      selectedOrder = await repository.getOrderById(id);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // GET BY USER ID
  // =========================
  Future<void> fetchOrdersByUserId(int userId) async {
    try {
      isLoading = true;

      notifyListeners();

      orders = await repository.getOrdersByUserId(userId);

      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  // =========================
  // GET BY USER ID + STATUS (server-side filter)
  // status == null hoặc rỗng → lấy tất cả
  // =========================
  Future<void> fetchOrdersByUserIdAndStatus(int userId, String? status) async {
    try {
      isLoading = true;
      orders = []; // Clear list cũ để Consumer rebuild rõ ràng
      error = null;
      notifyListeners();

      final result = await repository.getOrdersByUserIdAndStatus(
        userId,
        status,
      );
      debugPrint(
        '[OrderProvider] fetchOrdersByUserIdAndStatus '
        'userId=$userId status=$status → ${result.length} orders',
      );

      orders = result;
    } catch (e) {
      error = e.toString();
      debugPrint('[OrderProvider] error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // CREATE
  // =========================
  Future<void> createOrder(OrderModel order) async {
    try {
      await repository.createOrder(order);

      await fetchOrders();
    } catch (e) {
      error = e.toString();

      notifyListeners();
    }
  }

  // =========================
  // UPDATE
  // =========================
  Future<void> updateOrder(int id, Map<String, dynamic> data) async {
    try {
      await repository.updateOrder(id, data);

      await fetchOrders();
    } catch (e) {
      error = e.toString();

      notifyListeners();
    }
  }

  // =========================
  // DELETE
  // =========================
  Future<void> deleteOrder(int id) async {
    try {
      await repository.deleteOrder(id);

      orders.removeWhere((e) => e.orderId == id);

      notifyListeners();
    } catch (e) {
      error = e.toString();

      notifyListeners();
    }
  }

  // =========================
  // CONFIRM
  // =========================
  Future<void> confirmOrder(int id) async {
    try {
      await repository.confirmOrder(id);

      await fetchOrders();
    } catch (e) {
      error = e.toString();

      notifyListeners();
    }
  }

  // =========================
  // PREPARING
  // =========================
  Future<void> preparingOrder(int id) async {
    try {
      await repository.preparingOrder(id);

      await fetchOrders();
    } catch (e) {
      error = e.toString();

      notifyListeners();
    }
  }

  // =========================
  // SHIPPING
  // =========================
  Future<void> shippingOrder(int id) async {
    try {
      await repository.shippingOrder(id);

      await fetchOrders();
    } catch (e) {
      error = e.toString();

      notifyListeners();
    }
  }

  // =========================
  // COMPLETE
  // =========================
  Future<void> completeOrder(int id) async {
    try {
      await repository.completeOrder(id);

      await fetchOrders();
    } catch (e) {
      error = e.toString();

      notifyListeners();
    }
  }

  // =========================
  // CANCEL
  // =========================
  Future<void> cancelOrder(int id) async {
    try {
      await repository.cancelOrder(id);

      await fetchOrders();
    } catch (e) {
      error = e.toString();

      notifyListeners();
    }
  }
}
