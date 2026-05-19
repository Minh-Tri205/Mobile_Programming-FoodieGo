import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/promotion_model.dart';

class CouponSelectorWidget extends StatelessWidget {
  final List<PromotionModel> availableCoupons;
  final PromotionModel? selectedCoupon;
  final double cartAmount;
  final Function(PromotionModel?) onCouponSelected;

  const CouponSelectorWidget({
    super.key,
    required this.availableCoupons,
    this.selectedCoupon,
    required this.cartAmount,
    required this.onCouponSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Coupon selector button
        GestureDetector(
          onTap: () => _showCouponBottomSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selectedCoupon != null
                    ? AppColors.accent1
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer_outlined,
                    size: 18, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedCoupon != null
                        ? '✅ ${selectedCoupon!.name}'
                        : 'Chọn mã giảm giá',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selectedCoupon != null
                          ? AppColors.accent1
                          : AppColors.textMuted,
                    ),
                  ),
                ),
                if (selectedCoupon != null)
                  GestureDetector(
                    onTap: () => onCouponSelected(null),
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
        ),
        // Display selected coupon details
        if (selectedCoupon != null) ...[
          const SizedBox(height: 12),
          _buildCouponDetails(selectedCoupon!),
        ],
      ],
    );
  }

  Widget _buildCouponDetails(PromotionModel coupon) {
    final discount = coupon.calculateDiscount(cartAmount);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pastel3.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent1.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                coupon.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent1,
                ),
              ),
              Text(
                'Tiết kiệm: ${(discount / 1000).toStringAsFixed(0)}.000đ',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent3,
                ),
              ),
            ],
          ),
          if (coupon.description != null) ...[
            const SizedBox(height: 6),
            Text(
              coupon.description!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCouponBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                height: 5,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mã giảm giá khả dụng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      if (availableCoupons.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.local_offer_outlined,
                                  size: 48,
                                  color: AppColors.divider,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Không có mã giảm giá nào khả dụng',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...availableCoupons.map((coupon) {
                          final isApplicable =
                              coupon.isApplicable(cartAmount);
                          final discount =
                              coupon.calculateDiscount(cartAmount);
                          final isSelected =
                              selectedCoupon?.promotionId ==
                                  coupon.promotionId;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: isApplicable
                                  ? () {
                                      onCouponSelected(coupon);
                                      Navigator.pop(context);
                                    }
                                  : null,
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.pastel1
                                      : (isApplicable
                                          ? Colors.white
                                          : AppColors.surface),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.accent1
                                        : AppColors.divider,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.accent1
                                                .withOpacity(0.2),
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                coupon.name,
                                                style:
                                                    const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.w800,
                                                  color: AppColors
                                                      .textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                coupon
                                                    .description ??
                                                    'Mã giảm giá',
                                                maxLines: 2,
                                                overflow: TextOverflow
                                                    .ellipsis,
                                                style:
                                                    const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors
                                                      .textMuted,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: AppColors.accent1,
                                            size: 24,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              'Tiết kiệm: ${discount > 0 ? "(${(discount / 1000).toStringAsFixed(0)}.000đ)" : "—"}',
                                              style:
                                                  TextStyle(
                                                fontSize: 12,
                                                fontWeight:
                                                    FontWeight.w700,
                                                color: isApplicable
                                                    ? AppColors
                                                        .accent3
                                                    : AppColors
                                                        .textMuted,
                                              ),
                                            ),
                                            const SizedBox(
                                                height: 2),
                                            Text(
                                              'Tối thiểu: ${(coupon.minOrderAmount / 1000).toStringAsFixed(0)}.000đ',
                                              style:
                                                  const TextStyle(
                                                fontSize: 10,
                                                color: AppColors
                                                    .textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (!isApplicable)
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration:
                                                BoxDecoration(
                                              color: AppColors
                                                  .statusCancelled
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(6),
                                            ),
                                            child: const Text(
                                              'Không khả dụng',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight:
                                                    FontWeight.w600,
                                                color: AppColors
                                                    .statusCancelledText,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
