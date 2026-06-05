// NotificationProvider — quan ly:
//  + danh sach thong bao theo user
//  + so luong chua doc (badge realtime)
//  + ket noi SignalR khi login -> nhan thong bao realtime
//  + danh dau da doc / da doc tat ca / xoa
//  + callback global de cac man hinh hien Snackbar khi co notif moi
import 'package:flutter/foundation.dart';

import '../../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import '../services/notification_signalr_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository repository;
  final NotificationSignalRService signalR;

  NotificationProvider(this.repository, this.signalR) {
    // Khi service nhan event realtime -> chen vao dau list, tang unread
    signalR.onReceiveNotification = _onRealtimePush;
  }

  // ── STATE ──────────────────────────────────────────────
  List<NotificationModel> notifications = [];
  int unreadCount = 0;
  bool isLoading = false;
  String? error;

  // Callback cho UI global lang nghe push moi (vd hien Snackbar)
  void Function(NotificationModel n)? onPushed;

  int? _currentUserId;

  // ── INIT KHI LOGIN ─────────────────────────────────────
  Future<void> bootstrap(int userId) async {
    _currentUserId = userId;
    await Future.wait([
      fetchNotifications(userId),
      fetchUnreadCount(userId),
    ]);
    // Khong block UI, ket noi SignalR nen
    signalR.connect(userId);
  }

  Future<void> shutdown() async {
    notifications = [];
    unreadCount = 0;
    _currentUserId = null;
    await signalR.disconnect();
    notifyListeners();
  }

  // ── FETCH ──────────────────────────────────────────────
  Future<void> fetchNotifications(int userId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final list = await repository.getByUser(userId);
      // Sap xep moi nhat truoc
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifications = list;
    } catch (e) {
      error = e.toString();
      debugPrint('[NotificationProvider] fetch error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount(int userId) async {
    try {
      unreadCount = await repository.getUnreadCount(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('[NotificationProvider] unreadCount error: $e');
    }
  }

  Future<void> refresh() async {
    if (_currentUserId == null) return;
    await Future.wait([
      fetchNotifications(_currentUserId!),
      fetchUnreadCount(_currentUserId!),
    ]);
  }

  // ── ACTIONS ────────────────────────────────────────────
  Future<void> markAsRead(int notificationId) async {
    final idx =
        notifications.indexWhere((n) => n.notificationId == notificationId);
    if (idx == -1) return;
    if (notifications[idx].isRead) return; // da doc, bo qua

    // Optimistic update
    notifications[idx].isRead = true;
    if (unreadCount > 0) unreadCount--;
    notifyListeners();

    try {
      await repository.markAsRead(notificationId);
    } catch (e) {
      // Rollback
      notifications[idx].isRead = false;
      unreadCount++;
      notifyListeners();
      debugPrint('[NotificationProvider] markAsRead error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;
    final prev = unreadCount;
    for (final n in notifications) {
      n.isRead = true;
    }
    unreadCount = 0;
    notifyListeners();

    try {
      await repository.markAllAsRead(_currentUserId!);
    } catch (e) {
      // Rollback don gian: fetch lai
      unreadCount = prev;
      await refresh();
      debugPrint('[NotificationProvider] markAllAsRead error: $e');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    final idx =
        notifications.indexWhere((n) => n.notificationId == notificationId);
    if (idx == -1) return;
    final removed = notifications.removeAt(idx);
    if (!removed.isRead && unreadCount > 0) unreadCount--;
    notifyListeners();

    try {
      await repository.delete(notificationId);
    } catch (e) {
      // Rollback
      notifications.insert(idx, removed);
      if (!removed.isRead) unreadCount++;
      notifyListeners();
      debugPrint('[NotificationProvider] delete error: $e');
    }
  }

  // ── REALTIME PUSH ──────────────────────────────────────
  void _onRealtimePush(NotificationModel n) {
    // Chi nhan thong bao cua user dang dang nhap
    if (_currentUserId != null && n.userId != _currentUserId) return;

    // Tranh trung neu server cung gui qua REST
    final dup = notifications.any((x) => x.notificationId == n.notificationId);
    if (!dup) {
      notifications.insert(0, n);
      if (!n.isRead) unreadCount++;
      notifyListeners();
    }

    // Goi callback global de UI (vd HomeScreen) hien Snackbar
    onPushed?.call(n);
  }
}
