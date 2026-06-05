// Khop voi backend Notification (table: notifications)
// + SignalR payload event "ReceiveNotification".
//
// notificationType (chuoi tu backend - khong fix cung enum de de mo rong):
//   "order"          -> trang thai don hang
//   "voucher"        -> co voucher moi
//   "payment"        -> giao dich thanh toan
//   "review"         -> nhac danh gia
//   "promotion"      -> khuyen mai/loyalty
// (mapping icon + mau o widget tile, khong o model)
class NotificationModel {
  final int notificationId;
  final int userId;
  final String title;
  final String body;
  final String notificationType;
  final int? relatedId;
  bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.body,
    required this.notificationType,
    this.relatedId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Backend tra ve PascalCase hoac camelCase tuy serializer
    final id = json['notificationId'] ?? json['NotificationId'] ?? 0;
    final uid = json['userId'] ?? json['UserId'] ?? 0;
    final type =
        (json['notificationType'] ?? json['NotificationType'] ?? '').toString();
    final relId = json['relatedId'] ?? json['RelatedId'];
    final created = json['createdAt'] ?? json['CreatedAt'];

    return NotificationModel(
      notificationId: id is int ? id : int.tryParse(id.toString()) ?? 0,
      userId: uid is int ? uid : int.tryParse(uid.toString()) ?? 0,
      title: (json['title'] ?? json['Title'] ?? '').toString(),
      body: (json['body'] ?? json['Body'] ?? '').toString(),
      notificationType: type,
      relatedId:
          relId == null ? null : (relId is int ? relId : int.tryParse(relId.toString())),
      isRead: (json['isRead'] ?? json['IsRead'] ?? false) == true,
      createdAt: created != null
          ? DateTime.tryParse(created.toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'body': body,
      'notificationType': notificationType,
      'relatedId': relatedId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
