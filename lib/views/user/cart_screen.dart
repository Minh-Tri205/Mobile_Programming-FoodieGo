// lib/views/user/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/providers/voucher_provider.dart';
import '../../../data/providers/voucher_usage_provider.dart';
import '../../../models/cart_model.dart';
import '../../../models/voucher_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final voucherProv = context.read<VoucherProvider>();
      final usageProv = context.read<VoucherUsageProvider>();
      final userId = context.read<UserProvider>().currentUserId;
      if (voucherProv.vouchers.isEmpty) voucherProv.fetchAll();
      if (userId != null) usageProv.fetchByUser(userId);
    });
  }

  String _money(double a) {
    if (a >= 1000) return '${(a / 1000).toStringAsFixed(0)}.000đ';
    return '${a.toStringAsFixed(0)}đ';
  }

  String _firstLetter(String s) {
    final t = s.trim();
    if (t.isEmpty) return '?';
    return t.characters.first.toUpperCase();
  }

  // Voucher hop le de hien thi: admin bat + chua het han + user nay chua dung
  List<VoucherModel> _availableVouchers() {
    final voucherProv = context.watch<VoucherProvider>();
    final usageProv = context.watch<VoucherUsageProvider>();
    final userId = context.watch<UserProvider>().currentUserId;
    final usedIds = usageProv.usages
        .where((u) => userId != null && u.userId == userId)
        .map((u) => u.voucherId)
        .toSet();
    final now = DateTime.now();
    return voucherProv.vouchers.where((v) {
      if (v.isActive != true) return false;
      if (v.endDate != null && v.endDate!.isBefore(now)) return false;
      if (v.startDate != null && v.startDate!.isAfter(now)) return false;
      if (v.voucherId != null && usedIds.contains(v.voucherId)) return false;
      return true;
    }).toList();
  }

  void _onTapVoucher(CartProvider cart, VoucherModel v) {
    if (cart.appliedVoucherId == v.voucherId) {
      cart.removeVoucher();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã bỏ mã ${v.code}'),
          backgroundColor: AppColors.textMuted,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    final err = cart.applyVoucherModel(v);
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(err == null ? '✅ Đã áp dụng mã ${v.code}' : '❌ $err'),
    //     backgroundColor:
    //         err == null ? AppColors.accent3 : AppColors.statusCancelledText,
    //     behavior: SnackBarBehavior.floating,
    //     shape:
    //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //     margin: const EdgeInsets.all(16),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Consumer<CartProvider>(
          builder: (context, cart, _) {
            return Column(
              children: [
                _buildHeader(cart),
                Expanded(
                  child: cart.isEmpty
                      ? _buildEmpty()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                          children: [
                            ...cart.items.map((it) => _buildCartItem(cart, it)),
                            const SizedBox(height: 16),
                            _buildCouponRow(cart),
                            const SizedBox(height: 12),
                            _buildSummaryCard(cart),
                          ],
                        ),
                ),
                if (!cart.isEmpty) _buildCheckoutBar(cart),
              ],
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // HEADER với select all
  // =========================================================
  Widget _buildHeader(CartProvider cart) {
    final allSelected = cart.items.isNotEmpty &&
        cart.selectedItems.length == cart.items.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                const SizedBox(height: 2),
                Text(
                  '${cart.items.length} món · ${cart.selectedItems.length} đang chọn',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (cart.items.isNotEmpty)
            GestureDetector(
              onTap: () {
                if (allSelected) {
                  cart.unselectAll();
                } else {
                  cart.selectAll();
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.pastel1,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  allSelected ? 'Bỏ chọn' : 'Chọn tất cả',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================
  // ITEM ROW
  // =========================================================
  Widget _buildCartItem(CartProvider cart, CartItemModel item) {
    final foodId = item.food.foodId ?? -1;
    final isSelected = cart.isSelected(foodId);
    final letter = _firstLetter(item.food.name);

    return Dismissible(
      key: ValueKey('cart-${item.food.foodId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.statusCancelled,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: AppColors.statusCancelledText,
            ),
            SizedBox(width: 6),
            Text(
              'Xoá',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.statusCancelledText,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => cart.removeItem(foodId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: isSelected
                ? AppColors.accent1.withOpacity(0.3)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => cart.toggleSelect(foodId),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent1 : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected ? AppColors.accent1 : AppColors.divider,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : null,
              ),
            ),
            // Image
            SizedBox(
              width: 56,
              height: 56,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildImage(item.food.imageUrl, letter),
              ),
            ),
            const SizedBox(width: 12),
            // Name + unit price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.food.categoryName.isNotEmpty)
                    Text(
                      item.food.categoryName,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent2,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    item.food.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _money(item.food.price),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildQtyControl(cart, item),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? url, String letter) {
    if (url == null || url.isEmpty) return _letterBox(letter);
    final isNet = url.startsWith('http');
    return isNet
        ? Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _letterBox(letter),
          )
        : Image.asset(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _letterBox(letter),
          );
  }

  Widget _letterBox(String letter) {
    return Container(
      color: AppColors.pastel1,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.accent1,
        ),
      ),
    );
  }

  // =========================================================
  // QTY CONTROL
  // =========================================================
  Widget _buildQtyControl(CartProvider cart, CartItemModel item) {
    final foodId = item.food.foodId ?? -1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.pastel1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(Icons.remove_rounded,
              onTap: () => cart.updateQty(foodId, item.quantity - 1)),
          SizedBox(
            width: 32,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _qtyBtn(Icons.add_rounded,
              onTap: () => cart.updateQty(foodId, item.quantity + 1)),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.accent1),
      ),
    );
  }

  // =========================================================
  // VOUCHER LIST (tu API admin tao)
  // =========================================================
  Widget _buildCouponRow(CartProvider cart) {
    final voucherProv = context.watch<VoucherProvider>();
    final list = _availableVouchers();

    if (voucherProv.isLoading && voucherProv.vouchers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.accent1,
            ),
          ),
        ),
      );
    }

    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(
              Icons.local_offer_outlined,
              size: 18,
              color: AppColors.textMuted,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Chưa có voucher khả dụng',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              const Icon(
                Icons.local_offer_rounded,
                size: 16,
                color: AppColors.accent1,
              ),
              const SizedBox(width: 6),
              const Text(
                'Mã giảm giá',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${list.length} mã',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _buildVoucherCard(cart, list[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherCard(CartProvider cart, VoucherModel v) {
    final isApplied = cart.appliedVoucherId == v.voucherId;
    final minOrder = v.minOrderValue ?? 0;
    final notEnough = cart.subtotal < minOrder;

    return GestureDetector(
      onTap: () => _onTapVoucher(cart, v),
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: isApplied
              ? const LinearGradient(
                  colors: [AppColors.accent1, Color(0xFFFFAB7E)],
                )
              : null,
          color: isApplied ? null : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isApplied
                ? Colors.transparent
                : (notEnough
                    ? AppColors.divider
                    : AppColors.accent1.withOpacity(0.4)),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isApplied ? AppColors.accent1 : Colors.black)
                  .withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_offer_rounded,
                  size: 14,
                  color: isApplied ? Colors.white : AppColors.accent1,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    v.code,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isApplied
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isApplied)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
              ],
            ),
            Text(
              '-${_money(v.discountAmount)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isApplied ? Colors.white : AppColors.accent1,
              ),
            ),
            Text(
              v.description ?? 'Đơn từ ${_money(minOrder)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: isApplied
                    ? Colors.white.withOpacity(0.92)
                    : (notEnough
                        ? AppColors.statusCancelledText
                        : AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // SUMMARY
  // =========================================================
  Widget _buildSummaryCard(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.pastel1, AppColors.pastel4],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _summaryRow('Tạm tính', _money(cart.subtotal)),
          const SizedBox(height: 6),
          _summaryRow('Phí giao hàng', _money(cart.deliveryFee)),
          if (cart.discountAmount > 0) ...[
            const SizedBox(height: 6),
            _summaryRow(
              cart.appliedVoucherCode != null
                  ? 'Giảm giá (${cart.appliedVoucherCode})'
                  : 'Giảm giá',
              '-${_money(cart.discountAmount)}',
              valueColor: AppColors.accent3,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0x33FF8C69), thickness: 1),
          ),
          _summaryRow('Tổng cộng', _money(cart.total), isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(
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
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
            color: valueColor ??
                (isTotal ? AppColors.accent1 : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // CHECKOUT BAR
  // =========================================================
  Widget _buildCheckoutBar(CartProvider cart) {
    final selectedCount = cart.selectedItems.length;
    final disabled = selectedCount == 0;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tổng',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _money(cart.total),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent1,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: disabled
                  ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hãy chọn ít nhất 1 món để thanh toán'),
                        ),
                      )
                  : () => Navigator.pushNamed(context, AppRoutes.checkout),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: disabled
                      ? null
                      : const LinearGradient(
                          colors: [AppColors.accent1, Color(0xFFFFAB7E)],
                        ),
                  color: disabled ? AppColors.divider : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: disabled
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.accent1.withOpacity(0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color:
                          disabled ? AppColors.textMuted : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Thanh toán ($selectedCount)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color:
                            disabled ? AppColors.textMuted : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EMPTY
  // =========================================================
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.pastel1, AppColors.pastel5],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('🛒', style: TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Quay lại thực đơn và thả tim cho món bạn thích nhé!',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.home,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent1, Color(0xFFFFAB7E)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Khám phá menu',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
