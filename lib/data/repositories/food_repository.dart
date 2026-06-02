// lib/data/repositories/food_repository.dart
import '../../models/food_model.dart';
import '../services/food_service.dart';

class FoodRepository {
  final FoodService service;

  FoodRepository(this.service);

  Future<List<FoodModel>> getFoods() => service.getFoods();

  Future<FoodModel> getFoodById(int id) => service.getFoodById(id);

  Future<FoodModel> createFood(
    FoodModel food, {
    String? localFilePath,
  }) =>
      service.createFood(food, localFilePath: localFilePath);

  Future<FoodModel> updateFood(
    int id,
    FoodModel food, {
    String? localFilePath,
  }) =>
      service.updateFood(id, food, localFilePath: localFilePath);

  Future<FoodModel> patchFood(int id, Map<String, dynamic> data) =>
      service.patchFood(id, data);

  Future<void> deleteFood(int id) => service.deleteFood(id);

  Future<List<FoodModel>> searchFoods(String query) =>
      service.searchFoods(query);
}
