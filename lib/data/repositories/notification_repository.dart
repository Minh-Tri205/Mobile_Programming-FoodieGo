import '../../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationRepository {
  final NotificationService service;

  NotificationRepository(this.service);

  Future<List<NotificationModel>> getByUser(int userId) {
    return service.getByUser(userId);
  }

  Future<int> getUnreadCount(int userId) {
    return service.getUnreadCount(userId);
  }

  Future<void> markAsRead(int notificationId) {
    return service.markAsRead(notificationId);
  }

  Future<void> markAllAsRead(int userId) {
    return service.markAllAsRead(userId);
  }

  Future<void> delete(int notificationId) {
    return service.delete(notificationId);
  }
}
