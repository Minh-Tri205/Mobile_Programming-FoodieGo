// lib/views/user/checkout_screen.dart
// THÊM MỚI so với bản cũ:
//   - Chọn phương thức thanh toán: COD hoặc Chuyển khoản
//   - Khi chọn Chuyển khoản: hiện QR code + thông tin tài khoản
// Logic cũ (địa chỉ, phone, note, voucher, summary) giữ nguyên 100%

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../models/cart_model.dart';
import '../../../widgets/common/primary_button.dart';

// Enum phương thức thanh toán
enum PaymentMethod { cod, transfer }

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

  final CartModel _cart = CartModel.sample();
  bool _voucherApplied = false;

  // ✅ THÊM MỚI: Phương thức thanh toán, mặc định COD
  PaymentMethod _paymentMethod = PaymentMethod.cod;

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
        content: Text(
          _voucherApplied
              ? '✅ Áp dụng mã giảm giá thành công!'
              : '❌ Mã không hợp lệ hoặc đơn chưa đủ 50.000đ',
        ),
        backgroundColor: _voucherApplied
            ? AppColors.accent3
            : AppColors.statusCancelledText,
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

    // ✅ THÊM MỚI: Nếu chọn chuyển khoản → hiện dialog xác nhận đã chuyển
    if (_paymentMethod == PaymentMethod.transfer) {
      _showTransferConfirmDialog();
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.tracking);
    }
  }

  // ✅ THÊM MỚI: Dialog xác nhận đã chuyển khoản
  void _showTransferConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Xác nhận thanh toán',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.accent3,
              size: 56,
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn đã chuyển khoản\n${(_cart.total / 1000).toStringAsFixed(0)}.000đ\nthành công?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Chưa',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, AppRoutes.tracking);
            },
            child: const Text(
              'Đã chuyển khoản',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
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
            // Header (giữ nguyên)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
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
                    // 1. Thông tin giao hàng (giữ nguyên)
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

                    // 2. Danh sách món (giữ nguyên)
                    _buildSectionTitle('Món đã chọn'),
                    ..._cart.items.map((item) => _buildOrderItem(item)),

                    const SizedBox(height: 20),

                    // 3. Voucher (giữ nguyên)
                    _buildSectionTitle('Mã giảm giá'),
                    _buildVoucherRow(),

                    const SizedBox(height: 20),

                    // ✅ 4. THÊM MỚI: Phương thức thanh toán
                    _buildSectionTitle('Phương thức thanh toán'),
                    _buildPaymentSelector(),

                    // ✅ 5. THÊM MỚI: Hiện thông tin chuyển khoản nếu chọn
                    if (_paymentMethod == PaymentMethod.transfer) ...[
                      const SizedBox(height: 12),
                      _buildTransferInfo(),
                    ],

                    const SizedBox(height: 20),

                    // 6. Tổng tiền (giữ nguyên)
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
                label: _paymentMethod == PaymentMethod.cod
                    ? 'Đặt hàng (COD)  •  ${(_cart.total / 1000).toStringAsFixed(0)}.000đ'
                    : 'Xác nhận đã chuyển khoản  •  ${(_cart.total / 1000).toStringAsFixed(0)}.000đ',
                onTap: _placeOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ THÊM MỚI: Widget chọn phương thức thanh toán
  Widget _buildPaymentSelector() {
    return Column(
      children: [
        _paymentOption(
          method: PaymentMethod.cod,
          icon: Icons.delivery_dining_outlined,
          title: 'Thanh toán khi nhận hàng (COD)',
          subtitle: 'Trả tiền mặt khi shipper giao tới',
        ),
        const SizedBox(height: 10),
        _paymentOption(
          method: PaymentMethod.transfer,
          icon: Icons.account_balance_outlined,
          title: 'Chuyển khoản ngân hàng',
          subtitle: 'Quét QR hoặc chuyển theo thông tin bên dưới',
        ),
      ],
    );
  }

  Widget _paymentOption({
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pastel1 : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.accent1 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent1 : AppColors.divider,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.accent1 : Colors.white,
                border: Border.all(
                  color: isSelected ? AppColors.accent1 : AppColors.divider,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ THÊM MỚI: Thông tin chuyển khoản + QR giả lập
  Widget _buildTransferInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent1.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'Thông tin chuyển khoản',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // QR Code giả lập bằng widget
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.divider, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(painter: _QrPlaceholderPainter()),
          ),

          const SizedBox(height: 12),

          // Thông tin tài khoản
          _transferRow('Ngân hàng', 'VietcomBank'),
          const SizedBox(height: 6),
          _transferRow('Số tài khoản', '1234 5678 9012'),
          const SizedBox(height: 6),
          _transferRow('Chủ tài khoản', 'FOODIEGO'),
          const SizedBox(height: 6),
          _transferRow(
            'Số tiền',
            '${(_cart.total / 1000).toStringAsFixed(0)}.000đ',
            valueColor: AppColors.accent1,
            valueBold: true,
          ),
          const SizedBox(height: 6),
          _transferRow(
            'Nội dung CK',
            'FOODIEGO ${DateTime.now().millisecondsSinceEpoch % 100000}',
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.pastel3,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.accent3),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Đơn hàng sẽ được xác nhận sau khi chúng tôi nhận được thanh toán.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.accent3,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _transferRow(
    String label,
    String value, {
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: valueBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─── Các widget giữ nguyên từ bản cũ ─────────────────────────────────────

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

  Widget _buildVoucherRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_offer_outlined,
            size: 18,
            color: AppColors.textMuted,
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
                Text(
                  item.food.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'x${item.quantity}  •  ${(item.food.price / 1000).toStringAsFixed(0)}.000đ/món',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
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
          _row(
            'Tạm tính',
            '${(_cart.subtotal / 1000).toStringAsFixed(0)}.000đ',
          ),
          const SizedBox(height: 7),
          _row(
            'Phí giao hàng',
            '${(_cart.deliveryFee / 1000).toStringAsFixed(0)}.000đ',
          ),
          const SizedBox(height: 7),
          _row(
            'Giảm giá',
            '-${(_cart.discountAmount / 1000).toStringAsFixed(0)}.000đ',
            valueColor: _voucherApplied
                ? AppColors.accent3
                : AppColors.textMuted,
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

  Widget _row(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
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
            color:
                valueColor ??
                (isTotal ? AppColors.accent1 : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

// ✅ THÊM MỚI: Vẽ QR placeholder (không cần thư viện ngoài)
class _QrPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 10;

    // Pattern QR giả lập — 3 góc + dots trung tâm
    final pattern = [
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 0],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 0, 1, 0, 1, 1, 0],
      [0, 1, 0, 0, 1, 0, 1, 0, 0, 1],
    ];

    for (int row = 0; row < pattern.length; row++) {
      for (int col = 0; col < pattern[row].length; col++) {
        if (pattern[row][col] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * cellSize + 4,
              row * cellSize + 4,
              cellSize - 1,
              cellSize - 1,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
