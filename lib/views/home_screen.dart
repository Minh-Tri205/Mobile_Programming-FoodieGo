// lib/views/home_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/food_model.dart';
import '../../widgets/cards/food_card.dart';
import '../../widgets/common/category_chip.dart';
import '../../widgets/navigation/app_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;

  // Danh mục khớp với bảng categories trong SQL
  final List<String> _categories = [
    'Tất cả',
    'Món Nước',
    'Cơm Văn Phòng',
    'Đồ Uống',
  ];

  final List<Color> _foodBgColors = [
    AppColors.pastel1,
    AppColors.pastel2,
    AppColors.pastel3,
    AppColors.pastel4,
  ];

  List<FoodModel> get _filteredFoods {
    if (_selectedCategory == 0) return FoodModel.sampleFoods;
    final cat = _categories[_selectedCategory];
    return FoodModel.sampleFoods
        .where((f) => f.categoryName == cat)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPromoBanner(),
                    _buildSectionTitle('Danh mục'),
                    _buildCategories(),
                    _buildSectionTitle('Thực đơn'),
                    _buildFoodGrid(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào! 👋',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Hôm nay bạn muốn ăn gì?',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                child: Stack(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColors.pastel1,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.notifications_outlined,
                          color: AppColors.textPrimary),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.accent1,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.search),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.textMuted, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Tìm kiếm món ăn...',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.pastel1, AppColors.pastel4],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mã giảm giá GIAM10K!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Giảm 10.000đ cho đơn từ 50.000đ',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accent1,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Đặt ngay →',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Text('🎉', style: TextStyle(fontSize: 52)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return CategoryChip(
            label: _categories[index],
            isActive: _selectedCategory == index,
            onTap: () => setState(() => _selectedCategory = index),
          );
        },
      ),
    );
  }

  Widget _buildFoodGrid() {
    final foods = _filteredFoods;
    if (foods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text('Không có món nào.',
              style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          return FoodCard(
            food: foods[index],
            bgColor: _foodBgColors[index % _foodBgColors.length],
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.foodDetail,
              arguments: foods[index],
            ),
          );
        },
      ),
    );
  }
}