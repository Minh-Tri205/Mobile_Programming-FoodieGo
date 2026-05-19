import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/promotion_model.dart';
import '../../../widgets/common/back_button_widget.dart';
import '../../../widgets/common/primary_button.dart';

class PromotionsListScreen extends StatefulWidget {
  const PromotionsListScreen({super.key});

  @override
  State<PromotionsListScreen> createState() => _PromotionsListScreenState();
}

class _PromotionsListScreenState extends State<PromotionsListScreen> {
  late List<PromotionModel> _promotions;
  final _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _promotions = List.from(PromotionModel.samplePromotions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchPromotions(String query) {
    setState(() {
      if (query.isEmpty) {
        _promotions = List.from(PromotionModel.samplePromotions);
      } else {
        _promotions = PromotionModel.samplePromotions
            .where((p) =>
                p.name.toLowerCase().contains(query.toLowerCase()) ||
                p.description?.toLowerCase().contains(query.toLowerCase()) == true)
            .toList();
      }
      _currentPage = 1;
    });
  }

  void _togglePromotionStatus(int promotionId) {
    setState(() {
      final index = _promotions.indexWhere((p) => p.promotionId == promotionId);
      if (index >= 0) {
        final promotion = _promotions[index];
        final newStatus = promotion.status == PromotionStatus.active
            ? PromotionStatus.inactive
            : PromotionStatus.active;
        _promotions[index] = PromotionModel(
          promotionId: promotion.promotionId,
          name: promotion.name,
          description: promotion.description,
          discountType: promotion.discountType,
          discountValue: promotion.discountValue,
          startDate: promotion.startDate,
          endDate: promotion.endDate,
          minOrderAmount: promotion.minOrderAmount,
          maxDiscount: promotion.maxDiscount,
          usageLimit: promotion.usageLimit,
          usageCount: promotion.usageCount,
          status: newStatus,
          createdAt: promotion.createdAt,
          updatedAt: DateTime.now(),
        );
      }
    });
  }

  void _deletePromotion(int promotionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xóa khuyến mãi?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
          'Bạn chắc chắn muốn xóa khuyến mãi này? Hành động không thể hoàn tác.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCancelledText,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _promotions.removeWhere((p) => p.promotionId == promotionId);
              });
              _showSnackBar('✅ Khuyến mãi đã được xóa');
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages =
        (_promotions.isEmpty ? 1 : (_promotions.length / _itemsPerPage).ceil());
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex =
        (startIndex + _itemsPerPage > _promotions.length
            ? _promotions.length
            : startIndex + _itemsPerPage);
    final paginatedItems =
        _promotions.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButtonWidget(onTap: () => Navigator.pop(context)),
        title: const Text('Quản lý khuyến mãi', style: AppTextStyles.heading2),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          // Search and Add Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm khuyến mãi...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: _searchPromotions,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.accent1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    onPressed: () {
                      _showSnackBar('Tính năng thêm khuyến mãi sẽ được phát triển');
                    },
                  ),
                ),
              ],
            ),
          ),

          // Promotions List
          Expanded(
            child: _promotions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_offer_outlined,
                            size: 64, color: AppColors.divider),
                        const SizedBox(height: 16),
                        const Text(
                          'Không tìm thấy khuyến mãi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        ...paginatedItems.map((promo) =>
                            _buildPromotionCard(promo)),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),

          // Pagination
          if (_promotions.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trang $_currentPage / $totalPages',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: _currentPage > 1
                            ? () => setState(() => _currentPage--)
                            : null,
                        color: _currentPage > 1
                            ? AppColors.accent1
                            : AppColors.divider,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: _currentPage < totalPages
                            ? () => setState(() => _currentPage++)
                            : null,
                        color: _currentPage < totalPages
                            ? AppColors.accent1
                            : AppColors.divider,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(PromotionModel promo) {
    final isExpired = promo.isExpired;
    final isActive = promo.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.accent1 : AppColors.divider,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.accent1.withOpacity(0.1),
                  blurRadius: 8,
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promo.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (promo.description != null)
                      Text(
                        promo.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.3,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: promo.status.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  promo.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: promo.status.textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoBadge(
                label: 'Loại',
                value: promo.discountType.label,
              ),
              _buildInfoBadge(
                label: 'Giá trị',
                value: promo.discountType == PromotionType.percentage
                    ? '${promo.discountValue.toStringAsFixed(0)}%'
                    : '${(promo.discountValue / 1000).toStringAsFixed(0)}.000đ',
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bắt đầu: ${promo.startDate.day}/${promo.startDate.month}/${promo.startDate.year}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      'Kết thúc: ${promo.endDate.day}/${promo.endDate.month}/${promo.endDate.year}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isExpired
                            ? AppColors.statusCancelledText
                            : AppColors.textMuted,
                        fontWeight: isExpired ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      promo.status == PromotionStatus.active
                          ? Icons.pause_circle_rounded
                          : Icons.play_circle_rounded,
                      color: AppColors.accent1,
                    ),
                    onPressed: () =>
                        _togglePromotionStatus(promo.promotionId),
                    tooltip: 'Bật/Tắt',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded,
                        color: AppColors.accent1),
                    onPressed: () {
                      _showSnackBar('Tính năng chỉnh sửa sẽ được phát triển');
                    },
                    tooltip: 'Chỉnh sửa',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded,
                        color: AppColors.statusCancelledText),
                    onPressed: () =>
                        _deletePromotion(promo.promotionId),
                    tooltip: 'Xóa',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
