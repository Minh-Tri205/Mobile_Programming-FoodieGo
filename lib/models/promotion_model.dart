import 'package:flutter/material.dart';

// Promotion model for discount management
enum PromotionType { fixed, percentage }

extension PromotionTypeExtension on PromotionType {
  String get label {
    switch (this) {
      case PromotionType.fixed:
        return 'Giảm giá cố định';
      case PromotionType.percentage:
        return 'Giảm giá theo %';
    }
  }

  String get value {
    switch (this) {
      case PromotionType.fixed:
        return 'FIXED';
      case PromotionType.percentage:
        return 'PERCENTAGE';
    }
  }

  static PromotionType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'FIXED':
        return PromotionType.fixed;
      case 'PERCENTAGE':
        return PromotionType.percentage;
      default:
        return PromotionType.fixed;
    }
  }
}

enum PromotionStatus { active, inactive }

extension PromotionStatusExtension on PromotionStatus {
  String get label {
    switch (this) {
      case PromotionStatus.active:
        return 'Đang hoạt động';
      case PromotionStatus.inactive:
        return 'Không hoạt động';
    }
  }

  String get value {
    switch (this) {
      case PromotionStatus.active:
        return 'ACTIVE';
      case PromotionStatus.inactive:
        return 'INACTIVE';
    }
  }

  Color get bgColor {
    switch (this) {
      case PromotionStatus.active:
        return const Color(0xFFE8F5E9);
      case PromotionStatus.inactive:
        return const Color(0xFFFCEBEB);
    }
  }

  Color get textColor {
    switch (this) {
      case PromotionStatus.active:
        return const Color(0xFF2E7D32);
      case PromotionStatus.inactive:
        return const Color(0xFFA32D2D);
    }
  }

  static PromotionStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ACTIVE':
        return PromotionStatus.active;
      case 'INACTIVE':
        return PromotionStatus.inactive;
      default:
        return PromotionStatus.inactive;
    }
  }
}

class PromotionModel {
  final int promotionId;
  final String name;
  final String? description;
  final PromotionType discountType;
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final double minOrderAmount;
  final double? maxDiscount; // For percentage type
  final int? usageLimit;
  final int usageCount;
  final PromotionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PromotionModel({
    required this.promotionId,
    required this.name,
    this.description,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    this.minOrderAmount = 0,
    this.maxDiscount,
    this.usageLimit,
    this.usageCount = 0,
    this.status = PromotionStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isActive => status == PromotionStatus.active && !isExpired;
  bool get hasReachedUsageLimit => usageLimit != null && usageCount >= usageLimit!;

  bool isApplicable(double orderAmount) {
    if (!isActive) return false;
    if (orderAmount < minOrderAmount) return false;
    if (hasReachedUsageLimit) return false;
    return true;
  }

  double calculateDiscount(double orderAmount) {
    if (!isApplicable(orderAmount)) return 0;

    double discount = 0;
    if (discountType == PromotionType.fixed) {
      discount = discountValue;
    } else {
      discount = (orderAmount * discountValue) / 100;
      if (maxDiscount != null && discount > maxDiscount!) {
        discount = maxDiscount!;
      }
    }
    return discount;
  }

  static List<PromotionModel> samplePromotions = [
    PromotionModel(
      promotionId: 1,
      name: 'SAVE10',
      description: 'Giảm 10.000 đồng cho đơn hàng từ 50.000 đồng',
      discountType: PromotionType.fixed,
      discountValue: 10000,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      minOrderAmount: 50000,
      status: PromotionStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    PromotionModel(
      promotionId: 2,
      name: 'WELCOME20',
      description: 'Giảm 20% cho khách hàng mới',
      discountType: PromotionType.percentage,
      discountValue: 20,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 60)),
      minOrderAmount: 30000,
      maxDiscount: 100000,
      status: PromotionStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    PromotionModel(
      promotionId: 3,
      name: 'VIP30',
      description: 'Giảm 30% cho thành viên VIP',
      discountType: PromotionType.percentage,
      discountValue: 30,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 90)),
      minOrderAmount: 100000,
      maxDiscount: 200000,
      usageLimit: 10,
      status: PromotionStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    PromotionModel(
      promotionId: 4,
      name: 'FREESHIP',
      description: 'Miễn phí vận chuyển',
      discountType: PromotionType.fixed,
      discountValue: 0, // Handled separately as free shipping
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 45)),
      minOrderAmount: 200000,
      status: PromotionStatus.inactive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
}
