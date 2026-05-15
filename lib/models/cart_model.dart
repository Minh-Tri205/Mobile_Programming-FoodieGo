// lib/core/models/cart_model.dart
import 'food_model.dart';

class CartItemModel {
  final FoodModel food;
  int quantity;

  CartItemModel({required this.food, this.quantity = 1});

  double get totalPrice => food.price * quantity;
}

class CartModel {
  List<CartItemModel> items;
  double deliveryFee;
  double discountAmount; // từ voucher, mặc định 0

  CartModel({
    List<CartItemModel>? items,
    this.deliveryFee = 15000,
    this.discountAmount = 0,
  }) : items = List.from(items ?? []);

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  double get total => (subtotal + deliveryFee - discountAmount).clamp(0, double.infinity);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  // Áp voucher GIAM10K từ SQL: giảm 10k khi đơn >= 50k
  void applyVoucher(String code) {
    if (code == 'GIAM10K' && subtotal >= 50000) {
      discountAmount = 10000;
    }
  }

  void removeVoucher() {
    discountAmount = 0;
  }

  static CartModel sample() {
    return CartModel(
      items: [
        CartItemModel(food: FoodModel.sampleFoods[0], quantity: 2),
        CartItemModel(food: FoodModel.sampleFoods[2], quantity: 1),
      ],
      deliveryFee: 15000,
      discountAmount: 10000,
    );
  }
}