import 'package:doancuoiki/core/constants/app_colors.dart';
import 'package:doancuoiki/core/constants/app_routes.dart';
import 'package:doancuoiki/core/constants/app_text_styles.dart';
import 'package:doancuoiki/widgets/admin_widgets/app_search_bar.dart';
import 'package:flutter/material.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  String selectedCategory = 'Tất cả';
  final List<String> categories = ['Tất cả', 'Pizza', 'Burger', 'Phở'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý thực đơn', style: AppTextStyles.heading2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent1,
        onPressed: () {
          Navigator.pushReplacementNamed(context, AppRoutes.adminAddProduct);
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm món', style: AppTextStyles.button),
      ),
      body: Column(
        children: [
          AppSearchBar(
            hintText: 'Tìm kiếm tên món, giá...',
            onChanged: (value) {
              print("Đang tìm: $value");
              // Gọi logic filter dữ liệu ở đây
            },
          ),
          _buildCategoryFilter(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: 6,
              itemBuilder: (context, index) {
                final List<Map<String, dynamic>> products = [
                  {
                    'name': 'Pizza Hải Sản Size L',
                    'type': 'Pizza',
                    'price': '250.000đ',
                    'stock': 15,
                  },
                  {
                    'name': 'Burger Bò Đặc Biệt',
                    'type': 'Burger',
                    'price': '85.000đ',
                    'stock': 20,
                  },
                  {
                    'name': 'Phở Bò Tái Lăn',
                    'type': 'Phở',
                    'price': '65.000đ',
                    'stock': 0,
                  },
                  {
                    'name': 'Pizza Phô Mai Nhồi',
                    'type': 'Pizza',
                    'price': '190.000đ',
                    'stock': 8,
                  },
                  {
                    'name': 'Burger Gà Giòn',
                    'type': 'Burger',
                    'price': '55.000đ',
                    'stock': 12,
                  },
                  {
                    'name': 'Phở Gà Lá Chanh',
                    'type': 'Phở',
                    'price': '60.000đ',
                    'stock': 5,
                  },
                ];
                final item = products[index % products.length];
                return _buildProductCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategory == categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: isSelected,
              onSelected: (val) =>
                  setState(() => selectedCategory = categories[index]),
              selectedColor: AppColors.accent1,
              backgroundColor: AppColors.card,
              labelStyle: AppTextStyles.label.copyWith(
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide.none,
              elevation: 2,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    IconData itemIcon;
    Color itemColor, itemAccent;

    switch (item['type']) {
      case 'Pizza':
        itemIcon = Icons.local_pizza_rounded;
        itemColor = AppColors.pastel1;
        itemAccent = AppColors.accent1;
        break;
      case 'Burger':
        itemIcon = Icons.lunch_dining_rounded;
        itemColor = AppColors.pastel4;
        itemAccent = AppColors.accent4;
        break;
      default:
        itemIcon = Icons.soup_kitchen_rounded;
        itemColor = AppColors.pastel2;
        itemAccent = AppColors.accent2;
    }

    bool isOutOfStock = item['stock'] == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Opacity(
        opacity: isOutOfStock ? 0.6 : 1.0,
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: itemColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(itemIcon, color: itemAccent, size: 30),
          ),
          title: Text(item['name'], style: AppTextStyles.heading3),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(item['price'], style: AppTextStyles.price),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 12,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOutOfStock ? 'Hết hàng' : 'Kho: ${item['stock']}',
                    style: AppTextStyles.caption.copyWith(
                      color: isOutOfStock ? Colors.red : AppColors.textMuted,
                      fontWeight: isOutOfStock
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () => _showActionSheet(context, item),
          ),
        ),
      ),
    );
  }

  // Hàm hiển thị tùy chọn cho từng món ăn
  void _showActionSheet(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            Text(item['name'], style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            _buildOptionTile(
              Icons.edit_outlined,
              'Chỉnh sửa món',
              AppColors.accent2,
              () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRoutes.adminEditProduct,
                  arguments: item, 
                );
              },
            ),
            _buildOptionTile(
              Icons.visibility_off_outlined,
              'Ẩn khỏi thực đơn',
              AppColors.accent3,
              () {
                Navigator.pop(context);
                // Thêm logic ẩn
              },
            ),
            _buildOptionTile(
              Icons.delete_outline_rounded,
              'Xóa món ăn',
              AppColors.statusCancelledText,
              () {
                Navigator.pop(context);
                // Thêm logic xóa
              },
            ),
          ],
        ),
      ),
    );
  }

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
}
