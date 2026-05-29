import '../../models/order_model.dart';
import '../services/order_service.dart';

class OrderRepository {
  final OrderService service;

  OrderRepository(this.service);

  Future<List<OrderModel>> getOrders() {
    return service.getOrders();
  }

  Future<OrderModel> getOrderById(int id) {
    return service.getOrderById(id);
  }

  Future<List<OrderModel>> getOrdersByUserId(int userId) {
    return service.getOrdersByUserId(userId);
  }

  Future<List<OrderModel>> getOrdersByUserIdAndStatus(
    int userId,
    String? status,
  ) {
    return service.getOrdersByUserIdAndStatus(userId, status);
  }

  Future<void> createOrder(OrderModel order) {
    return service.createOrder(order);
  }

  Future<void> updateOrder(int id, Map<String, dynamic> data) {
    return service.updateOrder(id, data);
  }

  Future<void> deleteOrder(int id) {
    return service.deleteOrder(id);
  }

  Future<void> changeStatus(int id, String status) {
    return service.changeStatus(id, status);
  }

  Future<void> confirmOrder(int id) {
    return service.confirmOrder(id);
  }

  Future<void> preparingOrder(int id) {
    return service.preparingOrder(id);
  }

  Future<void> shippingOrder(int id) {
    return service.shippingOrder(id);
  }

  Future<void> completeOrder(int id) {
    return service.completeOrder(id);
  }

  Future<void> cancelOrder(int id) {
    return service.cancelOrder(id);
  }
}
