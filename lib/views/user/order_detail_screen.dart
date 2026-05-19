// lib/views/order_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../models/order_model.dart';
import '../../../widgets/common/back_button_widget.dart';
import '../../../widgets/common/primary_button.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)?.settings.arguments as OrderModel?
        ?? OrderModel.sampleOrders.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  BackButtonWidget(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chi tiết đơn hàng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // order_code từ SQL
                      Text(
                        order.orderCode,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Badge trạng thái
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.status.bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: order.status.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Thông tin giao hàng — khớp delivery_address, delivery_phone SQL
                    _sectionTitle('Thông tin giao hàng'),
                    _infoCard(children: [
                      _infoRow(Icons.location_on_outlined, 'Địa chỉ',
                          order.deliveryAddress),
                      const Divider(color: AppColors.divider, height: 16),
                      _infoRow(Icons.phone_outlined, 'Điện thoại',
                          order.deliveryPhone),
                      if (order.note != null &&
                          order.note!.isNotEmpty) ...[
                        const Divider(color: AppColors.divider, height: 16),
                        _infoRow(Icons.note_outlined, 'Ghi chú',
                            order.note!),
                      ],
                    ]),

                    const SizedBox(height: 16),

                    // 2. Phương thức thanh toán
                    _sectionTitle('Phương thức thanh toán'),
                    _infoCard(children: [
                      _infoRow(Icons.payment_outlined, 'Phương thức',
                          order.paymentMethod.label),
                    ]),

                    const SizedBox(height: 16),

                    // 3. Danh sách món — khớp order_items SQL
                    _sectionTitle('Món đã đặt'),
                    _infoCard(
                      children: [
                        ...order.items.asMap().entries.map((e) {
                          final i = e.key;
                          final item = e.value;
                          return Column(
                            children: [
                              if (i > 0)
                                const Divider(
                                    color: AppColors.divider, height: 16),
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.pastel1,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: item.foodImageUrl != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.asset(
                                              item.foodImageUrl!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(Icons.fastfood,
                                            color: AppColors.accent1),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.foodName,
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.w600)),
                                        Text(
                                          'x${item.quantity}  •  '
                                          '${(item.unitPrice / 1000).toStringAsFixed(0)}.000đ/món',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${(item.subtotal / 1000).toStringAsFixed(0)}.000đ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accent1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 4. Tổng tiền — khớp total_amount, delivery_fee, discount_amount SQL
                    _sectionTitle('Thanh toán'),
                    _infoCard(children: [
                      _totalRow('Tạm tính',
                          '${((order.totalAmount - order.deliveryFee + order.discountAmount) / 1000).toStringAsFixed(0)}.000đ'),
                      const SizedBox(height: 8),
                      _totalRow('Phí giao hàng',
                          '${(order.deliveryFee / 1000).toStringAsFixed(0)}.000đ'),
                      if (order.discountAmount > 0) ...[
                        const SizedBox(height: 8),
                        _totalRow(
                          'Giảm giá${order.voucherCode != null ? " (${order.voucherCode})" : ""}',
                          '-${(order.discountAmount / 1000).toStringAsFixed(0)}.000đ',
                          valueColor: AppColors.accent3,
                        ),
                      ],
                      const Divider(color: AppColors.divider, height: 20),
                      _totalRow(
                        'Tổng cộng',
                        '${(order.totalAmount / 1000).toStringAsFixed(0)}.000đ',
                        isTotal: true,
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // 5. Thời gian — khớp created_at SQL
                    _infoCard(children: [
                      _infoRow(Icons.access_time_outlined, 'Thời gian đặt',
                          order.createdAt),
                    ]),

                    const SizedBox(height: 24),

                    // Nút hành động theo trạng thái
                    if (order.status == OrderStatus.completed)
                      PrimaryButton(
                        label: '⭐ Viết đánh giá',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.review,
                          arguments: order,
                        ),
                      ),
                    if (order.status == OrderStatus.delivering ||
                        order.status == OrderStatus.preparing)
                      PrimaryButton(
                        label: '🛵 Theo dõi đơn hàng',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.tracking,
                          arguments: order,
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textMuted)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ),
      ],
    );
  }

  Widget _totalRow(String label, String value,
      {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight:
                  isTotal ? FontWeight.w800 : FontWeight.w400,
              color: isTotal ? AppColors.textPrimary : AppColors.textMuted,
            )),
        Text(value,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight:
                  isTotal ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ??
                  (isTotal ? AppColors.accent1 : AppColors.textPrimary),
            )),
      ],
    );
  }
}