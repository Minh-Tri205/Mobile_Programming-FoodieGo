import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'order_item_model.dart';

// ============================================================
// OrderStatus — khớp CHECK constraint trong SQL:
//   'pending', 'confirmed', 'preparing', 'shipping', 'completed', 'cancelled'
// Dùng class chứa hằng String để giữ cú pháp OrderStatus.completed
// như UI cũ mà vẫn lưu dưới dạng String (đúng schema).
// ============================================================
class OrderStatus {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String preparing = 'preparing';
  static const String shipping = 'shipping';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';

  // Giữ tương thích với code cũ dùng OrderStatus.delivering
  static const String delivering = shipping;
}

extension OrderStatusLabel on String? {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.preparing:
        return 'Đang chuẩn bị';
      case OrderStatus.shipping:
        return 'Đang giao';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã huỷ';
      default:
        return 'Không rõ';
    }
  }

  Color get bgColor {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.statusPending;
      case OrderStatus.confirmed:
        return AppColors.statusConfirmed;
      case OrderStatus.preparing:
        return AppColors.statusPreparing;
      case OrderStatus.shipping:
        return AppColors.statusDelivering;
      case OrderStatus.completed:
        return AppColors.statusDelivered;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
      default:
        return AppColors.statusPending;
    }
  }

  Color get textColor {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.statusPendingText;
      case OrderStatus.confirmed:
        return AppColors.statusConfirmedText;
      case OrderStatus.preparing:
        return AppColors.statusPreparingText;
      case OrderStatus.shipping:
        return AppColors.statusDeliveringText;
      case OrderStatus.completed:
        return AppColors.statusDeliveredText;
      case OrderStatus.cancelled:
        return AppColors.statusCancelledText;
      default:
        return AppColors.statusPendingText;
    }
  }
}

class OrderModel {
  final int? orderId;
  final int userId;

  final String orderCode;

  final String recipientName;
  final String deliveryAddress;
  final String deliveryPhone;

  final double deliveryFee;

  final String? note;

  final int? addressId;

  final String paymentMethod;

  final int? voucherId;
  final String? voucherCode;

  final double discountAmount;

  final String status;

  final double totalAmount;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  // order_items đi kèm — lấy qua JOIN ở backend
  final List<OrderItemModel> items;

  OrderModel({
    this.orderId,
    required this.userId,
    required this.orderCode,
    required this.recipientName,
    required this.deliveryAddress,
    required this.deliveryPhone,
    this.deliveryFee = 0,
    this.note,
    this.addressId,
    this.paymentMethod = 'cash',
    this.voucherId,
    this.voucherCode,
    this.discountAmount = 0,
    this.status = OrderStatus.pending,
    this.totalAmount = 0,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  // Tóm tắt món ăn hiển thị danh sách đơn hàng
  String get itemsSummary {
    if (items.isEmpty) return '';
    return items.map((e) => '${e.foodName} x${e.quantity}').join(', ');
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ?? json['orderItems'];
    return OrderModel(
      orderId: json['orderId'],
      userId: json['userId'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      recipientName: json['recipientName'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      deliveryPhone: json['deliveryPhone'] ?? '',
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      note: json['note'],
      addressId: json['addressId'],
      paymentMethod: json['paymentMethod'] ?? 'cash',
      voucherId: json['voucherId'],
      voucherCode: json['voucherCode'],
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      status: json['status'] ?? OrderStatus.pending,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      items: rawItems is List
          ? rawItems
                .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'orderCode': orderCode,
      'recipientName': recipientName,
      'deliveryAddress': deliveryAddress,
      'deliveryPhone': deliveryPhone,
      'deliveryFee': deliveryFee,
      'note': note,
      'addressId': addressId,
      'paymentMethod': paymentMethod,
      'voucherId': voucherId,
      'voucherCode': voucherCode,
      'discountAmount': discountAmount,
      'status': status,
      'totalAmount': totalAmount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  // ============================================================
  // SAMPLE DATA — gán cứng tạm thời để UI chạy
  // Khi backend hoàn thiện, thay thế bằng dữ liệu thật qua provider.
  // ============================================================
  static final List<OrderModel> sampleOrders = [
    OrderModel(
      orderId: 1,
      orderCode: 'DH-001',
      userId: 1,
      recipientName: 'Nguyễn Văn A',
      deliveryAddress: '123 Nguyễn Huệ, Quận 1, TP.HCM',
      deliveryPhone: '0901234567',
      deliveryFee: 15000,
      voucherCode: 'GIAM10K',
      discountAmount: 10000,
      status: OrderStatus.shipping,
      totalAmount: 160000,
      paymentMethod: 'cash',
      createdAt: DateTime.now(),
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
      recipientName: 'Nguyễn Văn A',
      deliveryAddress: '45 Lê Lợi, Quận 1, TP.HCM',
      deliveryPhone: '0901234567',
      deliveryFee: 15000,
      discountAmount: 0,
      status: OrderStatus.preparing,
      totalAmount: 100000,
      paymentMethod: 'momo',
      createdAt: DateTime.now(),
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
      recipientName: 'Nguyễn Văn A',
      deliveryAddress: '78 Trần Hưng Đạo, Quận 5',
      deliveryPhone: '0901234567',
      deliveryFee: 15000,
      discountAmount: 10000,
      voucherCode: 'GIAM10K',
      status: OrderStatus.completed,
      totalAmount: 200000,
      paymentMethod: 'cash',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
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
      recipientName: 'Nguyễn Văn A',
      deliveryAddress: '12 Hai Bà Trưng, Quận 3',
      deliveryPhone: '0901234567',
      deliveryFee: 15000,
      discountAmount: 0,
      status: OrderStatus.cancelled,
      totalAmount: 75000,
      paymentMethod: 'cash',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
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

// sId': addressId,
//       'paymentMethod': paymentMethod,
//       'voucherId': voucherId,
//       'discountAmount': discountAmount,
//       'status': status,
//       'totalAmount': totalAmount,
//       'createdAt': createdAt?.toIso8601String(),
//       'updatedAt': updatedAt?.toIso8601String(),
//     };
//   }
// }
// ': addressId,
//       'paymentMethod': paymentMethod,
//       'voucherId': voucherId,
//       'discountAmount': discountAmount,
//       'status': status,
//       'totalAmount': totalAmount,
//       'createdAt': createdAt?.toIso8601String(),
//       'updatedAt': updatedAt?.toIso8601String(),
//     };
//   }
// }
