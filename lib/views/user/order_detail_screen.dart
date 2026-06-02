// lib/views/user/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/providers/order_provider.dart';
import '../../../models/order_item_model.dart';
import '../../../models/order_model.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _loaded = false;

  // Fallback dùng khi arguments không hợp lệ — vẫn render được UI.
  OrderModel get _fallbackOrder => OrderModel.sampleOrders.first;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is int) {
      Future.microtask(() {
        if (!mounted) return;
        context.read<OrderProvider>().getOrderById(args);
      });
    } else if (args is OrderModel) {
      Future.microtask(() {
        if (!mounted) return;
        final provider = context.read<OrderProvider>();
        provider.selectedOrder = args;
        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        provider.notifyListeners();
        // Refetch ngam theo ID de lay nested food (kem imageUrl) tu GetById,
        // vi list endpoint co the khong .Include(OrderItems).ThenInclude(Food)
        if (args.orderId != null) {
          provider.refreshOrderById(args.orderId!);
        }
      });
    }
  }

  // =========================================================
  // HELPERS
  // =========================================================
  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }

  String _formatMoney(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}.000đ';
    }
    return '${amount.toStringAsFixed(0)}đ';
  }

  String _firstLetter(String s) {
    final t = s.trim();
    if (t.isEmpty) return '?';
    return t.characters.first.toUpperCase();
  }

  String _paymentLabel(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Tiền mặt khi nhận hàng';
      case 'momo':
        return 'Ví MoMo';
      case 'vnpay':
        return 'VNPay';
      case 'zalopay':
        return 'ZaloPay';
      case 'credit_card':
        return 'Thẻ tín dụng';
      case 'bank_transfer':
        return 'Chuyển khoản ngân hàng';
      default:
        return method;
    }
  }

  IconData _paymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.payments_rounded;
      case 'credit_card':
        return Icons.credit_card_rounded;
      case 'bank_transfer':
        return Icons.account_balance_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  // =========================================================
  // BUILD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.selectedOrder == null) {
            return const Center(child: CircularProgressIndicator());
          }

          OrderModel? order = provider.selectedOrder;
          if (order == null) {
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args is OrderModel) {
              order = args;
            } else {
              order = _fallbackOrder;
            }
          }

          return CustomScrollView(
            slivers: [
              _buildSliverHeader(order),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -16),
                  child: _buildTimelineCard(order),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildShippingSection(order),
                    const SizedBox(height: 16),
                    _buildItemsSection(order),
                    const SizedBox(height: 16),
                    _buildPaymentSection(order),
                    const SizedBox(height: 16),
                    _buildMetaSection(order),
                    const SizedBox(height: 24),
                    _buildActionButtons(order),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =========================================================
  // SLIVER HEADER — gradient + curved + order code + status hero
  // =========================================================
  Widget _buildSliverHeader(OrderModel order) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.pastel1,
      elevation: 0,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: ClipPath(
          clipper: _HeaderClipper(),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.pastel1, AppColors.pastel5],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -30,
                    right: -20,
                    child: _decorCircle(140, Colors.white.withOpacity(0.18)),
                  ),
                  Positioned(
                    top: 40,
                    left: -40,
                    child: _decorCircle(90, Colors.white.withOpacity(0.12)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Chi tiết đơn hàng',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          order.orderCode,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Big status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: order.status.bgColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: order.status.textColor.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _statusIcon(order.status),
                                color: order.status.textColor,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                order.status.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: order.status.textColor,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_top_rounded;
      case OrderStatus.confirmed:
        return Icons.task_alt_rounded;
      case OrderStatus.preparing:
        return Icons.restaurant_rounded;
      case OrderStatus.shipping:
        return Icons.delivery_dining_rounded;
      case OrderStatus.completed:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // =========================================================
  // TIMELINE CARD — 4 steps mini progress
  // =========================================================
  Widget _buildTimelineCard(OrderModel order) {
    final steps = [
      _Step('Đã đặt', Icons.shopping_bag_rounded, OrderStatus.pending),
      _Step('Xác nhận', Icons.task_alt_rounded, OrderStatus.confirmed),
      _Step('Chuẩn bị', Icons.restaurant_rounded, OrderStatus.preparing),
      _Step('Giao hàng', Icons.delivery_dining_rounded, OrderStatus.shipping),
      _Step('Hoàn thành', Icons.check_circle_rounded, OrderStatus.completed),
    ];

    final currentIndex = _statusIndex(order.status, steps);
    final isCancelled = order.status == OrderStatus.cancelled;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isCancelled ? Icons.cancel_outlined : Icons.route_outlined,
                color: isCancelled
                    ? AppColors.statusCancelledText
                    : AppColors.accent1,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isCancelled ? 'Đơn đã huỷ' : 'Tiến trình đơn hàng',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isCancelled)
            _buildCancelledHint()
          else
            Row(
              children: List.generate(steps.length, (i) {
                final reached = i <= currentIndex;
                final isCurrent = i == currentIndex;
                final isLast = i == steps.length - 1;
                return Expanded(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              gradient: reached
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.accent1,
                                        Color(0xFFFFAB7E),
                                      ],
                                    )
                                  : null,
                              color: reached ? null : AppColors.pastel1,
                              shape: BoxShape.circle,
                              border: isCurrent
                                  ? Border.all(
                                      color: AppColors.accent1.withOpacity(0.3),
                                      width: 3,
                                    )
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              steps[i].icon,
                              color: reached
                                  ? Colors.white
                                  : AppColors.textMuted,
                              size: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 48,
                            child: Text(
                              steps[i].label,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: isCurrent
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: reached
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.only(bottom: 18),
                            color: i < currentIndex
                                ? AppColors.accent1
                                : AppColors.divider,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildCancelledHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.statusCancelled,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.statusCancelledText,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Đơn hàng này đã bị huỷ và không còn được xử lý.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.statusCancelledText.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _statusIndex(String status, List<_Step> steps) {
    // pending=0, confirmed=1, preparing=2, shipping=3, completed=4
    for (int i = 0; i < steps.length; i++) {
      if (steps[i].status == status) return i;
    }
    return 0;
  }

  // =========================================================
  // SHIPPING SECTION
  // =========================================================
  Widget _buildShippingSection(OrderModel order) {
    return _sectionCard(
      title: 'Thông tin giao hàng',
      titleIcon: Icons.local_shipping_outlined,
      children: [
        _infoRow(
          Icons.person_outline_rounded,
          AppColors.accent2,
          'Người nhận',
          order.recipientName,
        ),
        _divider(),
        _infoRow(
          Icons.location_on_outlined,
          AppColors.accent1,
          'Địa chỉ',
          order.deliveryAddress,
        ),
        _divider(),
        _infoRow(
          Icons.phone_outlined,
          AppColors.accent3,
          'Số điện thoại',
          order.deliveryPhone,
        ),
        if (order.note != null && order.note!.isNotEmpty) ...[
          _divider(),
          _infoRow(
            Icons.sticky_note_2_outlined,
            AppColors.accent4,
            'Ghi chú',
            order.note!,
          ),
        ],
      ],
    );
  }

  // =========================================================
  // ITEMS SECTION — beautiful rows with image slot + letter fallback
  // =========================================================
  Widget _buildItemsSection(OrderModel order) {
    return _sectionCard(
      title: 'Món đã đặt (${order.items.length})',
      titleIcon: Icons.restaurant_menu_outlined,
      children: [
        if (order.items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'Đơn này chưa có món nào.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          )
        else
          ...order.items.asMap().entries.map((e) {
            final isLast = e.key == order.items.length - 1;
            return Column(
              children: [_itemRow(e.value), if (!isLast) _divider()],
            );
          }),
      ],
    );
  }

  Widget _itemRow(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image slot 56x56 với letter fallback
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.pastel1,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _buildItemImage(item),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.foodName.isEmpty ? 'Món ăn' : item.foodName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pastel2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'x${item.quantity}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatMoney(item.unitPrice),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatMoney(item.subtotal),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.accent1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage(OrderItemModel item) {
    final url = item.foodImageUrl;
    final letter = _firstLetter(item.foodName);

    if (url == null || url.isEmpty) {
      return _initialBox(letter);
    }
    final isNet = url.startsWith('http');
    return isNet
        ? Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialBox(letter),
          )
        : Image.asset(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialBox(letter),
          );
  }

  Widget _initialBox(String letter) {
    return Container(
      color: AppColors.pastel1,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.accent1,
        ),
      ),
    );
  }

  // =========================================================
  // PAYMENT BREAKDOWN
  // =========================================================
  Widget _buildPaymentSection(OrderModel order) {
    final subtotal =
        order.totalAmount - order.deliveryFee + order.discountAmount;

    return _sectionCard(
      title: 'Tổng kết thanh toán',
      titleIcon: Icons.receipt_outlined,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: _totalRow('Tạm tính', _formatMoney(subtotal)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: _totalRow(
            'Phí giao hàng',
            _formatMoney(order.deliveryFee),
            valueIcon: Icons.local_shipping_outlined,
          ),
        ),
        if (order.discountAmount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: _totalRow(
              order.voucherCode != null
                  ? 'Giảm giá (${order.voucherCode})'
                  : 'Giảm giá',
              '-${_formatMoney(order.discountAmount)}',
              valueColor: AppColors.accent3,
              valueIcon: Icons.local_offer_outlined,
            ),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 20, color: Color(0xFFF5EEE9)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent1, Color(0xFFFFAB7E)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent1.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  _formatMoney(order.totalAmount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _totalRow(
    String label,
    String value, {
    Color? valueColor,
    IconData? valueIcon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            if (valueIcon != null) ...[
              Icon(
                valueIcon,
                size: 12,
                color: valueColor ?? AppColors.textMuted,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // META SECTION — created at + payment method
  // =========================================================
  Widget _buildMetaSection(OrderModel order) {
    return _sectionCard(
      title: 'Thông tin khác',
      titleIcon: Icons.info_outline_rounded,
      children: [
        _infoRow(
          Icons.access_time_rounded,
          AppColors.accent2,
          'Thời gian đặt',
          _formatDate(order.createdAt),
        ),
        _divider(),
        _infoRow(
          _paymentIcon(order.paymentMethod),
          AppColors.accent3,
          'Phương thức thanh toán',
          _paymentLabel(order.paymentMethod),
        ),
      ],
    );
  }

  // =========================================================
  // ACTION BUTTONS
  // =========================================================
  Widget _buildActionButtons(OrderModel order) {
    final isCompleted = order.status == OrderStatus.completed;
    final isShipping = order.status == OrderStatus.shipping;
    final isPreparing = order.status == OrderStatus.preparing;

    if (isCompleted) {
      return _bigButton(
        label: 'Viết đánh giá',
        icon: Icons.star_rounded,
        gradient: const [AppColors.accent4, Color(0xFFFFC95C)],
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.review, arguments: order),
      );
    }
    if (isShipping || isPreparing) {
      return _bigButton(
        label: 'Theo dõi đơn hàng',
        icon: Icons.delivery_dining_rounded,
        gradient: const [AppColors.accent2, Color(0xFF7AC2F0)],
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.tracking, arguments: order),
      );
    }
    // pending/confirmed/cancelled: không hành động
    return const SizedBox.shrink();
  }

  Widget _bigButton({
    required String label,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.4),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // SHARED — section card / info row / divider
  // =========================================================
  Widget _sectionCard({
    required String title,
    required IconData titleIcon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(titleIcon, size: 16, color: AppColors.accent1),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Divider(height: 1, color: Color(0xFFF5EEE9)),
  );
}

class _Step {
  final String label;
  final IconData icon;
  final String status;
  const _Step(this.label, this.icon, this.status);
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
