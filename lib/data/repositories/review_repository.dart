// lib/data/repositories/review_repository.dart
import '../../models/review_model.dart';
import '../services/review_service.dart';

class ReviewRepository {
  final ReviewService service;
  ReviewRepository(this.service);

  Future<List<ReviewModel>> getAll() => service.getAll();
  Future<ReviewModel> getById(int id) => service.getById(id);
  Future<ReviewModel> create(ReviewModel review) => service.create(review);
  Future<ReviewModel> update(int id, ReviewModel review) =>
      service.update(id, review);
  Future<void> delete(int id) => service.delete(id);
}
