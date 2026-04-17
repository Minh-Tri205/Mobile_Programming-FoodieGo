import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/food_model.dart';
import '../../widgets/common/primary_button.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({super.key});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 1;
  bool _isFavorite = false;

  final List<Map<String, String>> _reviews = [
    {
      'name': 'Nguyễn Lan Anh',
      'emoji': '👩',
      'rating': '⭐⭐⭐⭐⭐',
      'comment': 'Ngon tuyệt vời! Nước dùng đậm đà, thịt mềm. Sẽ đặt lại lần nữa.',
    },
    {
      'name': 'Trần Minh Khoa',
      'emoji': '👨',
      'rating': '⭐⭐⭐⭐',
      'comment': 'Giao hàng nhanh, đồ ăn còn nóng. Rất hài lòng!',
    },
    {
      'name': 'Lê Thị Hoa',
      'emoji': '🧑',
      'rating': '⭐⭐⭐⭐⭐',
      'comment': 'Đặc sản thật sự, hương vị chuẩn miền Trung.',
    },
  ];

  final List<Color> _reviewAvatarColors = [
    AppColors.pastel1,
    AppColors.pastel2,
    AppColors.pastel5,
  ];

  @override
  Widget build(BuildContext context) {
    final food = (ModalRoute.of(context)?.settings.arguments as FoodModel?) ??
        FoodModel.sampleFoods[0];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHero(context, food),
                  _buildBody(food),
                ],
              ),
            ),
          ),
          _buildAddToCartBar(context, food),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, FoodModel food) {
    return Stack(
      children: [
        // IMAGE THAY EMOJI
        SizedBox(
          height: 240,
          width: double.infinity,
          child: Image.asset(
            food.imageUrl,
            fit: BoxFit.cover,
          ),
        ),

        // overlay nhẹ cho dễ nhìn
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
          ),
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isFavorite = !_isFavorite),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(FoodModel food) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  food.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.pastel3,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${food.rating}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            food.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metaChip('${food.deliveryMinutes}-${food.deliveryMinutes + 10} phút'),
              const SizedBox(width: 14),
              _metaChip('${food.calories} cal'),
              const SizedBox(width: 14),
              _metaChip('${food.rating} (${food.reviewCount})'),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(food.price / 1000).toStringAsFixed(0)}.000đ',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent1,
                ),
              ),
              _buildQtyControl(),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Đánh giá khách hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          ...List.generate(_reviews.length, (i) => _buildReviewItem(i)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _metaChip(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 13, color: AppColors.textMuted));
  }

  Widget _buildQtyControl() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.pastel1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_quantity > 1) setState(() => _quantity--);
            },
            child: _circleButton('−'),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$_quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _quantity++),
            child: _circleButton('+'),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(String text) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: AppColors.accent1,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 18)),
    );
  }

  Widget _buildReviewItem(int index) {
    final r = _reviews[index];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                _reviewAvatarColors[index % _reviewAvatarColors.length],
            child: Text(r['name']![0]), // chữ cái đầu thay avatar
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['name']!),
                Text(r['rating']!),
                Text(r['comment']!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartBar(BuildContext context, FoodModel food) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: PrimaryButton(
        label:
            'Thêm vào giỏ hàng  •  ${((food.price * _quantity) / 1000).toStringAsFixed(0)}.000đ',
        onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
      ),
    );
  }
}