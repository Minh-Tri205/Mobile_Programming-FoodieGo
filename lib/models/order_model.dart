import 'package:flutter/material.dart';

// Khớp đúng với CHECK constraint trong SQL
enum OrderStatus { pending, confirmed, preparing, delivering, completed, cancelled }

// Payment method enum
enum PaymentMethod { cod, bankTransfer }

// Extension for PaymentMethod
extension PaymentMethodExtension on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cod:
        return 'Thanh toán khi nhận hàng (COD)';
      case PaymentMethod.bankTransfer:
        return 'Chuyển khoản ngân hàng';
    }
  }

  String get value {
    switch (this) {
      case PaymentMethod.cod:
        return 'COD';
      case PaymentMethod.bankTransfer:
        return 'BANK_TRANSFER';
    }
  }

  static PaymentMethod fromString(String value) {
    switch (value.toUpperCase()) {
      case 'COD':
        return PaymentMethod.cod;
      case 'BANK_TRANSFER':
        return PaymentMethod.bankTransfer;
      default:
        return PaymentMethod.cod;
    }
  }
}

class OrderItemModel {
  final int foodId;
  final String foodName;
  final String? foodImageUrl;
  final int quantity;
  final double unitPrice;

  const OrderItemModel({
    required this.foodId,
    required this.foodName,
    this.foodImageUrl,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;
}

class OrderModel {
  final int orderId;
  final String orderCode;
  final int userId;

  // Thông tin giao hàng — khớp SQL
  final String deliveryAddress;
  final String deliveryPhone;
  final double deliveryFee;
  final String? note;

  // Khuyến mãi — khớp SQL
  final int? voucherId;
  final String? voucherCode; // để hiển thị UI
  final double discountAmount;

  // Payment method
  final PaymentMethod paymentMethod;

  final OrderStatus status;
  final double totalAmount;
  final List<OrderItemModel> items;
  final String createdAt;

  const OrderModel({
    required this.orderId,
    required this.orderCode,
    required this.userId,
    required this.deliveryAddress,
    required this.deliveryPhone,
    this.deliveryFee = 0,
    this.note,
    this.voucherId,
    this.voucherCode,
    this.discountAmount = 0,
    this.paymentMethod = PaymentMethod.cod,
    required this.status,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
  });

  // Tóm tắt món ăn để hiển thị ở danh sách đơn hàng
  String get itemsSummary {
    return items.map((e) => '${e.foodName} x${e.quantity}').join(', ');
  }

  static List<OrderModel> sampleOrders = [
    OrderModel(
      orderId: 1,
      orderCode: 'DH-001',
      userId: 1,
      deliveryAddress: '123 Nguyễn Huệ, Quận 1, TP.HCM',
      deliveryPhone: '0901234567',
      deliveryFee: 15000,
      voucherCode: 'GIAM10K',
      discountAmount: 10000,
      paymentMethod: PaymentMethod.cod,
      status: OrderStatus.delivering,
      totalAmount: 160000,
      createdAt: 'Hôm nay 09:41',
      items: const [
        OrderItemModel(
          foodId: 1,
          foodName: 'Phở Bò Đặc Biệt',
          foodImageUrl: 'assets/images/pho_bo.jpg',
          quantity: 2,
          unitPrice: 50000,
        ),
        OrderItemModel(
          foodId: 5,
          foodName: 'Trà Đào Cam Sả',
          foodImageUrl: 'assets/images/tra_dao.jpg',
          quantity: 2,
          unitPrice: 25000,
        ),
      ],
    ),
    OrderModel(
      orderId: 2,
      orderCode: 'DH-002',
      userId: 1,
      deliveryAddress: '45 Lê Lợi, Quận 1, TP.HCM',
      deliveryPhone: '0901234567',
      deliveryFee: 15000,
      discountAmount: 0,
      paymentMethod: PaymentMethod.bankTransfer,
      status: OrderStatus.preparing,
      totalAmount: 100000,
      createdAt: 'Hôm nay 08:20',
      items: const [
        OrderItemModel(
          foodId: 3,
          foodName: 'Cơm Sườn Nướng',
          foodImageUrl: 'assets/images/com_suon.jpg',
          quantity: 2,
          unitPrice: 45000,
        ),
      ],
    ),
    OrderModel(
      orderId: 3,
      orderCode: 'DH-003',
      userId: 1,
      deliveryAddress: '78 Trần Hưng Đạo, Quận 5',
      deliveryPhone: '0901234567',
      deliveryFee: 15000,
      discountAmount: 10000,
      voucherCode: 'GIAM10K',
      paymentMethod: PaymentMethod.cod,
      status: OrderStatus.completed,
      totalAmount: 200000,
      createdAt: 'Hôm qua 19:30',
      items: const [
        OrderItemModel(
          foodId: 2,
          foodName: 'Bún Bò Huế',
          foodImageUrl: 'assets/images/bun_bo.jpg',
          quantity: 2,
          unitPrice: 45000,
        ),
        OrderItemModel(
          foodId: 6,
          foodName: 'Cà Phê Sữa Đá',
          foodImageUrl: 'assets/images/ca_phe.jpg',
          quantity: 2,
          unitPrice: 20000,
        ),
      ],
    ),
    OrderModel(
      orderId: 4,
      orderCode: 'DH-004',
      userId: 1,
      deliveryAddress: '12 Hai Bà Trưng, Quận 3',
      deliveryPhone: '0901234567',
      deliveryFee: 15000,
      discountAmount: 0,
      paymentMethod: PaymentMethod.bankTransfer,
      status: OrderStatus.cancelled,
      totalAmount: 75000,
      createdAt: '03/04 12:00',
      items: const [
        OrderItemModel(
          foodId: 4,
          foodName: 'Cơm Gà Xối Mỡ',
          foodImageUrl: 'assets/images/com_ga.jpg',
          quantity: 1,
          unitPrice: 40000,
        ),
      ],
    ),
  ];
}

// Helper để hiển thị text và màu trạng thái — dùng chung toàn app
extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:     return 'Chờ xác nhận';
      case OrderStatus.confirmed:   return 'Đã xác nhận';
      case OrderStatus.preparing:   return 'Đang chuẩn bị';
      case OrderStatus.delivering:  return 'Đang giao';
      case OrderStatus.completed:   return 'Hoàn thành';
      case OrderStatus.cancelled:   return 'Đã huỷ';
    }
  }

  // Màu nền badge
  Color get bgColor {
    switch (this) {
      case OrderStatus.pending:     return const Color(0xFFF5F5F5);
      case OrderStatus.confirmed:   return const Color(0xFFE8F5E9);
      case OrderStatus.preparing:   return const Color(0xFFFFF3CD);
      case OrderStatus.delivering:  return const Color(0xFFD4E8FF);
      case OrderStatus.completed:   return const Color(0xFFD9F2E6);
      case OrderStatus.cancelled:   return const Color(0xFFFCEBEB);
    }
  }

  // Màu chữ badge
  Color get textColor {
    switch (this) {
      case OrderStatus.pending:     return const Color(0xFF616161);
      case OrderStatus.confirmed:   return const Color(0xFF2E7D32);
      case OrderStatus.preparing:   return const Color(0xFFE6A817);
      case OrderStatus.delivering:  return const Color(0xFF185FA5);
      case OrderStatus.completed:   return const Color(0xFF3B6D11);
      case OrderStatus.cancelled:   return const Color(0xFFA32D2D);
    }
  }
}