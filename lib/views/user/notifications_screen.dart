// lib/views/notifications_screen.dart
// Giu nguyen UI cu (header "Thong bao", item: icon bubble + title + message + time + dot).
// Doi nguon du lieu sang NotificationProvider (real-time qua SignalR + REST).
// - Pull to refresh
// - Tap item -> markAsRead + deep link theo notificationType
// - Nut "Doc tat ca" o goc header
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../models/notification_model.dart';
import '../../../widgets/common/back_button_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NotificationProvider>();
    final list = prov.notifications;

    // Tach 2 nhom: chua doc (MOI) + da doc (TRUOC DO) — giu nguyen layout cu
    final unread = list.where((n) => !n.isRead).toList();
    final read = list.where((n) => n.isRead).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  BackButtonWidget(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  const Text(
                    'Thông báo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (prov.unreadCount > 0)
                    GestureDetector(
                      onTap: () => prov.markAllAsRead(),
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
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.accent1,
                onRefresh: () => prov.refresh(),
                child: _buildBody(prov, unread, read),
              ),
            ),
          ],
        ),
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
      // Phai dung ListView (khong dung Column) de RefreshIndicator hoat dong
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text(
              'Chưa có thông báo nào',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (unread.isNotEmpty) _sectionLabel('MỚI'),
        ...unread.map((n) => _notifItem(n)),
        if (read.isNotEmpty) _sectionLabel('TRƯỚC ĐÓ'),
        ...read.map((n) => _notifItem(n)),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Mapping type -> emoji + mau bubble (khop voi UI cu) ───
  ({String icon, Color bg}) _styleOf(String type) {
    switch (type.toLowerCase()) {
      case 'order':
      case 'order_status':
        return (icon: '🛵', bg: AppColors.pastel3);
      case 'voucher':
        return (icon: '🎁', bg: AppColors.pastel4);
      case 'review':
        return (icon: '⭐', bg: AppColors.pastel2);
      case 'order_completed':
        return (icon: '✅', bg: AppColors.pastel1);
      case 'promotion':
      case 'loyalty':
        return (icon: '🎉', bg: AppColors.pastel4);
      case 'payment':
        return (icon: '💳', bg: AppColors.pastel2);
      case 'new_food':
        return (icon: '🍜', bg: AppColors.pastel5);
      default:
        return (icon: '🔔', bg: AppColors.pastel1);
    }
  }

  // ── Deep link theo type ───────────────────────────────────
  void _openDetail(NotificationModel n) {
    final ctx = context;
    final type = n.notificationType.toLowerCase();
    // ORDER_STATUS -> Order detail
    if (type == 'order' ||
        type == 'order_status' ||
        type == 'order_completed') {
      if (n.relatedId != null) {
        Navigator.pushNamed(
          ctx,
          AppRoutes.orderDetail,
          arguments: n.relatedId,
        );
      } else {
        Navigator.pushNamed(ctx, AppRoutes.orders);
      }
      return;
    }
    // VOUCHER -> chua co man voucher detail -> mo gio hang (noi ap voucher)
    if (type == 'voucher' || type == 'promotion') {
      Navigator.pushNamed(ctx, AppRoutes.cart);
      return;
    }
    // PAYMENT -> mo order detail neu co relatedId, neu khong -> tracking
    if (type == 'payment') {
      if (n.relatedId != null) {
        Navigator.pushNamed(
          ctx,
          AppRoutes.orderDetail,
          arguments: n.relatedId,
        );
      } else {
        Navigator.pushNamed(ctx, AppRoutes.tracking);
      }
      return;
    }
  }

  // ── Format thoi gian (Vua xong / X phut truoc / ...) ─────
  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year}';
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
      key: ValueKey('notif-${n.notificationId}'),
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
          _openDetail(n);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: !n.isRead ? const Color(0xFFFFFAF8) : Colors.transparent,
            border: const Border(
              bottom: BorderSide(color: Color(0xFFF9F4F0)),
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
                    Text(n.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        )),
                    const SizedBox(height: 3),
                    Text(n.body,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          height: 1.4,
                        )),
                    const SizedBox(height: 5),
                    Text(_timeAgo(n.createdAt),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
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
