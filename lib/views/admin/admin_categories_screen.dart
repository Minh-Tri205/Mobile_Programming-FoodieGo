import 'package:doancuoiki/core/constants/app_colors.dart';
import 'package:doancuoiki/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  static const List<Map<String, dynamic>> _mockCategories = [
    {
      'name': 'Món chính',
      'count': 24,
      'color': AppColors.pastel1,
      'accent': AppColors.accent1,
      'icon': Icons.restaurant,
    },
    {
      'name': 'Đồ uống',
      'count': 15,
      'color': AppColors.pastel2,
      'accent': AppColors.accent2,
      'icon': Icons.local_drink,
    },
    {
      'name': 'Tráng miệng',
      'count': 10,
      'color': AppColors.pastel5,
      'accent': AppColors.accent5,
      'icon': Icons.cake,
    },
    {
      'name': 'Ăn vặt',
      'count': 18,
      'color': AppColors.pastel4,
      'accent': AppColors.accent4,
      'icon': Icons.icecream,
    },
    {
      'name': 'Combo',
      'count': 5,
      'color': AppColors.pastel3,
      'accent': AppColors.accent3,
      'icon': Icons.auto_awesome,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý danh mục', style: AppTextStyles.heading3),
        backgroundColor: AppColors.card,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent1,
        onPressed: () => _showCategoryDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Thêm mới',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mockCategories.length,
        itemBuilder: (context, index) {
          final category = _mockCategories[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: category['color'],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  category['icon'],
                  color: category['accent'],
                  size: 28,
                ),
              ),
              title: Text(category['name'], style: AppTextStyles.heading3),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${category['count']} sản phẩm',
                  style: AppTextStyles.bodyMuted.copyWith(fontSize: 13),
                ),
              ),
              // THAY ĐỔI TẠI ĐÂY: Gọi hàm hiển thị BottomSheet
              trailing: IconButton(
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.textMuted,
                ),
                onPressed: () => _showCategoryActions(context, category),
              ),
            ),
          );
        },
      ),
    );
  }

  // Hàm hiển thị các hành động cho Danh mục
  void _showCategoryActions(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(category['name'], style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            _buildOptionTile(
              Icons.edit_outlined,
              'Chỉnh sửa danh mục',
              AppColors.accent2,
              () {
                Navigator.pop(context);
                // Thực hiện logic sửa tại đây
              },
            ),
            _buildOptionTile(
              Icons.delete_outline_rounded,
              'Xóa danh mục',
              AppColors.statusCancelledText,
              () {
                Navigator.pop(context);
                // Thực hiện logic xóa tại đây
              },
            ),
          ],
        ),
      ),
    );
  }

  // Hàm helper để build từng dòng tùy chọn
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
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Danh mục mới', style: AppTextStyles.heading3),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Nhập tên danh mục...',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
