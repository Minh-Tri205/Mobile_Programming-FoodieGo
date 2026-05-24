class UserModel {
  final int userId;
  final String fullName;
  final String? email;
  final String? phone;
  final String passwordHash;
  final String? avatarUrl;
  final String? deviceToken;
  String? role;
  bool? isActive;
  final int? loyaltyPoints;
  final String? passwordResetToken;
  final DateTime? resetTokenExpiry;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.userId,
    required this.fullName,
    this.email,
    this.phone,
    required this.passwordHash,
    this.avatarUrl,
    this.deviceToken,
    this.role,
    this.isActive,
    this.loyaltyPoints,
    this.passwordResetToken,
    this.resetTokenExpiry,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      passwordHash: json['passwordHash'],
      avatarUrl: json['avatarUrl'],
      deviceToken: json['deviceToken'],
      role: json['role'],
      isActive: json['isActive'],
      loyaltyPoints: json['loyaltyPoints'],
      passwordResetToken: json['passwordResetToken'],
      resetTokenExpiry: json['resetTokenExpiry'] != null
          ? DateTime.parse(json['resetTokenExpiry'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'passwordHash': passwordHash,
      'avatarUrl': avatarUrl,
      'deviceToken': deviceToken,
      'role': role,
      'isActive': isActive,
      'loyaltyPoints': loyaltyPoints,
      'passwordResetToken': passwordResetToken,
      'resetTokenExpiry': resetTokenExpiry?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
