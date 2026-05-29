// lib/data/providers/food_provider.dart
import 'package:flutter/material.dart';

import '../../models/food_model.dart';
import '../repositories/food_repository.dart';

class FoodProvider extends ChangeNotifier {
  final FoodRepository repository;

  FoodProvider(this.repository);

  // ==== STATE ====
  List<FoodModel> foods = [];
  List<FoodModel> searchResults = [];

  FoodModel? selectedFood;

  bool isLoading = false;
  bool isSearching = false;
  bool isLoadingDetail = false;

  String? error;

  // Filter / sort UI state
  int? selectedCategoryId; // null = tất cả
  String _query = '';
  String get query => _query;

  // ==== HELPERS ====

  // Toàn bộ món (admin xem được, kể cả món đã ẩn)
  List<FoodModel> get visibleFoods {
    var list = foods;
    if (selectedCategoryId != null) {
      list = list.where((f) => f.categoryId == selectedCategoryId).toList();
    }
    return list;
  }

  // Chỉ món đang hoạt động — dùng cho trang user-facing (home/search/detail)
  List<FoodModel> get activeFoods =>
      foods.where((f) => f.isActive).toList();

  // Cho home: active + filter theo category
  List<FoodModel> get publicVisibleFoods {
    var list = activeFoods;
    if (selectedCategoryId != null) {
      list = list.where((f) => f.categoryId == selectedCategoryId).toList();
    }
    return list;
  }

  // Top phổ biến (chỉ lấy từ activeFoods)
  List<FoodModel> topPopular({int limit = 6}) {
    final sorted = [...activeFoods]
      ..sort((a, b) => b.totalSold.compareTo(a.totalSold));
    return sorted.take(limit).toList();
  }

  // Top rated (chỉ lấy từ activeFoods)
  List<FoodModel> topRated({int limit = 6}) {
    final sorted = [...activeFoods]
      ..sort((a, b) => b.avgRating.compareTo(a.avgRating));
    return sorted.take(limit).toList();
  }

  // ==== FETCH LIST ====
  Future<void> fetchFoods() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      foods = await repository.getFoods();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==== FETCH DETAIL ====
  Future<void> fetchFoodById(int id) async {
    try {
      isLoadingDetail = true;
      selectedFood = null;
      error = null;
      notifyListeners();

      selectedFood = await repository.getFoodById(id);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoadingDetail = false;
      notifyListeners();
    }
  }

  void setSelectedFood(FoodModel food) {
    selectedFood = food;
    notifyListeners();
  }

  // ==== SEARCH ====
  Future<void> search(String query) async {
    _query = query;
    try {
      isSearching = true;
      notifyListeners();

      if (query.trim().isEmpty) {
        searchResults = [];
      } else {
        final raw = await repository.searchFoods(query);
        // Trang user-facing chỉ thấy món còn hoạt động
        searchResults = raw.where((f) => f.isActive).toList();
      }
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _query = '';
    searchResults = [];
    notifyListeners();
  }

  // ==== CATEGORY FILTER ====
  void selectCategory(int? categoryId) {
    selectedCategoryId = categoryId;
    notifyListeners();
  }

  // ==== ADMIN ACTIONS ====
  Future<void> createFood(FoodModel food) async {
    try {
      final created = await repository.createFood(food);
      foods = [...foods, created];
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateFood(int id, FoodModel food) async {
    try {
      final updated = await repository.updateFood(id, food);
      final idx = foods.indexWhere((f) => f.foodId == id);
      if (idx != -1) {
        foods[idx] = updated;
      }
      if (selectedFood?.foodId == id) selectedFood = updated;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> patchFood(int id, Map<String, dynamic> data) async {
    try {
      final patched = await repository.patchFood(id, data);
      final idx = foods.indexWhere((f) => f.foodId == id);
      if (idx != -1) {
        foods[idx] = patched;
      }
      if (selectedFood?.foodId == id) selectedFood = patched;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteFood(int id) async {
    try {
      await repository.deleteFood(id);
      foods.removeWhere((f) => f.foodId == id);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
