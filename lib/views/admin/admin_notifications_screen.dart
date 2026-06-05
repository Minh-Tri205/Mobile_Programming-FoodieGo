// lib/views/admin/admin_notifications_screen.dart
// Trang Thong bao cho admin. Dung chung NotificationProvider voi user:
// - SignalR realtime nhan thong bao do backend push (vd: don moi, thanh toan)
// - Pull to refresh, mark as read, mark all as read, swipe to delete
// - Background dynamic theo AdminSettingsProvider
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/providers/admin_settings_provider.dart';
import '../../data/providers/notification_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../models/notification_model.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  bool _booted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_booted) return;
    _booted = true;
    Future.microtask(() {
      if (!mounted) return;
      final userId = context.read<UserProvider>().currentUserId;
      if (userId != null) {
        context.read<NotificationProvider>().fetchNotifications(userId);
        context.read<NotificationProvider>().fetchUnreadCount(userId);
      }
    });
  }

  // ── Mapping type -> emoji + mau bubble ───────────────────
  ({String icon, Color bg}) _styleOf(String type) {
    switch (type.toLowerCase()) {
      case 'order':
      case 'order_status':
        return (icon: '🛵', bg: AppColors.pastel3);
      case 'order_new':
        return (icon: '🆕', bg: AppColors.pastel2);
      case 'voucher':
        return (icon: '🎁', bg: AppColors.pastel4);
      case 'review':
        return (icon: '⭐', bg: AppColors.pastel2);
      case 'order_completed':
        return (icon: '✅', bg: AppColors.pastel1);
      case 'payment':
        return (icon: '💳', bg: AppColors.pastel2);
      case 'user_register':
        return (icon: '👤', bg: AppColors.pastel5);
      default:
        return (icon: '🔔', bg: AppColors.pastel1);
    }
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${t.day.toString().padLeft(2, '0')}/'
        '${t.month.toString().padLeft(2, '0')}/${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NotificationProvider>();
    final unread = prov.notifications.where((n) => !n.isRead).toList();
    final read = prov.notifications.where((n) => n.isRead).toList();

    return Scaffold(
      backgroundColor:
          context.watch<AdminSettingsProvider>().backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('Thông báo', style: AppTextStyles.heading2),
            const SizedBox(width: 8),
            if (prov.unreadCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent1,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  prov.unreadCount > 99 ? '99+' : '${prov.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          if (prov.unreadCount > 0)
            TextButton(
              onPressed: () => prov.markAllAsRead(),
              child: const Text(
                'Đọc tất cả',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent1,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accent1,
        onRefresh: () => prov.refresh(),
        child: _buildBody(prov, unread, read),
      ),
    );
  }

  Widget _buildBody(
    NotificationProvider prov,
    List<NotificationModel> unread,
    List<NotificationModel> read,
  ) {
    if (prov.isLoading && prov.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.pastel1,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('🔔', style: TextStyle(fontSize: 44)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có thông báo',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (unread.isNotEmpty) _sectionLabel('MỚI'),
        ...unread.map((n) => _notifItem(n)),
        if (read.isNotEmpty) _sectionLabel('TRƯỚC ĐÓ'),
        ...read.map((n) => _notifItem(n)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _notifItem(NotificationModel n) {
    final style = _styleOf(n.notificationType);
    return Dismissible(
      key: ValueKey('admin-notif-${n.notificationId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.statusCancelled,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.statusCancelledText,
        ),
      ),
      onDismissed: (_) {
        context
            .read<NotificationProvider>()
            .deleteNotification(n.notificationId);
      },
      child: GestureDetector(
        onTap: () {
          context.read<NotificationProvider>().markAsRead(n.notificationId);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: !n.isRead ? AppColors.pastel1 : AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.divider.withOpacity(0.4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(style.icon, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      n.body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _timeAgo(n.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (!n.isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.accent1,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
