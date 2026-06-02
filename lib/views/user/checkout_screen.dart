// lib/views/user/checkout_screen.dart
// - Lay du lieu cart tu CartProvider (khong dung sample nua)
// - Dia chi & SDT load tu UserProvider / AddressProvider (defaultAddress)
// - Bo phan ma giam gia (da chon o CartScreen)
// - Khi dat hang: neu co voucher dang ap dung -> tao VoucherUsage
// - Giu nguyen UI: COD / Chuyen khoan
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/providers/address_provider.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/providers/voucher_usage_provider.dart';
import '../../../models/cart_model.dart';
import '../../../models/order_item_model.dart';
import '../../../models/order_model.dart';
import '../../../models/voucher_usage_model.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/notification/app_snackbar.dart';

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

  PaymentMethod _paymentMethod = PaymentMethod.cod;
  bool _prefilledOnce = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = context.read<UserProvider>().currentUserId;
      if (userId != null) {
        final addrProv = context.read<AddressProvider>();
        if (addrProv.addresses.isEmpty) {
          addrProv.fetchByUser(userId).then((_) => _prefill());
        } else {
          _prefill();
        }
      }
    });
  }

  void _prefill() {
    if (_prefilledOnce) return;
    final user = context.read<UserProvider>().currentUser;
    final addr = context.read<AddressProvider>().defaultAddress;

    final autoAddress = addr?.fullAddress ?? '';
    final autoPhone = addr?.recipientPhone ?? user?.phone ?? '';

    if (_addressController.text.isEmpty && autoAddress.isNotEmpty) {
      _addressController.text = autoAddress;
    }
    if (_phoneController.text.isEmpty && autoPhone.isNotEmpty) {
      _phoneController.text = autoPhone;
    }
    _prefilledOnce = true;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
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

    if (_paymentMethod == PaymentMethod.transfer) {
      _showTransferConfirmDialog();
    } else {
      _finishOrder();
    }
  }

  // Hoan tat dat hang: tao Order qua API + voucher_usage neu co + clear cart
  Future<void> _finishOrder() async {
    final cart = context.read<CartProvider>();
    final userProv = context.read<UserProvider>();
    final userId = userProv.currentUserId;
    final addrProv = context.read<AddressProvider>();

    if (userId == null) {
      AppSnackbar.showError(context, 'Vui lòng đăng nhập lại');
      return;
    }

    // currentUser co the chua load (chua vao Profile lan nao) -> fetch ngay
    var user = userProv.currentUser;
    if (user == null) {
      try {
        await userProv.fetchUserById(userId);
        user = userProv.currentUser;
      } catch (e) {
        debugPrint('[Checkout] fetchUser loi: $e');
      }
    }

    // Lay ten nguoi nhan tu nhieu nguon (tranh fail khi user van null)
    final defaultAddr = addrProv.defaultAddress;
    final addrName = defaultAddr?.recipientName?.trim() ?? '';
    final userName = user?.fullName.trim() ?? '';
    final recipientName = addrName.isNotEmpty
        ? addrName
        : (userName.isNotEmpty ? userName : 'Khách hàng');

    final items = cart.selectedItems.isNotEmpty
        ? cart.selectedItems
        : cart.items;
    if (items.isEmpty) {
      AppSnackbar.showError(context, 'Giỏ hàng trống');
      return;
    }

    // Build order_items
    final orderItems = items
        .map((it) => OrderItemModel(
              foodId: it.food.foodId ?? 0,
              quantity: it.quantity,
              unitPrice: it.food.price,
              foodName: it.food.name,
              foodImageUrl: it.food.imageUrl,
            ))
        .toList();

    // Sinh order_code phia client (backend co the override)
    final code = 'DH-${DateTime.now().millisecondsSinceEpoch}';

    // Tim address_id tu address da chon (neu co)
    final addrId = (defaultAddr != null &&
            defaultAddr.fullAddress == _addressController.text.trim())
        ? defaultAddr.addressId
        : null;

    // payment_method theo CHECK constraint SQL:
    // 'cash', 'momo', 'vnpay', 'zalopay', 'credit_card', 'bank_transfer'
    final paymentStr = _paymentMethod == PaymentMethod.cod
        ? 'cash'
        : 'bank_transfer';

    final order = OrderModel(
      userId: userId,
      orderCode: code,
      recipientName: recipientName,
      deliveryAddress: _addressController.text.trim(),
      deliveryPhone: _phoneController.text.trim(),
      deliveryFee: cart.deliveryFee,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      addressId: addrId,
      paymentMethod: paymentStr,
      voucherId: cart.appliedVoucherId,
      voucherCode: cart.appliedVoucherCode,
      discountAmount: cart.discountAmount,
      status: OrderStatus.pending,
      totalAmount: cart.total,
      items: orderItems,
    );

    // Goi API tao don
    final orderProv = context.read<OrderProvider>();
    OrderModel created;
    try {
      created = await orderProv.createOrder(order);
    } catch (e, st) {
      debugPrint('[Checkout] Tao don loi: $e');
      debugPrint(st.toString());
      if (mounted) _showErrorDialog(context, e.toString());
      return;
    }

    // Ghi nhan luot dung voucher (gan voi order vua tao)
    if (cart.appliedVoucherId != null) {
      try {
        await context.read<VoucherUsageProvider>().create(
              VoucherUsageModel(
                voucherId: cart.appliedVoucherId!,
                userId: userId,
                orderId: created.orderId,
                usedAt: DateTime.now(),
              ),
            );
      } catch (e) {
        debugPrint('[Checkout] VoucherUsage loi (bo qua): $e');
      }
    }

    cart.clear();
    if (!mounted) return;
    AppSnackbar.showSuccess(context, 'Đặt hàng thành công ${created.orderCode}');
    Navigator.pushReplacementNamed(context, AppRoutes.tracking);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.statusCancelledText,
            ),
            SizedBox(width: 8),
            Text(
              'Đặt hàng lỗi',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            message,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Đóng',
              style: TextStyle(color: AppColors.accent1),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransferConfirmDialog() {
    final cart = context.read<CartProvider>();
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
              'Bạn đã chuyển khoản\n${(cart.total / 1000).toStringAsFixed(0)}.000đ\nthành công?',
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
              _finishOrder();
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
    final cart = context.watch<CartProvider>();
    final items = cart.selectedItems.isNotEmpty
        ? cart.selectedItems
        : cart.items; // fallback: hien tat ca neu chua check

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
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

                    _buildSectionTitle('Món đã chọn'),
                    if (items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Chưa có món nào được chọn',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    else
                      ...items.map((it) => _buildOrderItem(it)),

                    const SizedBox(height: 20),

                    if (cart.appliedVoucherCode != null) ...[
                      _buildAppliedVoucherCard(cart),
                      const SizedBox(height: 20),
                    ],

                    _buildSectionTitle('Phương thức thanh toán'),
                    _buildPaymentSelector(),

                    if (_paymentMethod == PaymentMethod.transfer) ...[
                      const SizedBox(height: 12),
                      _buildTransferInfo(cart),
                    ],

                    const SizedBox(height: 20),

                    _buildSummaryCard(cart),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: PrimaryButton(
                label: _paymentMethod == PaymentMethod.cod
                    ? 'Đặt hàng (COD)  •  ${(cart.total / 1000).toStringAsFixed(0)}.000đ'
                    : 'Xác nhận đã chuyển khoản  •  ${(cart.total / 1000).toStringAsFixed(0)}.000đ',
                onTap: _placeOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hien card voucher dang ap dung (chi xem, khong chinh sua)
  Widget _buildAppliedVoucherCard(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent1, Color(0xFFFFAB7E)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_offer_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đã áp dụng ${cart.appliedVoucherCode}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '-${(cart.discountAmount / 1000).toStringAsFixed(0)}.000đ',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildTransferInfo(CartProvider cart) {
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
          _transferRow('Ngân hàng', 'VietcomBank'),
          const SizedBox(height: 6),
          _transferRow('Số tài khoản', '1234 5678 9012'),
          const SizedBox(height: 6),
          _transferRow('Chủ tài khoản', 'FOODIEGO'),
          const SizedBox(height: 6),
          _transferRow(
            'Số tiền',
            '${(cart.total / 1000).toStringAsFixed(0)}.000đ',
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
            child: _buildFoodImage(item),
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

  Widget _buildFoodImage(CartItemModel item) {
    final url = item.food.imageUrl;
    if (url == null || url.isEmpty) {
      return const Icon(Icons.fastfood, color: AppColors.accent1);
    }
    final isNet = url.startsWith('http');
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: isNet
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.fastfood, color: AppColors.accent1),
            )
          : Image.asset(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.fastfood, color: AppColors.accent1),
            ),
    );
  }

  Widget _buildSummaryCard(CartProvider cart) {
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
            '${(cart.subtotal / 1000).toStringAsFixed(0)}.000đ',
          ),
          const SizedBox(height: 7),
          _row(
            'Phí giao hàng',
            '${(cart.deliveryFee / 1000).toStringAsFixed(0)}.000đ',
          ),
          if (cart.discountAmount > 0) ...[
            const SizedBox(height: 7),
            _row(
              'Giảm giá${cart.appliedVoucherCode != null ? ' (${cart.appliedVoucherCode})' : ''}',
              '-${(cart.discountAmount / 1000).toStringAsFixed(0)}.000đ',
              valueColor: AppColors.accent3,
            ),
          ],
          const Divider(color: Color(0x33FF8C69), height: 20),
          _row(
            'Tổng cộng',
            '${(cart.total / 1000).toStringAsFixed(0)}.000đ',
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

// QR placeholder painter (giu nguyen)
class _QrPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 10;

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
