import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../widgets/navigation/app_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildStatsRow(),
            const SizedBox(height: 8),
            _buildSectionLabel('TÀI KHOẢN'),
            _buildMenuItem(
              context,
              icon: '🔔',
              iconBg: AppColors.pastel4,
              label: 'Thông báo',
              badge: '3',
              route: AppRoutes.notifications,
            ),
            _buildMenuItem(
              context,
              icon: '📍',
              iconBg: AppColors.pastel2,
              label: 'Địa chỉ của tôi',
            ),
            _buildMenuItem(
              context,
              icon: '💳',
              iconBg: AppColors.pastel3,
              label: 'Phương thức thanh toán',
            ),
            _buildMenuItem(
              context,
              icon: '❤️',
              iconBg: AppColors.pastel5,
              label: 'Món ăn yêu thích',
            ),
            _buildSectionLabel('HỖ TRỢ'),
            _buildMenuItem(
              context,
              icon: '🎧',
              iconBg: AppColors.pastel1,
              label: 'Trung tâm hỗ trợ',
            ),
            _buildMenuItem(
              context,
              icon: '⚙️',
              iconBg: AppColors.pastel4,
              label: 'Cài đặt',
            ),
            const SizedBox(height: 8),
            _buildLogoutItem(context),
            const SizedBox(height: 96),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.pastel1, AppColors.pastel5],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text('👩', style: TextStyle(fontSize: 44)),
          ),
          const SizedBox(height: 10),
          const Text(
            'Nguyễn Minh Anh',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'minhanh@gmail.com',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.accent1.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: const Text(
              '✏️  Chỉnh sửa hồ sơ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.accent1,
              ),
            ),
          ),
        ],
      ),
    );
  }

 // Thay hàm _buildStatsRow cũ bằng:
Widget _buildStatsRow() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        _statItem('28', 'Đơn hàng', isLast: false),
        // loyalty_points — khớp cột loyalty_points trong bảng users SQL
        _statItem('50 🪙', 'Điểm tích lũy', isLast: false),
        _statItem('⭐ 4.9', 'Đánh giá', isLast: true),
      ],
    ),
  );
}

  Widget _statItem(String value, String label, {required bool isLast}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          border: !isLast
              ? const Border(
                  right: BorderSide(color: Color(0xFFF5EEE9)),
                )
              : null,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.accent1,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String icon,
    required Color iconBg,
    required String label,
    String? badge,
    String? route,
  }) {
    return GestureDetector(
      onTap: () {
        if (route != null) Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF9F4F0))),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (badge != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent1,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF9F4F0))),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.statusCancelled,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text('🚪', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.statusCancelledText,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.statusCancelledText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
