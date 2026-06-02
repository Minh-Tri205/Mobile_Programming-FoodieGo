// lib/models/cart_remote_model.dart
// Khớp class Cart (C#) trong API_Food_App.Models
//   public int CartId
//   public int? UserId
//   public virtual ICollection<CartItem> CartItems
//   public virtual User? User
//
// File này dành cho REMOTE cart (sync với /api/Cart endpoint).
// Cart local cho UI giỏ hàng vẫn dùng cart_model.dart riêng.
import 'food_model.dart';
import 'user_model.dart';

class CartItemRemoteModel {
  final int? cartItemId;
  final int cartId;
  final int foodId;
  final int quantity;
  final double unitPrice;
  final bool isSelected;

  // Nested khi backend .Include(Food)
  final FoodModel? food;

  const CartItemRemoteModel({
    this.cartItemId,
    required this.cartId,
    required this.foodId,
    this.quantity = 1,
    required this.unitPrice,
    this.isSelected = true,
    this.food,
  });

  double get subtotal => unitPrice * quantity;

  factory CartItemRemoteModel.fromJson(Map<String, dynamic> json) {
    final foodJson = json['food'] as Map<String, dynamic>?;

    // Backend SQL trả isSelected dạng BIT (0/1) → bool
    bool parseSel(dynamic v) {
      if (v == null) return true;
      if (v is bool) return v;
      if (v is num) return v != 0;
      return true;
    }

    return CartItemRemoteModel(
      cartItemId: json['cartItemId'],
      cartId: json['cartId'] ?? 0,
      foodId: json['foodId'] ?? foodJson?['foodId'] ?? 0,
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      isSelected: parseSel(json['isSelected']),
      food: foodJson != null ? FoodModel.fromJson(foodJson) : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Backend C# có CartItemId là int (non-null) → null sẽ fail JSON binding
    final map = <String, dynamic>{
      'cartId': cartId,
      'foodId': foodId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'isSelected': isSelected,
    };
    if (cartItemId != null) map['cartItemId'] = cartItemId;
    return map;
  }

  CartItemRemoteModel copyWith({
    int? cartItemId,
    int? cartId,
    int? foodId,
    int? quantity,
    double? unitPrice,
    bool? isSelected,
    FoodModel? food,
  }) {
    return CartItemRemoteModel(
      cartItemId: cartItemId ?? this.cartItemId,
      cartId: cartId ?? this.cartId,
      foodId: foodId ?? this.foodId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      isSelected: isSelected ?? this.isSelected,
      food: food ?? this.food,
    );
  }
}

class CartRemoteModel {
  final int? cartId;
  final int? userId;

  // Navigation properties — nested khi backend .Include
  final List<CartItemRemoteModel> cartItems;
  final UserModel? user;

  const CartRemoteModel({
    this.cartId,
    this.userId,
    this.cartItems = const [],
    this.user,
  });

  // Convenience getters
  int get itemCount =>
      cartItems.fold(0, (sum, it) => sum + it.quantity);

  int get selectedCount => cartItems.where((it) => it.isSelected).length;

  double get subtotalSelected => cartItems
      .where((it) => it.isSelected)
      .fold<double>(0, (s, it) => s + it.subtotal);

  double get subtotalAll =>
      cartItems.fold<double>(0, (s, it) => s + it.subtotal);

  factory CartRemoteModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['cartItems'] ?? json['items'];
    final userJson = json['user'] as Map<String, dynamic>?;
    return CartRemoteModel(
      cartId: json['cartId'],
      userId: json['userId'],
      cartItems: rawItems is List
          ? rawItems
                .map((e) =>
                    CartItemRemoteModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : const [],
      user: userJson != null ? UserModel.fromJson(userJson) : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Backend C# có CartId là int (non-null) → null sẽ fail JSON binding khi tạo mới
    final map = <String, dynamic>{
      'userId': userId,
      'cartItems': cartItems.map((e) => e.toJson()).toList(),
    };
    if (cartId != null) map['cartId'] = cartId;
    return map;
  }

  CartRemoteModel copyWith({
    int? cartId,
    int? userId,
    List<CartItemRemoteModel>? cartItems,
    UserModel? user,
  }) {
    return CartRemoteModel(
      cartId: cartId ?? this.cartId,
      userId: userId ?? this.userId,
      cartItems: cartItems ?? this.cartItems,
      user: user ?? this.user,
    );
  }
}
