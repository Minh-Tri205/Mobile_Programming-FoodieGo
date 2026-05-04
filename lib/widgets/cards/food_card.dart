// lib/widgets/cards/food_card.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/food_model.dart';

class FoodCard extends StatelessWidget {
  final FoodModel food;
  final Color bgColor;
  final VoidCallback onTap;

  const FoodCard({
    super.key,
    required this.food,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .07),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE AREA — xử lý nullable imageUrl
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: food.imageUrl != null
                  ? Image.asset(
                      food.imageUrl!, // ✅ dùng ! vì đã kiểm tra null
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 110,
                      width: double.infinity,
                      color: bgColor,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.fastfood,
                        size: 40,
                        color: AppColors.accent1,
                      ),
                    ),
            ),

            // INFO
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  // categoryName thay cho rating — khớp SQL
                  Text(
                    food.categoryName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(food.price / 1000).toStringAsFixed(0)}.000đ',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent1,
                        ),
                      ),
                      // total_sold thay rating — khớp SQL
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 12,
                            color: AppColors.accent4,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${food.totalSold}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
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
}
