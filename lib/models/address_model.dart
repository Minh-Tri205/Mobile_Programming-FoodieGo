// lib/models/address_model.dart
// Khop class Address (C#) trong API_Food_App.Models
//   public int AddressId
//   public int UserId
//   public string? Label
//   public string FullAddress
//   public string? RecipientName
//   public string? RecipientPhone
//   public bool? IsDefault

class AddressModel {
  final int? addressId;
  final int userId;
  final String? label;
  final String fullAddress;
  final String? recipientName;
  final String? recipientPhone;
  final bool? isDefault;

  const AddressModel({
    this.addressId,
    required this.userId,
    this.label,
    required this.fullAddress,
    this.recipientName,
    this.recipientPhone,
    this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      addressId: json['addressId'],
      userId: json['userId'] ?? 0,
      label: json['label'],
      fullAddress: json['fullAddress'] ?? '',
      recipientName: json['recipientName'],
      recipientPhone: json['recipientPhone'],
      isDefault: json['isDefault'],
    );
  }

  Map<String, dynamic> toJson() {
    // Backend C# co AddressId la int (non-null) -> null se fail JSON binding khi create
    final map = <String, dynamic>{
      'userId': userId,
      'label': label,
      'fullAddress': fullAddress,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'isDefault': isDefault ?? false,
    };
    if (addressId != null) map['addressId'] = addressId;
    return map;
  }

  AddressModel copyWith({
    int? addressId,
    int? userId,
    String? label,
    String? fullAddress,
    String? recipientName,
    String? recipientPhone,
    bool? isDefault,
  }) {
    return AddressModel(
      addressId: addressId ?? this.addressId,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
