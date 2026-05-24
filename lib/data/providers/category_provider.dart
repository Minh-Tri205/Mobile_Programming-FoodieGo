import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository repository;

  CategoryProvider(this.repository);

  List<CategoryModel> categories = [];

  bool isLoading = false;

  String? error;

  // GET ALL
  Future<void> fetchCategories() async {
    try {
      isLoading = true;
      notifyListeners();
      categories = await repository.getCategories();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  // CREATE
  Future<void> createCategory(CategoryModel category) async {
    await repository.createCategory(category);

    await fetchCategories();
  }

  // UPDATE
Future<void> updateCategory(int id, Map<String, dynamic> data) async {
    await repository.updateCategory(id, data);

    final index = categories.indexWhere((e) => e.categoryId == id);

    if (index != -1) {
      final oldCategory = categories[index];

      categories[index] = CategoryModel(
        categoryId: oldCategory.categoryId,

        name: data['name'] ?? oldCategory.name,

        imageUrl: data['imageUrl'] ?? oldCategory.imageUrl,

        isActive: data['isActive'] ?? oldCategory.isActive,
      );

      notifyListeners();
    }
  }

  // DELETE
Future<void> deleteCategory(int id) async {
    try {
      await repository.deleteCategory(id);

      categories = categories.where((e) => e.categoryId != id).toList();

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

}
