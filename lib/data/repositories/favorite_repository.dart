// lib/data/repositories/favorite_repository.dart
import '../../models/favorite_model.dart';
import '../services/favorite_service.dart';

class FavoriteRepository {
  final FavoriteService service;
  FavoriteRepository(this.service);

  Future<List<FavoriteModel>> getAll() => service.getAll();
  Future<FavoriteModel> getById(int id) => service.getById(id);
  Future<FavoriteModel> create(int userId, int foodId) =>
      service.create(userId, foodId);
  Future<void> delete(int id) => service.delete(id);
}
