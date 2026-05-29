// lib/views/user/food_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/providers/food_provider.dart';
import '../../../models/food_model.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({super.key});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 1;
  bool _isFavorite = false;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      Future.microtask(() {
        if (!mounted) return;
        context.read<FoodProvider>().fetchFoodById(args);
      });
    } else if (args is FoodModel) {
      Future.microtask(() {
        if (!mounted) return;
        context.read<FoodProvider>().setSelectedFood(args);
      });
    }
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

  FoodModel _resolveFood(FoodProvider provider) {
    if (provider.selectedFood != null) return provider.selectedFood!;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is FoodModel) return args;
    return FoodModel.sampleFoods.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<FoodProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingDetail && provider.selectedFood == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final food = _resolveFood(provider);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHero(food),
                      _buildBody(food),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              _buildAddToCartBar(food),
            ],
          );
        },
      ),
    );
  }

  // =========================================================
  // HERO — image với gradient overlay + back/favorite floating
  // =========================================================
  Widget _buildHero(FoodModel food) {
    final letter = _firstLetter(food.name);
    return Stack(
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: _buildHeroImage(food, letter),
        ),
        // Gradient overlay
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.transparent,
                    AppColors.background,
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleIcon(
                  Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                _circleIcon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                  iconColor: _isFavorite ? AppColors.accent1 : null,
                  onTap: () => setState(() => _isFavorite = !_isFavorite),
                ),
              ],
            ),
          ),
        ),
        if (!food.inStock)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.statusCancelled,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '⚠️ HẾT HÀNG',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.statusCancelledText,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeroImage(FoodModel food, String letter) {
    final url = food.imageUrl;
    if (url == null || url.isEmpty) return _initialHero(letter);
    final isNet = url.startsWith('http');
    return isNet
        ? Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialHero(letter),
          )
        : Image.asset(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialHero(letter),
          );
  }

  Widget _initialHero(String letter) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.pastel1, AppColors.pastel5],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 140,
          fontWeight: FontWeight.w800,
          color: AppColors.accent1.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _circleIcon(
    IconData icon, {
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.textPrimary,
          size: 18,
        ),
      ),
    );
  }

  // =========================================================
  // BODY — info + description + stats
  // =========================================================
  Widget _buildBody(FoodModel food) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (food.categoryName.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pastel2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  food.categoryName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent2,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              food.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickStats(food),
            const SizedBox(height: 18),
            // Description
            if (food.description != null && food.description!.isNotEmpty) ...[
              const Text(
                'Mô tả',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                food.description!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
            ],
            _buildQuantityRow(food),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(FoodModel food) {
    return Row(
      children: [
        _statChip(
          icon: Icons.star_rounded,
          color: AppColors.accent4,
          label: food.avgRating > 0
              ? food.avgRating.toStringAsFixed(1)
              : 'Mới',
        ),
        const SizedBox(width: 8),
        _statChip(
          icon: Icons.local_fire_department_rounded,
          color: AppColors.accent1,
          label: 'Đã bán ${food.totalSold}',
        ),
        const SizedBox(width: 8),
        _statChip(
          icon: Icons.inventory_2_outlined,
          color: food.inStock ? AppColors.accent3 : AppColors.statusCancelledText,
          label: food.inStock ? 'Còn ${food.stockQuantity}' : 'Hết hàng',
        ),
      ],
    );
  }

  Widget _statChip({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityRow(FoodModel food) {
    return Row(
      children: [
        const Text(
          'Số lượng',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _qtyBtn(
                Icons.remove_rounded,
                onTap: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '$_quantity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _qtyBtn(
                Icons.add_rounded,
                onTap: () {
                  if (_quantity < (food.inStock ? food.stockQuantity : 99)) {
                    setState(() => _quantity++);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: AppColors.accent1),
      ),
    );
  }

  // =========================================================
  // BOTTOM BAR — total + add to cart
  // =========================================================
  Widget _buildAddToCartBar(FoodModel food) {
    final total = food.price * _quantity;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatMoney(total),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent1,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: food.inStock
                  ? () => Navigator.pushNamed(context, AppRoutes.cart)
                  : null,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: food.inStock
                      ? const LinearGradient(
                          colors: [AppColors.accent1, Color(0xFFFFAB7E)],
                        )
                      : null,
                  color: food.inStock ? null : AppColors.divider,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: food.inStock
                      ? [
                          BoxShadow(
                            color: AppColors.accent1.withOpacity(0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_shopping_cart_rounded,
                      color: food.inStock ? Colors.white : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      food.inStock ? 'Thêm vào giỏ' : 'Hết hàng',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: food.inStock
                            ? Colors.white
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
