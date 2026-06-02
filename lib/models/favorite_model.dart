import 'food_model.dart';
import 'user_model.dart';
import 'package:flutter/foundation.dart';
class FavoriteModel {
  final int? favoriteId;
  final int userId;
  final int foodId;
  final DateTime? createdAt;

  // Navigation properties — nested khi backend .Include
  final FoodModel? food;
  final UserModel? user;

  const FavoriteModel({
    this.favoriteId,
    required this.userId,
    required this.foodId,
    this.createdAt,
    this.food,
    this.user,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    final foodJson = json['food'] as Map<String, dynamic>?;
    final userJson = json['user'] as Map<String, dynamic>?;
    return FavoriteModel(
      favoriteId: json['favoriteId'],
      userId: json['userId'] ?? userJson?['userId'] ?? 0,
      foodId: json['foodId'] ?? foodJson?['foodId'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      food: foodJson != null ? FoodModel.fromJson(foodJson) : null,
      user: userJson != null ? UserModel.fromJson(userJson) : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Backend C# có FavoriteId là int (non-null) → null sẽ fail JSON binding
    final map = <String, dynamic>{
      'userId': userId,
      'foodId': foodId,
    };
    if (favoriteId != null) map['favoriteId'] = favoriteId;
    if (createdAt != null) map['createdAt'] = createdAt!.toIso8601String();
    return map;
  }

  FavoriteModel copyWith({
    int? favoriteId,
    int? userId,
    int? foodId,
    DateTime? createdAt,
    FoodModel? food,
    UserModel? user,
  }) {
    return FavoriteModel(
      favoriteId: favoriteId ?? this.favoriteId,
      userId: userId ?? this.userId,
      foodId: foodId ?? this.foodId,
      createdAt: createdAt ?? this.createdAt,
      food: food ?? this.food,
      user: user ?? this.user,
    );
  }
}
