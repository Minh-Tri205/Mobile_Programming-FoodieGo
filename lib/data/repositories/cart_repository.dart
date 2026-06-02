// lib/data/repositories/cart_repository.dart
import '../../models/cart_remote_model.dart';
import '../services/cart_service.dart';

class CartRepository {
  final CartService service;
  CartRepository(this.service);

  Future<List<CartRemoteModel>> getAll() => service.getAll();
  Future<CartRemoteModel?> getById(int id) => service.getById(id);
  Future<CartRemoteModel> create(int userId) => service.create(userId);
  Future<void> delete(int id) => service.delete(id);
}
