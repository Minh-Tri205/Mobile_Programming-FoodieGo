import 'package:doancuoiki/widgets/notification/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:doancuoiki/core/constants/app_colors.dart';
import 'package:doancuoiki/core/constants/app_text_styles.dart';
import 'package:doancuoiki/data/providers/category_provider.dart';
import 'package:doancuoiki/models/category_model.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,

        title: const Text('Quản lý danh mục', style: AppTextStyles.heading2),

        leading: IconButton(
          onPressed: () => Navigator.pop(context),

          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showCategoryDialog(context);
            },
            icon: const Icon(Icons.add_rounded, color: AppColors.accent1),
          ),
        ],
      ),

      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.categories.isEmpty) {
            return const Center(child: Text('Không có danh mục'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: provider.categories.length,

            itemBuilder: (context, index) {
              final category = provider.categories[index];

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
                      color: AppColors.pastel1,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),

                      child:
                          category.imageUrl != null &&
                              category.imageUrl!.isNotEmpty
                          ? Image.network(category.imageUrl!, fit: BoxFit.cover)
                          : const Icon(
                              Icons.category,
                              size: 28,
                              color: AppColors.accent1,
                            ),
                    ),
                  ),

                  title: Text(category.name, style: AppTextStyles.heading3),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),

                    child: Text(
                      category.isActive == true
                          ? 'Đang hoạt động'
                          : 'Ngưng hoạt động',

                      style: AppTextStyles.bodyMuted.copyWith(fontSize: 13),
                    ),
                  ),

                  trailing: IconButton(
                    onPressed: () {
                      _showCategoryActions(context, category);
                    },

                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // =========================
  // ACTIONS
  // =========================

  void _showCategoryActions(BuildContext context, CategoryModel category) {
    showModalBottomSheet(
      context: context,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      builder: (bottomSheetContext) {
        return Padding(
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

              Text(category.name, style: AppTextStyles.heading3),

              const SizedBox(height: 16),

              _buildOptionTile(
                Icons.edit_outlined,
                'Chỉnh sửa danh mục',
                AppColors.accent2,
                () {
                  Navigator.pop(bottomSheetContext);

                  _showCategoryDialog(context, category: category);
                },
              ),

              _buildOptionTile(
                Icons.delete_outline_rounded,
                'Xóa danh mục',
                AppColors.statusCancelledText,
                () async {
                  Navigator.pop(bottomSheetContext);

                  try {
                    await Provider.of<CategoryProvider>(
                      context,
                      listen: false,
                    ).deleteCategory(category.categoryId);

                    if (mounted) {
                      AppSnackbar.showSuccess(
                        context,
                        "Xóa danh mục thành công",
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      AppSnackbar.showError(context, 'Lỗi: $e');
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,

      contentPadding: EdgeInsets.zero,

      leading: Icon(icon, color: color),

      title: Text(title, style: AppTextStyles.body),
    );
  }

  // =========================
  // CREATE + UPDATE
  // =========================

  void _showCategoryDialog(BuildContext context, {CategoryModel? category}) {
    final provider = context.read<CategoryProvider>();

    final nameController = TextEditingController(text: category?.name ?? '');

    final imageController = TextEditingController(
      text: category?.imageUrl ?? '',
    );

    bool isActive = category?.isActive ?? true;

    showDialog(
      context: context,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              title: Text(
                category == null ? 'Danh mục mới' : 'Cập nhật danh mục',

                style: AppTextStyles.heading3,
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    TextField(
                      controller: nameController,

                      decoration: InputDecoration(
                        hintText: 'Tên danh mục',

                        filled: true,
                        fillColor: AppColors.surface,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),

                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: imageController,

                      decoration: InputDecoration(
                        hintText: 'Image URL',

                        filled: true,
                        fillColor: AppColors.surface,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),

                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SwitchListTile(
                      value: isActive,

                      title: const Text('Hoạt động'),

                      onChanged: (value) {
                        setState(() {
                          isActive = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },

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

                  onPressed: () async {
                    try {
                      final newCategory = CategoryModel(
                        categoryId: category?.categoryId ?? 0,

                        name: nameController.text.trim(),

                        imageUrl: imageController.text.trim().isEmpty
                            ? category?.imageUrl
                            : imageController.text.trim(),

                        isActive: isActive,
                      );

                      if (category == null) {
                        await provider.createCategory(newCategory);
                      } else {
                        Map<String, dynamic> data = {
                          // luôn gửi name
                          'name': nameController.text.trim(),
                        };

                        // image
                        if (imageController.text.trim() !=
                            (category.imageUrl ?? '')) {
                          data['imageUrl'] = imageController.text.trim();
                        }

                        // active
                        if (isActive != category.isActive) {
                          data['isActive'] = isActive;
                        }

                        // không có thay đổi gì ngoài name mặc định
                        final onlyNameUnchanged =
                            data.length == 1 && data['name'] == category.name;

                        if (onlyNameUnchanged) {
                          AppSnackbar.showInfo(context, 'Không có thay đổi');

                          return;
                        }

                        await provider.updateCategory(
                          category.categoryId,
                          data,
                        );
                      }

                      if (mounted) {
                        Navigator.pop(dialogContext);

                        AppSnackbar.showSuccess(
                          context,
                          category == null
                              ? 'Thêm danh mục thành công'
                              : 'Cập nhật danh mục thành công',
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                    }
                  },

                  child: Text(
                    category == null ? 'Thêm' : 'Lưu',

                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
