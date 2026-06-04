// lib/data/providers/cart_provider.dart
// Provider phụ trách:
//  - Local cart items (thêm/xoá/sửa số lượng/chọn) — vì backend chưa có
//    endpoint CartItem riêng để CRUD từng món
//  - Remote cart_id sync với backend Cart endpoint (đảm bảo user có cart row)
import 'package:flutter/material.dart';
import '../../models/cart_model.dart';
import '../../models/food_model.dart';
import '../../models/voucher_model.dart';
import '../repositories/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository repository;
  CartProvider(this.repository);

  // ==== REMOTE ====
  int? cartId;
  bool isLoading = false;
  String? error;

  // ==== LOCAL ITEMS ====
  final List<CartItemModel> _items = [];
  final Set<int> _selectedFoodIds = {}; // theo foodId
  double deliveryFee = 15000;
  double discountAmount = 0;
  String? appliedVoucherCode;
  int? appliedVoucherId; // Theo doi voucher API duoc ap dung de tao VoucherUsage

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get totalQty => _items.fold(0, (s, it) => s + it.quantity);
  bool isSelected(int foodId) => _selectedFoodIds.contains(foodId);

  List<CartItemModel> get selectedItems => _items
      .where((it) => it.food.foodId != null && isSelected(it.food.foodId!))
      .toList();

  double get subtotal =>
      selectedItems.fold(0, (s, it) => s + it.totalPrice);
  double get total =>
      (subtotal + deliveryFee - discountAmount).clamp(0, double.infinity);

  // ==== ADD / REMOVE / UPDATE ====
  void addItem(FoodModel food, {int quantity = 1}) {
    if (food.foodId == null) return;
    final idx = _items.indexWhere((it) => it.food.foodId == food.foodId);
    if (idx >= 0) {
      _items[idx].quantity += quantity;
    } else {
      _items.add(CartItemModel(food: food, quantity: quantity));
      _selectedFoodIds.add(food.foodId!); // mới thêm thì mặc định chọn
    }
    notifyListeners();
  }

  void removeItem(int foodId) {
    _items.removeWhere((it) => it.food.foodId == foodId);
    _selectedFoodIds.remove(foodId);
    notifyListeners();
  }

  void updateQty(int foodId, int newQty) {
    final idx = _items.indexWhere((it) => it.food.foodId == foodId);
    if (idx < 0) return;
    if (newQty <= 0) {
      removeItem(foodId);
      return;
    }
    _items[idx].quantity = newQty;
    notifyListeners();
  }

  void toggleSelect(int foodId) {
    if (_selectedFoodIds.contains(foodId)) {
      _selectedFoodIds.remove(foodId);
    } else {
      _selectedFoodIds.add(foodId);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedFoodIds
      ..clear()
      ..addAll(_items.map((it) => it.food.foodId).whereType<int>());
    notifyListeners();
  }

  void unselectAll() {
    _selectedFoodIds.clear();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _selectedFoodIds.clear();
    discountAmount = 0;
    appliedVoucherCode = null;
    appliedVoucherId = null;
    notifyListeners();
  }

  // ==== VOUCHER (đơn giản, sau này gắn vào API voucher) ====
  bool applyVoucher(String code) {
    final c = code.trim().toUpperCase();
    // Tạm hardcode 3 mã từ DB sample
    switch (c) {
      case 'GIAM10K':
        if (subtotal >= 50000) {
          discountAmount = 10000;
          appliedVoucherCode = c;
          notifyListeners();
          return true;
        }
        break;
      case 'GIAM20K':
        if (subtotal >= 100000) {
          discountAmount = 20000;
          appliedVoucherCode = c;
          notifyListeners();
          return true;
        }
        break;
      case 'FREESHIP':
        if (subtotal >= 30000) {
          discountAmount = deliveryFee;
          appliedVoucherCode = c;
          notifyListeners();
          return true;
        }
        break;
    }
    return false;
  }

  void removeVoucher() {
    discountAmount = 0;
    appliedVoucherCode = null;
    appliedVoucherId = null;
    notifyListeners();
  }

  // Ap dung voucher tu API (admin tao). Tra ve null neu thanh cong,
  // hoac chuoi ly do neu khong du dieu kien.
  // usedVoucherIds: id cac voucher user nay da dung — chan tai dung.
  String? applyVoucherModel(
    VoucherModel v, {
    Set<int> usedVoucherIds = const {},
  }) {
    if (v.voucherId == null) return 'Voucher không hợp lệ';
    if (v.isActive != true) return 'Voucher đã bị tắt';
    if (usedVoucherIds.contains(v.voucherId)) {
      return 'Bạn đã dùng voucher này rồi';
    }
    final now = DateTime.now();
    if (v.startDate != null && v.startDate!.isAfter(now)) {
      return 'Voucher chưa đến ngày áp dụng';
    }
    if (v.endDate != null && v.endDate!.isBefore(now)) {
      return 'Voucher đã hết hạn';
    }
    final minOrder = v.minOrderValue ?? 0;
    if (subtotal < minOrder) {
      return 'Đơn tối thiểu ${minOrder.toStringAsFixed(0)}đ';
    }
    discountAmount = v.discountAmount;
    appliedVoucherCode = v.code;
    appliedVoucherId = v.voucherId;
    notifyListeners();
    return null;
  }

  // ==== REMOTE SYNC ====
  Future<int?> ensureCartFor(int userId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();
      try {
        final created = await repository.create(userId);
        cartId = created.cartId;
      } catch (e) {
        // Cart đã tồn tại — bỏ qua. Khi backend có GET /cart/user/{id}
        // thì gọi GET trước để lấy cartId thật.
        error = null;
      }
      return cartId;
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCart(int id) async {
    try {
      await repository.delete(id);
      if (cartId == id) cartId = null;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
