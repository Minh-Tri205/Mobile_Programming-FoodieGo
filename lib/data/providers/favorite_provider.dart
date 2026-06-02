// lib/data/providers/favorite_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/favorite_model.dart';
import '../repositories/favorite_repository.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteRepository repository;
  FavoriteProvider(this.repository);

  List<FavoriteModel> favorites = [];
  bool isLoading = false;
  String? error;

  int? _lastUserId;

  // ==== Helpers ====
  bool isFavorite(int foodId) =>
      favorites.any((f) => f.foodId == foodId);

  int? favoriteIdOf(int foodId) {
    final match = favorites.where((f) => f.foodId == foodId);
    return match.isEmpty ? null : match.first.favoriteId;
  }

  List<FavoriteModel> ofUser(int userId) =>
      favorites.where((f) => f.userId == userId).toList();

  // ==== Fetch ====
  Future<void> fetchAll() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();
      favorites = await repository.getAll();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Load + cache theo user, không gọi lại nếu cùng user
  Future<void> ensureLoadedForUser(int userId) async {
    if (_lastUserId == userId && favorites.isNotEmpty) return;
    _lastUserId = userId;
    await fetchAll();
  }

  // ==== Toggle: add nếu chưa có, xoá nếu đã có ====
  // Trả về true = đã thêm vào yêu thích, false = đã bỏ.
  // Logic chắc chắn gọi DELETE /api/Favorite/{id} khi user đã có favorite.
  Future<bool> toggle(int userId, int foodId) async {
    final existing = favoriteIdOf(foodId);
    debugPrint(
      '[FavoriteProvider] toggle userId=$userId foodId=$foodId '
      'existingFavoriteId=$existing',
    );
    try {
      if (existing != null) {
        // ĐÃ THÍCH → gọi DELETE /api/Favorite/{favoriteId}
        debugPrint(
          '[FavoriteProvider] DELETE /api/Favorite/$existing (bỏ yêu thích)',
        );
        try {
          await repository.delete(existing);
        } catch (e) {
          // Nếu backend trả 404 (đã bị xoá ở nơi khác) → vẫn xem là xoá thành công
          // để sync state cục bộ. Lỗi khác mới rethrow.
          final msg = e.toString().toLowerCase();
          if (!msg.contains('404') && !msg.contains('not found')) rethrow;
          debugPrint(
            '[FavoriteProvider] DELETE trả 404 — coi như đã xoá, sync local',
          );
        }
        favorites.removeWhere((f) => f.favoriteId == existing);
        notifyListeners();
        return false; // đã bỏ thích
      } else {
        // CHƯA THÍCH → gọi POST /api/Favorite
        debugPrint(
          '[FavoriteProvider] POST /api/Favorite {userId:$userId, foodId:$foodId}',
        );
        try {
          final created = await repository.create(userId, foodId);
          favorites = [...favorites, created];
          debugPrint(
            '[FavoriteProvider] Đã thêm favoriteId=${created.favoriteId}',
          );
        } catch (e) {
          // Nếu backend báo "already added" → local đang stale, re-fetch để sync
          final msg = e.toString().toLowerCase();
          if (msg.contains('already')) {
            debugPrint(
              '[FavoriteProvider] Backend báo đã tồn tại — re-fetch để sync',
            );
            await fetchAll();
          } else {
            rethrow;
          }
        }
        notifyListeners();
        return true; // đã thích
      }
    } catch (e) {
      error = e.toString();
      debugPrint('[FavoriteProvider] toggle ERROR: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> remove(int favoriteId) async {
    try {
      await repository.delete(favoriteId);
      favorites.removeWhere((f) => f.favoriteId == favoriteId);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
