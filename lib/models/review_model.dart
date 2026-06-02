import 'food_model.dart';
import 'order_model.dart';
import 'user_model.dart';

class ReviewModel {
  final int? reviewId;
  final int orderId;
  final int userId;
  final int? foodId;
  final int rating; // 1..5
  final String? comment;
  final DateTime? createdAt;

  // Navigation properties — nested khi backend .Include
  final FoodModel? food;
  final OrderModel? order;
  final UserModel? user;

  const ReviewModel({
    this.reviewId,
    required this.orderId,
    required this.userId,
    this.foodId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.food,
    this.order,
    this.user,
  });

  // Convenience getters cho UI — không cần truy cập nested manually
  String get userName => user?.fullName ?? '';
  String? get userAvatarUrl => user?.avatarUrl;
  String get foodName => food?.name ?? '';
  String? get foodImageUrl => food?.imageUrl;
  String get orderCode => order?.orderCode ?? '';

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final foodJson = json['food'] as Map<String, dynamic>?;
    final orderJson = json['order'] as Map<String, dynamic>?;
    final userJson = json['user'] as Map<String, dynamic>?;
    return ReviewModel(
      reviewId: json['reviewId'],
      orderId: json['orderId'] ?? orderJson?['orderId'] ?? 0,
      userId: json['userId'] ?? userJson?['userId'] ?? 0,
      foodId: json['foodId'] ?? foodJson?['foodId'],
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      food: foodJson != null ? FoodModel.fromJson(foodJson) : null,
      order: orderJson != null ? OrderModel.fromJson(orderJson) : null,
      user: userJson != null ? UserModel.fromJson(userJson) : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Backend C# có ReviewId là int (non-null) → gửi null sẽ fail JSON binding
    // Chỉ include reviewId/createdAt khi đã có giá trị (tức là UPDATE, không phải CREATE)
    final map = <String, dynamic>{
      'orderId': orderId,
      'userId': userId,
      'foodId': foodId,
      'rating': rating,
      'comment': comment,
    };
    if (reviewId != null) map['reviewId'] = reviewId;
    if (createdAt != null) map['createdAt'] = createdAt!.toIso8601String();
    return map;
  }

  ReviewModel copyWith({
    int? reviewId,
    int? orderId,
    int? userId,
    int? foodId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    FoodModel? food,
    OrderModel? order,
    UserModel? user,
  }) {
    return ReviewModel(
      reviewId: reviewId ?? this.reviewId,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      foodId: foodId ?? this.foodId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      food: food ?? this.food,
      order: order ?? this.order,
      user: user ?? this.user,
    );
  }
}
