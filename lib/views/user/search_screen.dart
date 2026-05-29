// lib/views/user/search_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/providers/food_provider.dart';
import '../../../models/food_model.dart';
import '../../../widgets/navigation/app_bottom_nav.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  // Trending keywords — gợi ý nhanh khi chưa search
  static const List<_Trending> _trendingItems = [
    _Trending('🍜', 'Phở Bò', AppColors.pastel1, AppColors.accent1),
    _Trending('🍲', 'Bún Bò', AppColors.pastel2, AppColors.accent2),
    _Trending('🍚', 'Cơm Sườn', AppColors.pastel3, AppColors.accent3),
    _Trending('🥤', 'Trà Đào', AppColors.pastel4, AppColors.accent4),
    _Trending('☕', 'Cà Phê', AppColors.pastel5, AppColors.accent5),
    _Trending('🍗', 'Cơm Gà', AppColors.pastel1, AppColors.accent1),
    _Trending('🍕', 'Pizza', AppColors.pastel3, AppColors.accent3),
    _Trending('🍔', 'Burger', AppColors.pastel4, AppColors.accent4),
  ];

  // Lịch sử search trong session (in-memory)
  final List<String> _recent = [];

  @override
  void initState() {
    super.initState();
    // Load food list để có dữ liệu cho search client-side
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FoodProvider>();
      if (provider.foods.isEmpty) {
        provider.fetchFoods();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      context.read<FoodProvider>().search(value);
      setState(() {}); // refresh UI for show/hide states
    });
  }

  void _submitSearch(String value) {
    if (value.trim().isEmpty) return;
    if (!_recent.contains(value)) {
      setState(() {
        _recent.insert(0, value);
        if (_recent.length > 6) _recent.removeLast();
      });
    }
    context.read<FoodProvider>().search(value);
  }

  void _setQuery(String q) {
    _controller.text = q;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: q.length),
    );
    _submitSearch(q);
  }

  void _clearQuery() {
    _controller.clear();
    context.read<FoodProvider>().clearSearch();
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final hasQuery = _controller.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 4),
            Expanded(
              child: hasQuery ? _buildResults() : _buildIdle(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  // =========================================================
  // SEARCH BAR
  // =========================================================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Search input
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: false,
                onChanged: _onChanged,
                onSubmitted: _submitSearch,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm món, nhà hàng...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.accent1,
                    size: 22,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.cancel_rounded,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: _clearQuery,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent1, Color(0xFFFFAB7E)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent1.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // IDLE STATE — trending + recent
  // =========================================================
  Widget _buildIdle() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_recent.isNotEmpty) ...[
            _sectionHeader('Tìm kiếm gần đây', actionLabel: 'Xoá', onAction: () {
              setState(() => _recent.clear());
            }),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recent
                  .map(
                    (k) => GestureDetector(
                      onTap: () => _setQuery(k),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.history_rounded,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              k,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Trending
          _sectionHeader('Xu hướng tìm kiếm'),
          const SizedBox(height: 4),
          const Text(
            'Những món được tìm kiếm nhiều nhất hôm nay',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _trendingItems
                .map(
                  (t) => GestureDetector(
                    onTap: () => _setQuery(t.label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: t.bg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t.emoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            t.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: t.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 28),

          // Popular foods preview
          _sectionHeader('Phổ biến hôm nay'),
          const SizedBox(height: 12),
          Consumer<FoodProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.foods.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final popular = provider.topPopular(limit: 4);
              if (popular.isEmpty) {
                return _emptyHint('Chưa có món nào');
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: popular.length,
                itemBuilder: (_, i) => _buildFoodCard(popular[i]),
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // RESULTS STATE
  // =========================================================
  Widget _buildResults() {
    return Consumer<FoodProvider>(
      builder: (context, provider, _) {
        if (provider.isSearching && provider.searchResults.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = provider.searchResults;

        if (results.isEmpty) {
          return _buildNoResults();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pastel3,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${results.length} kết quả',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'cho "${provider.query}"',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: results.length,
                itemBuilder: (_, i) => _buildFoodCard(results[i]),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // FOOD CARD
  // =========================================================
  Widget _buildFoodCard(FoodModel food) {
    return GestureDetector(
      onTap: () {
        context.read<FoodProvider>().setSelectedFood(food);
        Navigator.pushNamed(
          context,
          AppRoutes.foodDetail,
          arguments: food,
        );
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
            // Image
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildFoodImage(food),
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
            // Info
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
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.accent1,
                                Color(0xFFFFAB7E),
                              ],
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

  Widget _buildFoodImage(FoodModel food) {
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

  // =========================================================
  // EMPTY / NO RESULTS
  // =========================================================
  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.pastel1,
                    AppColors.pastel5.withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('🔎', style: TextStyle(fontSize: 56)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Không tìm thấy món nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Thử từ khoá khác hoặc kiểm tra chính tả nhé!',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyHint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _sectionHeader(
    String title, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.accent1,
              ),
            ),
          ),
      ],
    );
  }
}

class _Trending {
  final String emoji;
  final String label;
  final Color bg;
  final Color accent;
  const _Trending(this.emoji, this.label, this.bg, this.accent);
}
