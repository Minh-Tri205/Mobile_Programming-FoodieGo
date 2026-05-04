import 'package:doancuoiki/core/constants/app_colors.dart';
import 'package:doancuoiki/core/constants/app_routes.dart';
import 'package:doancuoiki/core/constants/app_text_styles.dart';
import 'package:doancuoiki/widgets/admin_widgets/app_search_bar.dart';
import 'package:flutter/material.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Danh sách màu để random cho Avatar cho sinh động
    final List<Color> avatarColors = [
      AppColors.pastel1,
      AppColors.pastel2,
      AppColors.pastel3,
      AppColors.pastel5,
    ];
    final List<Color> accentColors = [
      AppColors.accent1,
      AppColors.accent2,
      AppColors.accent3,
      AppColors.accent5,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý người dùng', style: AppTextStyles.heading2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // // 1. Thanh tìm kiếm hiện đại
          AppSearchBar(
            hintText: 'Tìm kiếm tên, email...',
            onChanged: (value) {
              print("Đang tìm: $value");
              // Gọi logic filter dữ liệu ở đây
            },
          ),
          // 2. Danh sách người dùng
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 12,
              itemBuilder: (context, index) {
                final colorIndex = index % avatarColors.length;
                final bool isActive = index % 3 != 0;
                final int userId = index + 1; // Tạo ID giả định

                return InkWell(
                  // Sử dụng InkWell để có hiệu ứng gợn sóng khi chạm
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    // Điều hướng sang trang chi tiết và truyền ID người dùng
                    Navigator.pushNamed(
                      context,
                      AppRoutes.adminUserDetail,
                      arguments: userId,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: avatarColors[colorIndex],
                        child: Text(
                          'U$userId',
                          style: TextStyle(
                            color: accentColors[colorIndex],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            'Người dùng $userId',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(isActive),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'user$userId@email.com',
                            style: AppTextStyles.bodyMuted,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tham gia: 12/03/2024',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      // Nút 3 chấm vẫn giữ nguyên để hiện Menu tùy chọn nhanh
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => _showUserOptions(context, userId),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.statusConfirmed : AppColors.statusCancelled,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Hoạt động' : 'Bị khóa',
        style: AppTextStyles.label.copyWith(
          fontSize: 9,
          color: isActive
              ? AppColors.statusConfirmedText
              : AppColors.statusCancelledText,
        ),
      ),
    );
  }

  // Thêm tham số userId vào hàm
  void _showUserOptions(BuildContext context, int userId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thanh gạch ngang nhỏ trên đầu modal
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              Icons.history_rounded,
              'Lịch sử mua hàng',
              AppColors.accent3,
              () {
                Navigator.pop(context); // Đóng modal trước
                Navigator.pushNamed(
                  context,
                  AppRoutes.adminUserHistory,
                  arguments: userId,
                );
              },
            ),
            _buildOptionTile(
              Icons.block_flipped,
              'Khóa tài khoản',
              AppColors.statusCancelledText,
              () {
                // Xử lý logic khóa ở đây
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Cập nhật Widget build tile để nhận hàm callback onTap
  Widget _buildOptionTile(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: AppTextStyles.body),
      onTap: onTap,
    );
  }
}
