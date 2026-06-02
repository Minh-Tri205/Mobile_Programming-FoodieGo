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
    final rawImage = json['foodImageUrl'] ?? food?['imageUrl'];
    return OrderItemModel(
      orderItemId: json['orderItemId'],
      orderId: json['orderId'],
      foodId: json['foodId'] ?? food?['foodId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      foodName: json['foodName'] ?? food?['name'] ?? '',
      foodImageUrl: _resolveFoodImageUrl(rawImage),
    );
  }

  // food.ImageUrl tu Order endpoint la filename thuan (vd: "abc.jpg")
  // -> prepend base URL de Flutter Image.network load duoc
  static String? _resolveFoodImageUrl(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    if (s.startsWith('assets/')) return s;
    return 'http://10.0.2.2:5187/Uploads/FoodItems/$s';
  }

  Map<String, dynamic> toJson() {
    // Backend C# co OrderItemId va OrderId la int (non-null PK/FK)
    // -> chi gui khi co gia tri thuc te (UPDATE), bo qua khi CREATE
    final map = <String, dynamic>{
      'foodId': foodId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'foodName': foodName,
      'foodImageUrl': foodImageUrl,
    };
    if (orderItemId != null) map['orderItemId'] = orderItemId;
    if (orderId != null) map['orderId'] = orderId;
    return map;
  }
}
