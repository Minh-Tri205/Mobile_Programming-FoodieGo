// lib/views/user/cart_screen.dart
// THÊM MỚI so với bản cũ:
//   1. Checkbox chọn từng món (chọn 1 hoặc nhiều)
//   2. Nhập số lượng bằng tay khi nhấn vào số (TextField inline)
//   3. Thanh toán chỉ tính những món đã chọn
// Logic cũ (CartModel, voucher, summary) giữ nguyên 100%

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../models/cart_model.dart';
import '../../../widgets/common/back_button_widget.dart';
import '../../../widgets/common/primary_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartModel _cart = CartModel.sample();
  final TextEditingController _couponController = TextEditingController();
  bool _voucherApplied = false;

  // ✅ THÊM MỚI: Set index các món được chọn (mặc định chọn tất cả)
  late Set<int> _selectedIndices;

  // ✅ THÊM MỚI: Map để theo dõi item nào đang nhập tay
  final Map<int, TextEditingController> _qtyControllers = {};
  final Map<int, FocusNode> _qtyFocusNodes = {};
  final Map<int, bool> _isEditingQty = {};

  final List<Color> _itemBgColors = [
    AppColors.pastel1,
    AppColors.pastel2,
    AppColors.pastel3,
    AppColors.pastel4,
  ];

  @override
  void initState() {
    super.initState();
    // Mặc định chọn tất cả món
    _selectedIndices = Set.from(List.generate(_cart.items.length, (i) => i));
    // Khởi tạo controllers cho từng item
    for (int i = 0; i < _cart.items.length; i++) {
      _qtyControllers[i] = TextEditingController(
        text: '${_cart.items[i].quantity}',
      );
      _qtyFocusNodes[i] = FocusNode();
      _isEditingQty[i] = false;
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    for (final c in _qtyControllers.values) {
      c.dispose();
    }
    for (final f in _qtyFocusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  // ✅ THÊM MỚI: Tính tổng chỉ từ món được chọn
  double get _selectedSubtotal {
    double sum = 0;
    for (final i in _selectedIndices) {
      if (i < _cart.items.length) {
        sum += _cart.items[i].totalPrice;
      }
    }
    return sum;
  }

  double get _selectedTotal {
    final t = _selectedSubtotal + _cart.deliveryFee - _cart.discountAmount;
    return t.clamp(0, double.infinity);
  }

  void _applyVoucher() {
    final code = _couponController.text.trim().toUpperCase();
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

  // ✅ THÊM MỚI: Xác nhận số lượng nhập tay
  void _confirmQtyEdit(int index) {
    final text = _qtyControllers[index]?.text.trim() ?? '';
    final parsed = int.tryParse(text);
    setState(() {
      _isEditingQty[index] = false;
      if (parsed != null && parsed > 0) {
        _cart.items[index].quantity = parsed;
      } else if (parsed == 0) {
        // Xóa món nếu nhập 0
        _selectedIndices.remove(index);
        _cart.items.removeAt(index);
        _qtyControllers.remove(index);
        _qtyFocusNodes.remove(index);
        _isEditingQty.remove(index);
        return;
      }
      // Sync lại text
      _qtyControllers[index]?.text = '${_cart.items[index].quantity}';
    });
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
                  const Spacer(),
                  // ✅ THÊM MỚI: Chọn tất cả
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedIndices.length == _cart.items.length) {
                          _selectedIndices.clear();
                        } else {
                          _selectedIndices = Set.from(
                            List.generate(_cart.items.length, (i) => i),
                          );
                        }
                      });
                    },
                    child: Text(
                      _selectedIndices.length == _cart.items.length
                          ? 'Bỏ chọn tất cả'
                          : 'Chọn tất cả',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _cart.items.isEmpty
                  ? _buildEmptyCart()
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          ...List.generate(_cart.items.length, (i) {
                            return _buildCartItem(i, _cart.items[i]);
                          }),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          _buildCouponRow(),
                          const SizedBox(height: 12),
                          _buildSummaryCard(),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: PrimaryButton(
                              label: _selectedIndices.isEmpty
                                  ? 'Chưa chọn món nào'
                                  : 'Thanh toán (${_selectedIndices.length} món) → ${(_selectedTotal / 1000).toStringAsFixed(0)}.000đ',
                              onTap: _selectedIndices.isEmpty
                                  ? () => ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Hãy chọn ít nhất 1 món!',
                                            ),
                                          ),
                                        )
                                  : () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.checkout,
                                    ),
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

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🛒', style: TextStyle(fontSize: 64)),
          SizedBox(height: 12),
          Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Thêm món ăn để bắt đầu đặt hàng',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index, CartItemModel item) {
    final isSelected = _selectedIndices.contains(index);
    final isEditing = _isEditingQty[index] ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
          left: BorderSide(
            color: isSelected ? AppColors.accent1 : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          // ✅ THÊM MỚI: Checkbox
          GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedIndices.remove(index);
                } else {
                  _selectedIndices.add(index);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent1 : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.accent1 : AppColors.divider,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ),

          // Image
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _itemBgColors[index % _itemBgColors.length],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.food.imageUrl != null
                  ? Image.asset(item.food.imageUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.fastfood, color: AppColors.accent1),
            ),
          ),

          const SizedBox(width: 10),

          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.food.name,
                  style: const TextStyle(
                    fontSize: 14,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent1,
                  ),
                ),
              ],
            ),
          ),

          // ✅ THÊM MỚI: Qty control với nhập tay
          _buildQtyControl(index, item, isEditing),
        ],
      ),
    );
  }

  Widget _buildQtyControl(int index, CartItemModel item, bool isEditing) {
    return Row(
      children: [
        // Nút giảm
        _qtyButton('−', () {
          setState(() {
            if (item.quantity > 1) {
              item.quantity--;
              _qtyControllers[index]?.text = '${item.quantity}';
            } else {
              // Xóa món
              _selectedIndices.remove(index);
              _cart.items.removeAt(index);
            }
          });
        }),

        const SizedBox(width: 4),

        // ✅ THÊM MỚI: Nhấn vào số → nhập tay
        GestureDetector(
          onTap: () {
            setState(() => _isEditingQty[index] = true);
            _qtyControllers[index]?.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _qtyControllers[index]!.text.length,
            );
            _qtyFocusNodes[index]?.requestFocus();
          },
          child: isEditing
              ? SizedBox(
                  width: 40,
                  height: 30,
                  child: TextField(
                    controller: _qtyControllers[index],
                    focusNode: _qtyFocusNodes[index],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 4,
                      ),
                      filled: true,
                      fillColor: AppColors.pastel1,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.accent1,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.accent1,
                          width: 2,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _confirmQtyEdit(index),
                    onTapOutside: (_) => _confirmQtyEdit(index),
                  ),
                )
              : Container(
                  width: 40,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.pastel1,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
        ),

        const SizedBox(width: 4),

        // Nút tăng
        _qtyButton('+', () {
          setState(() {
            item.quantity++;
            _qtyControllers[index]?.text = '${item.quantity}';
          });
        }),
      ],
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
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
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
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _voucherApplied
                      ? AppColors.accent3
                      : AppColors.accent1,
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
          // ✅ Hiển thị số món được chọn
          if (_selectedIndices.length < _cart.items.length)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppColors.accent1,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Đang tính ${_selectedIndices.length}/${_cart.items.length} món được chọn',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.accent1,
                    ),
                  ),
                ],
              ),
            ),
          _summaryRow(
            'Tạm tính',
            '${(_selectedSubtotal / 1000).toStringAsFixed(0)}.000đ',
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
            '-${(_cart.discountAmount / 1000).toStringAsFixed(0)}.000đ',
            false,
            valueColor: AppColors.accent3,
          ),
          const SizedBox(height: 6),
          const Divider(color: Color(0x33FF8C69), thickness: 1),
          const SizedBox(height: 6),
          _summaryRow(
            'Tổng cộng',
            '${(_selectedTotal / 1000).toStringAsFixed(0)}.000đ',
            true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    bool isTotal, {
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
