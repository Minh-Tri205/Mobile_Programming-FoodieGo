// lib/views/notifications_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/common/back_button_widget.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _sectionLabel('MỚI'),
                  _notifItem(
                    icon: '🛵',
                    iconBg: AppColors.pastel3,
                    title: 'Đơn hàng đang được giao!',
                    // Khớp trigger trg_after_order_created trong SQL
                    message: 'Đơn hàng #DH-001 của bạn đang trên đường giao. Dự kiến 15 phút nữa.',
                    time: 'Vừa xong',
                    isUnread: true,
                  ),
                  _notifItem(
                    icon: '🎁',
                    iconBg: AppColors.pastel4,
                    title: 'Ưu đãi đặc biệt hôm nay!',
                    // Khớp voucher GIAM10K trong SQL
                    message: 'Dùng mã GIAM10K giảm 10.000đ cho đơn từ 50.000đ. Áp dụng ngay!',
                    time: '5 phút trước',
                    isUnread: true,
                  ),
                  _notifItem(
                    icon: '⭐',
                    iconBg: AppColors.pastel2,
                    title: 'Đánh giá đơn hàng của bạn',
                    // Khớp bảng reviews trong SQL
                    message: 'Bạn có hài lòng với đơn hàng #DH-002 không? Hãy để lại đánh giá!',
                    time: '2 giờ trước',
                    isUnread: true,
                  ),
                  _sectionLabel('TRƯỚC ĐÓ'),
                  _notifItem(
                    icon: '✅',
                    iconBg: AppColors.pastel1,
                    title: 'Đơn hàng đã giao thành công',
                    // Khớp trigger trg_after_order_completed trong SQL
                    message: 'Đơn hàng #DH-003 đã giao thành công. Bạn được cộng 10 điểm tích lũy!',
                    time: 'Hôm qua 19:45',
                    isUnread: false,
                  ),
                  _notifItem(
                    icon: '🎉',
                    iconBg: AppColors.pastel4,
                    title: 'Chúc mừng! Bạn đã tích 50 điểm',
                    // Khớp loyalty_points trong bảng users SQL
                    message: 'Bạn đang có 50 điểm tích lũy. Tiếp tục đặt hàng để nhận thêm ưu đãi!',
                    time: '3 ngày trước',
                    isUnread: false,
                  ),
                  _notifItem(
                    icon: '🍜',
                    iconBg: AppColors.pastel5,
                    title: 'Món mới đã có mặt!',
                    // Khớp bảng food_items trong SQL
                    message: 'Bún Bò Huế đặc biệt vừa được thêm vào thực đơn. Thử ngay hôm nay!',
                    time: '5 ngày trước',
                    isUnread: false,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
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

  Widget _notifItem({
    required String icon,
    required Color iconBg,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFFFFAF8) : Colors.transparent,
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
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 3),
                Text(message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      height: 1.4,
                    )),
                const SizedBox(height: 5),
                Text(time,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (isUnread) ...[
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
    );
  }
}