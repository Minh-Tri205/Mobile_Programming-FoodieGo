// lib/data/providers/review_provider.dart
import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository repository;
  ReviewProvider(this.repository);

  List<ReviewModel> reviews = [];
  bool isLoading = false;
  bool isSubmitting = false;
  String? error;

  // ==== Helpers ====
  List<ReviewModel> ofUser(int userId) =>
      reviews.where((r) => r.userId == userId).toList();

  List<ReviewModel> ofFood(int foodId) =>
      reviews.where((r) => r.foodId == foodId).toList();

  ReviewModel? ofOrder(int orderId) {
    final m = reviews.where((r) => r.orderId == orderId);
    return m.isEmpty ? null : m.first;
  }

  bool hasReviewedOrder(int orderId) =>
      reviews.any((r) => r.orderId == orderId);

  double avgRatingOfFood(int foodId) {
    final list = ofFood(foodId);
    if (list.isEmpty) return 0;
    final sum = list.fold<int>(0, (s, r) => s + r.rating);
    return sum / list.length;
  }

  // ==== Fetch ====
  Future<void> fetchAll() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();
      reviews = await repository.getAll();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==== Submit ====
  Future<ReviewModel?> submit(ReviewModel review) async {
    try {
      isSubmitting = true;
      error = null;
      notifyListeners();
      final created = await repository.create(review);
      reviews = [...reviews, created];
      return created;
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> remove(int reviewId) async {
    try {
      await repository.delete(reviewId);
      reviews.removeWhere((r) => r.reviewId == reviewId);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
