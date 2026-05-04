import 'package:doancuoiki/core/constants/app_colors.dart';
import 'package:doancuoiki/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AdminUserDetailScreen extends StatelessWidget {
  final int userId; // Nhận ID để fetch dữ liệu hoặc hiển thị demo

  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi tiết người dùng', style: AppTextStyles.heading2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_note_rounded,
              color: AppColors.accent1,
              size: 28,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Header Profile Card
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // 2. Statistics Row
            Row(
              children: [
                _buildStatCard(
                  'Đơn hàng',
                  '24',
                  AppColors.pastel1,
                  AppColors.accent1,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Tổng chi',
                  '2.4M',
                  AppColors.pastel2,
                  AppColors.accent2,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Information Sections
            _buildInfoSection(
              title: 'Thông tin cá nhân',
              children: [
                _buildInfoTile(
                  Icons.email_outlined,
                  'Email',
                  'user$userId@email.com',
                ),
                _buildInfoTile(
                  Icons.phone_android_rounded,
                  'Số điện thoại',
                  '0987 654 321',
                ),
                _buildInfoTile(
                  Icons.location_on_outlined,
                  'Địa chỉ mặc định',
                  '123 Đường ABC, Quận 1, TP.HCM',
                ),
                _buildInfoTile(
                  Icons.calendar_today_rounded,
                  'Ngày gia nhập',
                  '12/03/2024',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Admin Actions Area
            _buildInfoSection(
              title: 'Thao tác quản trị',
              children: [
                _buildActionTile(
                  Icons.history_rounded,
                  'Xem lịch sử mua hàng',
                  'Xem chi tiết 24 đơn hàng đã đặt',
                  AppColors.accent3,
                ),
                _buildActionTile(
                  Icons.lock_reset_rounded,
                  'Đặt lại mật khẩu',
                  'Gửi email khôi phục mật khẩu',
                  AppColors.accent1,
                ),
                _buildActionTile(
                  Icons.block_flipped,
                  'Khóa tài khoản này',
                  'Người dùng sẽ không thể đăng nhập',
                  AppColors.statusCancelledText,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.pastel5,
            child: Text(
              'U$userId',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.accent5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Người dùng $userId', style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.statusConfirmed,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Hạng Thành Viên: Gold',
              style: TextStyle(
                color: AppColors.statusConfirmedText,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.heading1.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: AppTextStyles.heading3),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textMuted, size: 22),
      title: Text(label, style: AppTextStyles.caption),
      subtitle: Text(value, style: AppTextStyles.body),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subTitle,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subTitle, style: AppTextStyles.caption),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.divider,
      ),
      onTap: () {},
    );
  }
}
