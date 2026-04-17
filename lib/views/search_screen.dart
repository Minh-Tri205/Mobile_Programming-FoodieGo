import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/food_model.dart';
import '../../models/restaurant_model.dart';
import '../../widgets/navigation/app_bottom_nav.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> _trending = [
    {'label': 'Bún bò', 'color': AppColors.pastel1, 'accent': AppColors.accent1},
    {'label': 'Pizza', 'color': AppColors.pastel2, 'accent': AppColors.accent2},
    {'label': 'Sushi', 'color': AppColors.pastel3, 'accent': AppColors.accent3},
    {'label': 'Trà sữa', 'color': AppColors.pastel4, 'accent': AppColors.accent4},
    {'label': 'Cơm tấm', 'color': AppColors.pastel5, 'accent': AppColors.accent5},
    {'label': 'Phở', 'color': AppColors.pastel1, 'accent': AppColors.accent1},
  ];

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

                  // SEARCH BOX
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Tìm món ăn, nhà hàng...',

                        // ❌ bỏ emoji 🔍 → dùng Icon chuẩn
                        prefixIcon: const Icon(Icons.search),

                        suffixIcon: GestureDetector(
                          onTap: () => Navigator.pop(context),

                          // ❌ bỏ ✕ → dùng icon
                          child: const Icon(Icons.close,
                              color: AppColors.textMuted),
                        ),

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
                    _buildSectionLabel('Xu hướng tìm kiếm'),
                    _buildTrendingChips(),

                    _buildSectionLabel('Nhà hàng nổi bật'),
                    _buildRestaurantItem(
                      RestaurantModel.sampleRestaurants[0],
                      AppColors.pastel1,
                    ),
                    _buildRestaurantItem(
                      RestaurantModel.sampleRestaurants[1],
                      AppColors.pastel2,
                    ),

                    _buildSectionLabel('Món ăn phổ biến'),
                    _buildFoodListItem(
                      FoodModel.sampleFoods[2],
                      AppColors.pastel3,
                    ),
                    _buildFoodListItem(
                      FoodModel.sampleFoods[3],
                      AppColors.pastel4,
                    ),

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
            onTap: () => Navigator.pushNamed(context, AppRoutes.restaurant),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
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

  Widget _buildRestaurantItem(RestaurantModel r, Color bg) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.restaurant),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE THAY EMOJI
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: Image.asset(
                getRestaurantImage(r.name),
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${r.rating}',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 14),
                      Text('${r.deliveryMinutes} phút',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
            // IMAGE THAY EMOJI
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                food.imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
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
                    ),
                  ),
                  Text(
                    '${food.restaurantName} • ${food.rating}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            Text(
              '${(food.price / 1000).toStringAsFixed(0)}k',
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

// MAP IMAGE (giống file trước)
String getRestaurantImage(String name) {
  if (name.contains('Phở')) return 'assets/images/pho.jpg';
  if (name.contains('Sakura')) return 'assets/images/sushi.jpg';
  if (name.contains('Domino')) return 'assets/images/pizza.jpg';
  if (name.contains('KFC')) return 'assets/images/kfc.jpg';
  return 'assets/images/default.jpg';
}