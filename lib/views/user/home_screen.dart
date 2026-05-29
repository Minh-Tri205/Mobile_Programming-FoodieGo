// lib/views/user/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/providers/food_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../models/category_model.dart';
import '../../../models/food_model.dart';
import '../../../widgets/navigation/app_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _pageSize = 6; // Số item load mỗi lần
  final ScrollController _scrollController = ScrollController();
  int _visibleCount = _pageSize;
  bool _loadingMore = false;
  int? _lastCategoryId; // detect đổi category để reset paging

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final foodProv = context.read<FoodProvider>();
      final catProv = context.read<CategoryProvider>();
      if (foodProv.foods.isEmpty) foodProv.fetchFoods();
      if (catProv.categories.isEmpty) catProv.fetchCategories();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    // Trigger khi còn 300px nữa là đến đáy
    if (pos.pixels >= pos.maxScrollExtent - 300 && !_loadingMore) {
      _loadMore();
    }
  }

  void _loadMore() {
    final foodProv = context.read<FoodProvider>();
    final total = foodProv.publicVisibleFoods.length;
    if (_visibleCount >= total) return; // hết data

    setState(() => _loadingMore = true);
    // Giả lập delay nhẹ để user thấy spinner — data đã sẵn ở client
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _visibleCount = (_visibleCount + _pageSize).clamp(0, total);
        _loadingMore = false;
      });
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

  Future<void> _refresh() async {
    await Future.wait([
      context.read<FoodProvider>().fetchFoods(),
      context.read<CategoryProvider>().fetchCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent1,
          onRefresh: _refresh,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildPromoBanner(),
                const SizedBox(height: 8),
                _buildSectionTitle('Danh mục', subtitle: 'Khám phá theo loại'),
                const SizedBox(height: 8),
                _buildCategories(),
                const SizedBox(height: 16),
                _buildSectionTitle(
                  '🔥 Phổ biến hôm nay',
                  subtitle: 'Top món được order nhiều nhất',
                ),
                const SizedBox(height: 8),
                _buildPopularRow(),
                const SizedBox(height: 16),
                _buildSectionTitle(
                  'Thực đơn cho bạn',
                  subtitle: 'Đa dạng món ngon mỗi ngày',
                ),
                const SizedBox(height: 8),
                _buildFoodGrid(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  // =========================================================
  // HEADER với greeting + notification + search
  // =========================================================
  Widget _buildHeader() {
    return Consumer<UserProvider>(
      builder: (context, userProv, _) {
        final name = userProv.currentUser?.fullName.split(' ').last ?? 'bạn';
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào, $name 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Hôm nay bạn muốn ăn gì?',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.notifications),
                    child: Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.accent1,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.accent1,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.card,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Search bar (tap → search screen)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: AppColors.accent1,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Tìm món, nhà hàng...',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accent1, Color(0xFFFFAB7E)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // PROMO BANNER
  // =========================================================
  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent1, Color(0xFFFFAB7E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent1.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'GIAM10K',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Giảm 10.000đ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Cho đơn hàng từ 50.000đ',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Đặt ngay',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent1,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.accent1,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Text('🎉', style: TextStyle(fontSize: 64)),
        ],
      ),
    );
  }

  // =========================================================
  // SECTION TITLE
  // =========================================================
  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // CATEGORY CHIPS — server data
  // =========================================================
  Widget _buildCategories() {
    return Consumer2<CategoryProvider, FoodProvider>(
      builder: (context, catProv, foodProv, _) {
        // Chỉ hiển thị category đang hoạt động (isActive == true)
        // isActive null xem như true để tránh ẩn nhầm khi backend không trả field
        final activeCats = catProv.categories
            .where((c) => c.isActive ?? true)
            .toList();
        final cats = <CategoryModel?>[null, ...activeCats];
        return SizedBox(
          height: 44,
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
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [AppColors.accent1, Color(0xFFFFAB7E)],
                          )
                        : null,
                    color: isActive ? null : AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.accent1.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
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
  // POPULAR ROW (horizontal)
  // =========================================================
  Widget _buildPopularRow() {
    return Consumer<FoodProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading && prov.foods.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final popular = prov.topPopular(limit: 6);
        if (popular.isEmpty) return _emptyHint('Chưa có món phổ biến');

        return SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: popular.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _buildPopularCard(popular[i]),
          ),
        );
      },
    );
  }

  Widget _buildPopularCard(FoodModel food) {
    return GestureDetector(
      onTap: () {
        context.read<FoodProvider>().setSelectedFood(food);
        Navigator.pushNamed(context, AppRoutes.foodDetail, arguments: food);
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    height: 110,
                    width: double.infinity,
                    child: _buildImage(food),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFC95C),
                            size: 11,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            food.avgRating > 0
                                ? food.avgRating.toStringAsFixed(1)
                                : 'Mới',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Đã bán ${food.totalSold}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatMoney(food.price),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent1,
                          ),
                        ),
                      ),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accent1, Color(0xFFFFAB7E)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
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

  // =========================================================
  // FOOD GRID — visibleFoods (đã filter theo category)
  // =========================================================
  Widget _buildFoodGrid() {
    return Consumer<FoodProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading && prov.foods.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (prov.error != null && prov.foods.isEmpty) {
          return _emptyHint('Lỗi tải: ${prov.error}');
        }

        final list = prov.publicVisibleFoods;
        if (list.isEmpty) return _emptyHint('Không có món nào');

        // Đổi category → reset paging về trang đầu
        if (prov.selectedCategoryId != _lastCategoryId) {
          _lastCategoryId = prov.selectedCategoryId;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _visibleCount = _pageSize;
                _loadingMore = false;
              });
            }
          });
        }

        final visible = list.take(_visibleCount).toList();
        final hasMore = _visibleCount < list.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: visible.length,
                itemBuilder: (_, i) => _buildFoodCard(visible[i]),
              ),
              if (hasMore) _buildLoadMoreFooter(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFoodCard(FoodModel food) {
    return GestureDetector(
      onTap: () {
        context.read<FoodProvider>().setSelectedFood(food);
        Navigator.pushNamed(context, AppRoutes.foodDetail, arguments: food);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(food),
                    if (food.avgRating > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Color(0xFFFFC95C),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                food.avgRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (!food.inStock)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          alignment: Alignment.center,
                          child: const Text(
                            'HẾT HÀNG',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (food.categoryName.isNotEmpty)
                      Text(
                        food.categoryName,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent2,
                          letterSpacing: 0.3,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        food.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _formatMoney(food.price),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accent1, Color(0xFFFFAB7E)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(FoodModel food) {
    final url = food.imageUrl;
    final letter = _firstLetter(food.name);
    if (url == null || url.isEmpty) return _initialImage(letter);
    final isNet = url.startsWith('http');
    return isNet
        ? Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialImage(letter),
          )
        : Image.asset(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialImage(letter),
          );
  }

  Widget _initialImage(String letter) {
    return Container(
      color: AppColors.pastel1,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: AppColors.accent1,
        ),
      ),
    );
  }

  // Footer dưới grid: spinner khi đang load thêm,
  // hoặc nút "Xem thêm" để user chủ động tải tiếp nếu chưa kịp scroll trigger
  Widget _buildLoadMoreFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
      child: Center(
        child: _loadingMore
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.accent1,
                ),
              )
            : GestureDetector(
                onTap: _loadMore,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pastel1,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Xem thêm',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent1,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.accent1,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _emptyHint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
