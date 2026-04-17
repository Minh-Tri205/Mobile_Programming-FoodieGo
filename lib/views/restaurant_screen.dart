import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/restaurant_model.dart';
import '../../widgets/cards/restaurant_card.dart';
import '../../widgets/common/back_button_widget.dart';
import '../../widgets/common/category_chip.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  int _selectedCat = 0;
  final List<String> _cats = ['Tất cả', 'Việt Nam', 'Nhật Bản', 'Hàn Quốc', 'Fast food'];
  final List<Color> _bgColors = [
    AppColors.pastel1,
    AppColors.pastel3,
    AppColors.pastel4,
    AppColors.pastel2,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  BackButtonWidget(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Nhà hàng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '32 nhà hàng gần bạn',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _cats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) => CategoryChip(
                  label: _cats[i],
                  isActive: _selectedCat == i,
                  onTap: () => setState(() => _selectedCat = i),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: RestaurantModel.sampleRestaurants.length,
                itemBuilder: (context, i) => RestaurantCard(
                  restaurant: RestaurantModel.sampleRestaurants[i],
                  bgColor: _bgColors[i % _bgColors.length],
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.foodDetail,
                    arguments: null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
