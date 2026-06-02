// lib/models/voucher_usage_model.dart
// Khop class VoucherUsage (C#) trong API_Food_App.Models
//   public int UsageId
//   public int VoucherId
//   public int UserId
//   public int? OrderId
//   public DateTime? UsedAt
//   public virtual Voucher Voucher
//   public virtual User User

import 'user_model.dart';
import 'voucher_model.dart';

class VoucherUsageModel {
  final int? usageId;
  final int voucherId;
  final int userId;
  final int? orderId;
  final DateTime? usedAt;

  // Nested khi backend .Include
  final VoucherModel? voucher;
  final UserModel? user;

  const VoucherUsageModel({
    this.usageId,
    required this.voucherId,
    required this.userId,
    this.orderId,
    this.usedAt,
    this.voucher,
    this.user,
  });

  factory VoucherUsageModel.fromJson(Map<String, dynamic> json) {
    final voucherJson = json['voucher'] as Map<String, dynamic>?;
    final userJson = json['user'] as Map<String, dynamic>?;
    return VoucherUsageModel(
      usageId: json['usageId'],
      voucherId: json['voucherId'] ?? voucherJson?['voucherId'] ?? 0,
      userId: json['userId'] ?? userJson?['userId'] ?? 0,
      orderId: json['orderId'],
      usedAt: json['usedAt'] != null
          ? DateTime.tryParse(json['usedAt'].toString())
          : null,
      voucher:
          voucherJson != null ? VoucherModel.fromJson(voucherJson) : null,
      user: userJson != null ? UserModel.fromJson(userJson) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'voucherId': voucherId,
      'userId': userId,
      'orderId': orderId,
      'usedAt': usedAt?.toIso8601String(),
    };
    if (usageId != null) map['usageId'] = usageId;
    return map;
  }
}
