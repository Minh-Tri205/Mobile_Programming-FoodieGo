import 'food_model.dart';

class CartItemModel {
  final FoodModel food;
  int quantity;

  CartItemModel({
    required this.food,
    this.quantity = 1,
  });

  double get totalPrice => food.price * quantity;
}

class CartModel {
  List<CartItemModel> items;

  CartModel({List<CartItemModel>? items})
    : items = List.from(items ?? []);

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  double get deliveryFee => 15000;
  double get discount => 20000;
  double get total => subtotal + deliveryFee - discount;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  static CartModel sample() {
    return CartModel(
      items: [
        CartItemModel(food: FoodModel.sampleFoods[0], quantity: 2),
        CartItemModel(food: FoodModel.sampleFoods[1], quantity: 1),
      ],
    );
  }
}
