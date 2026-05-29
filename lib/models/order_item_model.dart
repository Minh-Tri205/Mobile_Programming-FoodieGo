// lib/models/order_item_model.dart
// Khớp bảng order_items trong Database_Food_App.sql
// Các trường foodName, foodImageUrl được lấy qua JOIN với food_items
// để phục vụ hiển thị UI (chi tiết đơn, theo dõi đơn, ...).
class OrderItemModel {
  final int? orderItemId;
  final int? orderId;
  final int foodId;
  final int quantity;
  final double unitPrice;

  // Lấy từ JOIN food_items — phục vụ UI
  final String foodName;
  final String? foodImageUrl;

  const OrderItemModel({
    this.orderItemId,
    this.orderId,
    required this.foodId,
    required this.quantity,
    required this.unitPrice,
    required this.foodName,
    this.foodImageUrl,
  });

  double get subtotal => quantity * unitPrice;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Backend EF Core trả về nested object qua .Include(Food):
    //   { orderItemId, foodId, quantity, unitPrice, food: { name, imageUrl, ... } }
    // Cũng hỗ trợ dạng flat (foodName/foodImageUrl) cho tương thích.
    final food = json['food'] as Map<String, dynamic>?;
    return OrderItemModel(
      orderItemId: json['orderItemId'],
      orderId: json['orderId'],
      foodId: json['foodId'] ?? food?['foodId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      foodName: json['foodName'] ?? food?['name'] ?? '',
      foodImageUrl: json['foodImageUrl'] ?? food?['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'orderItemId': orderItemId,
    'orderId': orderId,
    'foodId': foodId,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'foodName': foodName,
    'foodImageUrl': foodImageUrl,
  };
}
