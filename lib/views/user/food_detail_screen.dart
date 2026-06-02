// lib/views/user/food_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/providers/favorite_provider.dart';
import '../../../data/providers/food_provider.dart';
import '../../../data/providers/review_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../models/food_model.dart';
import '../../../models/review_model.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({super.key});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 1;
  bool _loaded = false;
  bool _togglingFavorite = false;

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

    // Đảm bảo favorites đã load để biết món này đã thích chưa
    Future.microtask(() {
      if (!mounted) return;
      final uid = context.read<UserProvider>().currentUserId;
      if (uid != null) {
        context.read<FavoriteProvider>().ensureLoadedForUser(uid);
      }
    });

    // Load reviews (de hien thi danh gia tren food detail)
    Future.microtask(() {
      if (!mounted) return;
      final reviewProv = context.read<ReviewProvider>();
      if (reviewProv.reviews.isEmpty && !reviewProv.isLoading) {
        reviewProv.fetchAll();
      }
    });
  }

  Future<void> _toggleFavorite(FoodModel food) async {
    if (_togglingFavorite) return;
    final userId = context.read<UserProvider>().currentUserId;
    if (userId == null) {
      _showSnack('Bạn cần đăng nhập', error: true);
      return;
    }
    if (food.foodId == null) return;

    setState(() => _togglingFavorite = true);
    try {
      final added =
          await context.read<FavoriteProvider>().toggle(userId, food.foodId!);
      if (mounted) {
        _showSnack(added ? 'Đã thêm vào yêu thích ❤️' : 'Đã bỏ khỏi yêu thích');
      }
    } catch (e) {
      if (mounted) _showSnack('Lỗi: $e', error: true);
    } finally {
      if (mounted) setState(() => _togglingFavorite = false);
    }
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error
            ? AppColors.statusCancelledText
            : AppColors.accent1,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
                Consumer<FavoriteProvider>(
                  builder: (ctx, favProv, _) {
                    final isFav = food.foodId != null &&
                        favProv.isFavorite(food.foodId!);
                    return _circleIcon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: isFav ? AppColors.accent1 : null,
                      onTap: () => _toggleFavorite(food),
                    );
                  },
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
            const SizedBox(height: 24),
            _buildReviewsSection(food),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(FoodModel food) {
    return Consumer<ReviewProvider>(
      builder: (context, prov, _) {
        // Tinh avg rating tu reviews thuc te cua mon nay (qua cac don da danh gia).
        // Fallback ve food.avgRating tu backend neu chua co review nao trong cache.
        double avg = 0;
        int count = 0;
        if (food.foodId != null) {
          final list = prov.ofFood(food.foodId!);
          count = list.length;
          if (count > 0) {
            avg = list.fold<int>(0, (s, r) => s + r.rating) / count;
          }
        }
        final displayAvg = count > 0 ? avg : food.avgRating;

        return Row(
          children: [
            _statChip(
              icon: Icons.star_rounded,
              color: AppColors.accent4,
              label: displayAvg > 0
                  ? displayAvg.toStringAsFixed(1)
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
              color: food.inStock
                  ? AppColors.accent3
                  : AppColors.statusCancelledText,
              label: food.inStock ? 'Còn ${food.stockQuantity}' : 'Hết hàng',
            ),
          ],
        );
      },
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
  // REVIEWS — danh sach danh gia cua mon nay
  // =========================================================
  Widget _buildReviewsSection(FoodModel food) {
    return Consumer<ReviewProvider>(
      builder: (context, prov, _) {
        if (food.foodId == null) return const SizedBox.shrink();

        if (prov.isLoading && prov.reviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final reviews = prov.ofFood(food.foodId!)
          ..sort((a, b) {
            final ad = a.createdAt ?? DateTime(2000);
            final bd = b.createdAt ?? DateTime(2000);
            return bd.compareTo(ad); // moi nhat truoc
          });

        final avg = reviews.isEmpty
            ? 0.0
            : reviews.fold<int>(0, (s, r) => s + r.rating) / reviews.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Đánh giá',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pastel4,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${reviews.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent4,
                    ),
                  ),
                ),
                const Spacer(),
                if (reviews.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: AppColors.accent4,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        avg.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent4,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (reviews.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      color: AppColors.textMuted,
                      size: 28,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Chưa có đánh giá nào',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: List.generate(
                  reviews.length > 5 ? 5 : reviews.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildReviewCard(reviews[i]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildReviewCard(ReviewModel r) {
    final name = r.userName.isNotEmpty ? r.userName : 'Khách hàng';
    final letter = _firstLetter(name);
    final avatar = r.userAvatarUrl;

    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: (avatar != null && avatar.isNotEmpty)
                      ? Image.network(
                          avatar,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _reviewLetterAvatar(letter),
                        )
                      : _reviewLetterAvatar(letter),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (r.createdAt != null)
                      Text(
                        _formatDate(r.createdAt!),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < r.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.accent4,
                    size: 14,
                  );
                }),
              ),
            ],
          ),
          if (r.comment != null && r.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              r.comment!.trim(),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _reviewLetterAvatar(String letter) {
    return Container(
      color: AppColors.pastel1,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.accent1,
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) return '${diff.inMinutes} phút trước';
      return '${diff.inHours} giờ trước';
    }
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
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
                  ? () {
                      context.read<CartProvider>().addItem(
                            food,
                            quantity: _quantity,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã thêm ${_quantity}× "${food.name}" vào giỏ',
                          ),
                          backgroundColor: AppColors.accent3,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                          action: SnackBarAction(
                            label: 'Xem giỏ',
                            textColor: Colors.white,
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.cart,
                            ),
                          ),
                        ),
                      );
                    }
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
