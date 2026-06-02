// lib/models/voucher_model.dart
// Khop class Voucher (C#) trong API_Food_App.Models
//   public int VoucherId
//   public string Code
//   public string? Description
//   public decimal DiscountAmount
//   public decimal? MinOrderValue
//   public DateTime? StartDate
//   public DateTime? EndDate
//   public int? UsageLimit
//   public bool? IsActive

class VoucherModel {
  final int? voucherId;
  final String code;
  final String? description;
  final double discountAmount;
  final double? minOrderValue;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? usageLimit;
  final bool? isActive;

  const VoucherModel({
    this.voucherId,
    required this.code,
    this.description,
    required this.discountAmount,
    this.minOrderValue,
    this.startDate,
    this.endDate,
    this.usageLimit,
    this.isActive,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      voucherId: json['voucherId'],
      code: json['code'] ?? '',
      description: json['description'],
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      minOrderValue: json['minOrderValue'] != null
          ? (json['minOrderValue'] as num).toDouble()
          : null,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      usageLimit: json['usageLimit'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    // Backend C# co VoucherId la int (non-null) -> null se fail JSON binding khi create
    final map = <String, dynamic>{
      'code': code,
      'description': description,
      'discountAmount': discountAmount,
      'minOrderValue': minOrderValue,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'usageLimit': usageLimit,
      'isActive': isActive ?? true,
    };
    if (voucherId != null) map['voucherId'] = voucherId;
    return map;
  }

  VoucherModel copyWith({
    int? voucherId,
    String? code,
    String? description,
    double? discountAmount,
    double? minOrderValue,
    DateTime? startDate,
    DateTime? endDate,
    int? usageLimit,
    bool? isActive,
  }) {
    return VoucherModel(
      voucherId: voucherId ?? this.voucherId,
      code: code ?? this.code,
      description: description ?? this.description,
      discountAmount: discountAmount ?? this.discountAmount,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      usageLimit: usageLimit ?? this.usageLimit,
      isActive: isActive ?? this.isActive,
    );
  }
}
