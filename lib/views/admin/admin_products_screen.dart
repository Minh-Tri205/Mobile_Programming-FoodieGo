// lib/views/admin/admin_products_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../data/providers/category_provider.dart';
import '../../data/providers/food_provider.dart';
import '../../models/category_model.dart';
import '../../models/food_model.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final foodProvider = context.read<FoodProvider>();
      final catProvider = context.read<CategoryProvider>();
      if (foodProvider.foods.isEmpty) foodProvider.fetchFoods();
      if (catProvider.categories.isEmpty) catProvider.fetchCategories();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() => _searchQuery = v.trim().toLowerCase());
    });
  }

  String _formatMoney(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}.000đ';
    }
    return '${amount.toStringAsFixed(0)}đ';
  }

  String _firstLetter(String s) {
    final t = s.trim();
    if (t.isEmpty) return '?';
    return t.characters.first.toUpperCase();
  }

  List<FoodModel> _applyFilters(
    List<FoodModel> foods,
    int? selectedCategoryId,
  ) {
    return foods.where((f) {
      if (selectedCategoryId != null && f.categoryId != selectedCategoryId) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !f.name.toLowerCase().contains(_searchQuery)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _buildFab(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 8),
            _buildCategoryFilter(),
            const SizedBox(height: 4),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER với title + counter
  // =========================================================
  Widget _buildHeader() {
    return Consumer<FoodProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản lý thực đơn',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Thêm, sửa, xoá món ăn của cửa hàng',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pastel1,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.fastfood_rounded,
                      size: 16,
                      color: AppColors.accent1,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${provider.foods.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(
            hintText: 'Tìm theo tên món...',
            hintStyle: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.accent1,
              size: 22,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // Category filter — dùng CategoryProvider thật
  Widget _buildCategoryFilter() {
    return Consumer2<CategoryProvider, FoodProvider>(
      builder: (context, catProv, foodProv, _) {
        final cats = <CategoryModel?>[null, ...catProv.categories];
        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = cats[i];
              final isActive = foodProv.selectedCategoryId == cat?.categoryId;
              final label = cat == null ? 'Tất cả' : cat.name;

              return GestureDetector(
                onTap: () => foodProv.selectCategory(cat?.categoryId),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [AppColors.accent1, Color(0xFFFFAB7E)],
                          )
                        : null,
                    color: isActive ? null : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: isActive
                        ? null
                        : Border.all(color: AppColors.divider),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // =========================================================
  // LIST
  // =========================================================
  Widget _buildList() {
    return Consumer<FoodProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.foods.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null && provider.foods.isEmpty) {
          return _buildError(provider.error!);
        }

        final list = _applyFilters(
          provider.visibleFoods,
          provider.selectedCategoryId,
        );

        if (list.isEmpty) {
          return _buildEmpty();
        }

        return RefreshIndicator(
          color: AppColors.accent1,
          onRefresh: () => provider.fetchFoods(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: list.length,
            itemBuilder: (_, i) => _buildProductCard(list[i]),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(FoodModel food) {
    final outOfStock = !food.inStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Opacity(
        opacity: outOfStock ? 0.7 : 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              SizedBox(
                width: 72,
                height: 72,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _buildFoodImage(food),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (food.categoryName.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.pastel2,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              food.categoryName,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent2,
                              ),
                            ),
                          ),
                        const Spacer(),
                        if (food.avgRating > 0) ...[
                          const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Color(0xFFFFC95C),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            food.avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      food.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatMoney(food.price),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          outOfStock ? 'Hết hàng' : 'Kho: ${food.stockQuantity}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: outOfStock
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: outOfStock
                                ? AppColors.statusCancelledText
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.textMuted,
                ),
                onPressed: () => _showActions(food),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodImage(FoodModel food) {
    final url = food.imageUrl;
    final letter = _firstLetter(food.name);
    if (url == null || url.isEmpty) return _initialBox(letter);
    final isNet = url.startsWith('http');
    return isNet
        ? Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialBox(letter),
          )
        : Image.asset(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialBox(letter),
          );
  }

  Widget _initialBox(String letter) {
    return Container(
      color: AppColors.pastel1,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.accent1,
        ),
      ),
    );
  }

  // =========================================================
  // BOTTOM SHEET — actions edit / toggle active / delete
  // =========================================================
  void _showActions(FoodModel food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
            const SizedBox(height: 18),
            Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildFoodImage(food),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatMoney(food.price),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            _actionRow(
              Icons.edit_outlined,
              'Chỉnh sửa món',
              AppColors.accent2,
              () {
                Navigator.pop(ctx);
                Navigator.pushNamed(
                  context,
                  AppRoutes.adminEditProduct,
                  arguments: food,
                );
              },
            ),
            _actionRow(
              food.isActive
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              food.isActive ? 'Ẩn khỏi thực đơn' : 'Hiển thị trên thực đơn',
              AppColors.accent3,
              () async {
                Navigator.pop(ctx);
                try {
                  await context.read<FoodProvider>().patchFood(
                    food.foodId!,
                    {'isActive': !food.isActive, 'foodId': food.foodId},
                  );
                  if (mounted) {
                    _toast(
                      food.isActive ? 'Đã ẩn món' : 'Đã hiển thị món',
                    );
                  }
                } catch (e) {
                  if (mounted) _toast('Lỗi: $e', error: true);
                }
              },
            ),
            _actionRow(
              Icons.delete_outline_rounded,
              'Xoá món ăn',
              AppColors.statusCancelledText,
              () async {
                Navigator.pop(ctx);
                final ok = await _confirmDelete(food.name);
                if (!ok || !mounted) return;
                try {
                  await context
                      .read<FoodProvider>()
                      .deleteFood(food.foodId!);
                  if (mounted) _toast('Đã xoá ${food.name}');
                } catch (e) {
                  if (mounted) _toast('Lỗi: $e', error: true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionRow(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
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

  Future<bool> _confirmDelete(String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Xoá món ăn?',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            content: Text('Bạn có chắc muốn xoá "$name"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Huỷ'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusCancelledText,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Xoá'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error
            ? AppColors.statusCancelledText
            : AppColors.accent3,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // =========================================================
  // FAB
  // =========================================================
  Widget _buildFab() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.adminAddProduct),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accent1, Color(0xFFFFAB7E)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent1.withOpacity(0.4),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 22),
            SizedBox(width: 6),
            Text(
              'Thêm món',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.statusCancelledText,
              size: 56,
            ),
            const SizedBox(height: 12),
            const Text(
              'Không tải được danh sách',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              msg,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<FoodProvider>().fetchFoods(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent1,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          const Text(
            'Chưa có món nào',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Bấm "Thêm món" để bắt đầu xây dựng thực đơn',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
