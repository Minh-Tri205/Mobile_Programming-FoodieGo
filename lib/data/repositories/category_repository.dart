import '../../models/category_model.dart';
import '../services/category_service.dart';

class CategoryRepository {
  final CategoryService service;

  CategoryRepository(this.service);

  Future<List<CategoryModel>> getCategories() {
    return service.getCategories();
  }

  Future<CategoryModel> getCategoryById(int id) {
    return service.getCategoryById(id);
  }

  Future<void> createCategory(CategoryModel category) {
    return service.createCategory(category);
  }

  Future<void> updateCategory(int id, Map<String, dynamic> data) {
    return service.updateCategory(id, data);
  }

  Future<void> deleteCategory(int id) {
    return service.deleteCategory(id);
  }
}
