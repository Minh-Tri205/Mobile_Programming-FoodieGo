import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/cart_model.dart';
import '../../widgets/common/back_button_widget.dart';
import '../../widgets/common/primary_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartModel _cart = CartModel.sample();
  final TextEditingController _couponController = TextEditingController();
  bool _voucherApplied = false;

  final List<Color> _itemBgColors = [
    AppColors.pastel1,
    AppColors.pastel2,
    AppColors.pastel3,
    AppColors.pastel4,
  ];

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  // Kết nối nút "Áp dụng" với CartModel.applyVoucher()
  void _applyVoucher() {
    final code = _couponController.text.trim().toUpperCase();
    setState(() {
      _cart.applyVoucher(code);
      _voucherApplied = _cart.discountAmount > 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_voucherApplied
            ? '✅ Áp dụng mã giảm giá thành công!'
            : '❌ Mã không hợp lệ hoặc đơn chưa đủ 50.000đ'),
        backgroundColor: _voucherApplied
            ? AppColors.accent3
            : AppColors.statusCancelledText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        'Giỏ hàng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_cart.itemCount} món đã chọn',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Cart items
                    ...List.generate(_cart.items.length, (i) {
                      final item = _cart.items[i];
                      return _buildCartItem(i, item);
                    }),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Coupon
                    _buildCouponRow(),

                    const SizedBox(height: 12),

                    // Summary
                    _buildSummaryCard(),

                    const SizedBox(height: 12),

                    // Checkout button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: PrimaryButton(
                        label:
                            'Thanh toán → ${(_cart.total / 1000).toStringAsFixed(0)}.000đ',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.checkout),
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

  Widget _buildCartItem(int index, CartItemModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5EEE9))),
      ),
      child: Row(
        children: [
          // IMAGE — xử lý nullable imageUrl
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _itemBgColors[index % _itemBgColors.length],
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: item.food.imageUrl != null
                  ? Image.asset(
                      item.food.imageUrl!, // ✅ dùng ! vì đã kiểm tra null
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.fastfood, color: AppColors.accent1),
            ),
          ),

          const SizedBox(width: 12),

          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.food.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${(item.food.price / 1000).toStringAsFixed(0)}.000đ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent1,
                  ),
                ),
              ],
            ),
          ),

          // Qty controls
          Row(
            children: [
              _qtyButton('−', () {
                setState(() {
                  if (item.quantity > 1) {
                    item.quantity--;
                  } else {
                    _cart.items.removeAt(index);
                  }
                });
              }),
              SizedBox(
                width: 32,
                child: Text(
                  '${item.quantity}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _qtyButton('+', () => setState(() => item.quantity++)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.pastel1,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accent1, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.accent1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCouponRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Text(
              'Mã giảm giá',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _couponController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'VD: GIAM10K',
                  hintStyle: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
              ),
            ),
            // ✅ Đã kết nối với _applyVoucher()
            GestureDetector(
              onTap: _applyVoucher,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: _voucherApplied ? AppColors.accent3 : AppColors.accent1,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _voucherApplied ? '✓ Đã áp dụng' : 'Áp dụng',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pastel1,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _summaryRow(
            'Tạm tính',
            '${(_cart.subtotal / 1000).toStringAsFixed(0)}.000đ',
            false,
          ),
          const SizedBox(height: 7),
          _summaryRow(
            'Phí giao hàng',
            '${(_cart.deliveryFee / 1000).toStringAsFixed(0)}.000đ',
            false,
          ),
          const SizedBox(height: 7),
          _summaryRow(
            'Giảm giá',
            '-${(_cart.discountAmount / 1000).toStringAsFixed(0)}.000đ', // ✅ đổi discount → discountAmount
            false,
            valueColor: AppColors.accent3,
          ),
          const SizedBox(height: 6),
          const Divider(color: Color(0x33FF8C69), thickness: 1),
          const SizedBox(height: 6),
          _summaryRow(
            'Tổng cộng',
            '${(_cart.total / 1000).toStringAsFixed(0)}.000đ',
            true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool isTotal,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w400,
            color: isTotal ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ??
                (isTotal ? AppColors.accent1 : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}