// lib/views/search_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../models/food_model.dart';
import '../../../widgets/navigation/app_bottom_nav.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  // Xu hướng tìm kiếm — khớp với categoryName trong food_model
  final List<Map<String, dynamic>> _trending = [
    {'label': 'Phở Bò', 'color': AppColors.pastel1, 'accent': AppColors.accent1},
    {'label': 'Bún Bò', 'color': AppColors.pastel2, 'accent': AppColors.accent2},
    {'label': 'Cơm Sườn', 'color': AppColors.pastel3, 'accent': AppColors.accent3},
    {'label': 'Trà Đào', 'color': AppColors.pastel4, 'accent': AppColors.accent4},
    {'label': 'Cà Phê', 'color': AppColors.pastel5, 'accent': AppColors.accent5},
    {'label': 'Cơm Gà', 'color': AppColors.pastel1, 'accent': AppColors.accent1},
  ];

  // Lọc món ăn theo từ khoá tìm kiếm
  List<FoodModel> get _searchResults {
    if (_query.isEmpty) return [];
    return FoodModel.sampleFoods
        .where((f) =>
            f.name.toLowerCase().contains(_query.toLowerCase()) ||
            f.categoryName.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tìm kiếm',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _controller,
                      onChanged: (val) => setState(() => _query = val),
                      decoration: InputDecoration(
                        hintText: 'Tìm món ăn...',
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textMuted),
                        suffixIcon: _query.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _controller.clear();
                                  setState(() => _query = '');
                                },
                                child: const Icon(Icons.close,
                                    color: AppColors.textMuted),
                              )
                            : null,
                        border: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hiện kết quả tìm kiếm nếu có query
                    if (_query.isNotEmpty) ...[
                      _buildSectionLabel(
                          'Kết quả cho "${_query}"'),
                      if (_searchResults.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'Không tìm thấy món ăn phù hợp',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        )
                      else
                        ..._searchResults.map(
                          (food) => _buildFoodListItem(
                            food,
                            AppColors.pastel1,
                          ),
                        ),
                    ] else ...[
                      // Màn hình mặc định khi chưa tìm kiếm
                      _buildSectionLabel('Xu hướng tìm kiếm'),
                      _buildTrendingChips(),
                      _buildSectionLabel('Món phổ biến'),
                      // Sắp xếp theo total_sold — khớp SQL
                      ...(() {
                        final sorted = [...FoodModel.sampleFoods]
                          ..sort((a, b) => b.totalSold.compareTo(a.totalSold));
                        return sorted
                            .take(4)
                            .map((food) => _buildFoodListItem(
                                  food,
                                  AppColors.pastel1,
                                ));
                      })(),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildTrendingChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _trending.map((item) {
          return GestureDetector(
            onTap: () {
              // Tìm kiếm khi bấm chip
              _controller.text = item['label'] as String;
              setState(() => _query = item['label'] as String);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: item['color'] as Color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                item['label'] as String,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: item['accent'] as Color,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFoodListItem(FoodModel food, Color bg) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.foodDetail,
        arguments: food,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Ảnh món ăn — xử lý nullable imageUrl
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: food.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        food.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.fastfood, color: AppColors.accent1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  // categoryName thay restaurantName — khớp SQL
                  Text(
                    '${food.categoryName}  •  🔥 Đã bán ${food.totalSold}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Text(
              '${(food.price / 1000).toStringAsFixed(0)}.000đ',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.accent1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}