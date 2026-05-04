// lib/views/checkout_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../models/cart_model.dart';
import '../../../widgets/common/primary_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  final _voucherController = TextEditingController();

  // Dữ liệu giỏ hàng — sau này lấy từ state management
  final CartModel _cart = CartModel.sample();
  bool _voucherApplied = false;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    _voucherController.dispose();
    super.dispose();
  }

  void _applyVoucher() {
    final code = _voucherController.text.trim().toUpperCase();
    setState(() {
      _cart.applyVoucher(code);
      _voucherApplied = _cart.discountAmount > 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_voucherApplied
            ? '✅ Áp dụng mã giảm giá thành công!'
            : '❌ Mã không hợp lệ hoặc đơn chưa đủ 50.000đ'),
        backgroundColor:
            _voucherApplied ? AppColors.accent3 : AppColors.statusCancelledText,
      ),
    );
  }

  void _placeOrder() {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ giao hàng')),
      );
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số điện thoại')),
      );
      return;
    }
    // Điều hướng sang tracking sau khi đặt hàng
    Navigator.pushReplacementNamed(context, AppRoutes.tracking);
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Xác nhận đơn hàng',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
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
                    // 1. Thông tin giao hàng — khớp delivery_address, delivery_phone trong SQL
                    _buildSectionTitle('Thông tin giao hàng'),
                    _buildInputField(
                      controller: _addressController,
                      hint: 'Địa chỉ giao hàng',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(
                      controller: _phoneController,
                      hint: 'Số điện thoại nhận hàng',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(
                      controller: _noteController,
                      hint: 'Ghi chú (không bắt buộc)',
                      icon: Icons.note_outlined,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 20),

                    // 2. Danh sách món — khớp order_items trong SQL
                    _buildSectionTitle('Món đã chọn'),
                    ..._cart.items.map((item) => _buildOrderItem(item)),

                    const SizedBox(height: 20),

                    // 3. Voucher — khớp bảng vouchers trong SQL
                    _buildSectionTitle('Mã giảm giá'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_offer_outlined,
                              size: 18, color: AppColors.textMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _voucherController,
                              decoration: const InputDecoration(
                                hintText: 'Nhập mã (VD: GIAM10K)',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                filled: false,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _applyVoucher,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.accent1,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Áp dụng',
                                style: TextStyle(
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

                    const SizedBox(height: 20),

                    // 4. Tổng tiền — khớp total_amount, delivery_fee, discount_amount
                    _buildSummaryCard(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Nút đặt hàng
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: PrimaryButton(
                label:
                    'Đặt hàng  •  ${(_cart.total / 1000).toStringAsFixed(0)}.000đ',
                onTap: _placeOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Icon(icon, size: 18, color: AppColors.textMuted),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItemModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.pastel1,
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.food.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(item.food.imageUrl!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.fastfood, color: AppColors.accent1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.food.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  'x${item.quantity}  •  ${(item.food.price / 1000).toStringAsFixed(0)}.000đ/món',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Text(
            '${(item.totalPrice / 1000).toStringAsFixed(0)}.000đ',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.accent1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pastel1,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _row('Tạm tính',
              '${(_cart.subtotal / 1000).toStringAsFixed(0)}.000đ'),
          const SizedBox(height: 7),
          _row('Phí giao hàng',
              '${(_cart.deliveryFee / 1000).toStringAsFixed(0)}.000đ'),
          const SizedBox(height: 7),
          _row(
            'Giảm giá',
            '-${(_cart.discountAmount / 1000).toStringAsFixed(0)}.000đ',
            valueColor:
                _voucherApplied ? AppColors.accent3 : AppColors.textMuted,
          ),
          const Divider(color: Color(0x33FF8C69), height: 20),
          _row(
            'Tổng cộng',
            '${(_cart.total / 1000).toStringAsFixed(0)}.000đ',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w400,
              color: isTotal ? AppColors.textPrimary : AppColors.textMuted,
            )),
        Text(value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ??
                  (isTotal ? AppColors.accent1 : AppColors.textPrimary),
            )),
      ],
    );
  }
}