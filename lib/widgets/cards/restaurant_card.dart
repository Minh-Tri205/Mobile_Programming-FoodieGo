import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/restaurant_model.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final Color bgColor;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image area
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                restaurant.emoji,
                style: const TextStyle(fontSize: 56),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Tags
                  Wrap(
                    spacing: 6,
                    children: restaurant.tags
                        .map((tag) => _buildTag(tag))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  // Meta info
                  Row(
                    children: [
                      _buildMeta('⭐ ${restaurant.rating}'),
                      const SizedBox(width: 14),
                      _buildMeta('🕐 ${restaurant.deliveryMinutes} phút'),
                      const SizedBox(width: 14),
                      _buildMeta('🚚 ${restaurant.deliveryFee}'),
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

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.pastel1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.accent1,
        ),
      ),
    );
  }

  Widget _buildMeta(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
    );
  }
}
