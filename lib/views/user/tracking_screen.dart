// lib/views/user/tracking_screen.dart
// Theo doi don hang — 5 buoc:
//   pending -> confirmed -> preparing -> shipping -> completed
// Tinh nang:
//  - Pull-to-refresh: tra cuu lai status tu API
//  - Realtime: lang nghe SignalR notification co relatedId = orderId -> auto refresh
//  - Hien chi tiet don, payment method, payment status, voucher
//  - Cancel khi van con pending (chua xac nhan)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../data/providers/order_provider.dart';
import '../../../models/notification_model.dart';
import '../../../models/order_model.dart';
import '../../../widgets/common/back_button_widget.dart';
import '../../../widgets/notification/app_snackbar.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  OrderModel? _order;
  bool _busy = false;

  // Callback cu cua NotificationProvider — restore khi roi screen
  void Function(NotificationModel)? _prevOnPushed;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_order == null) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is OrderModel) _order = arg;
    }

    // Lang nghe SignalR push -> neu lien quan toi don dang xem thi refresh
    final notifProv = context.read<NotificationProvider>();
    _prevOnPushed ??= notifProv.onPushed;
    notifProv.onPushed = (n) {
      _prevOnPushed?.call(n);
      if (_order == null) return;
      if (n.relatedId == _order!.orderId) {
        // Auto refresh khi backend bao co update lien quan don nay
        _refresh(silent: true);
      }
    };
  }

  @override
  void dispose() {
    // Restore callback cu
    try {
      context.read<NotificationProvider>().onPushed = _prevOnPushed;
    } catch (_) {}
    super.dispose();
  }

  Future<void> _refresh({bool silent = false}) async {
    if (_order?.orderId == null) return;
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final prov = context.read<OrderProvider>();
      await prov.refreshOrderById(_order!.orderId!);
      if (prov.selectedOrder != null && mounted) {
        setState(() => _order = prov.selectedOrder);
      }
    } catch (e) {
      if (!silent && mounted) {
        AppSnackbar.showError(context, 'Không tải được trạng thái: $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancelOrder() async {
    if (_order?.orderId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Huỷ đơn hàng?'),
        content: const Text(
          'Bạn có chắc muốn huỷ đơn này? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCancelledText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Huỷ đơn', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await context.read<OrderProvider>().cancelOrder(_order!.orderId!);
      await _refresh();
      if (mounted) AppSnackbar.showSuccess(context, 'Đã huỷ đơn');
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, 'Lỗi: $e');
    }
  }

  // ──────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────
  String _formatDate(DateTime? d) {
    if (d == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} '
        '${two(d.hour)}:${two(d.minute)}';
  }

  String _formatMoney(double a) {
    final s = a.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()}đ';
  }

  String _paymentLabel(String method) {
    switch (method) {
      case 'cash':
        return 'COD - Thanh toán khi nhận hàng';
      case 'bank_transfer':
        return 'Chuyển khoản ngân hàng';
      case 'vnpay':
        return 'VNPay';
      default:
        return method;
    }
  }

  // ──────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final order = _order;
    if (order == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              const Text(
                'Không có đơn hàng để theo dõi',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.orders),
                child: const Text('Xem danh sách đơn hàng'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(order),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.accent1,
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    _buildStatusCard(order),
                    const SizedBox(height: 16),
                    _buildTimeline(order),
                    const SizedBox(height: 16),
                    _buildPaymentCard(order),
                    const SizedBox(height: 16),
                    _buildItemsCard(order),
                    const SizedBox(height: 16),
                    _buildSummaryCard(order),
                    if (order.status == OrderStatus.pending) ...[
                      const SizedBox(height: 16),
                      _buildCancelButton(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // HEADER
  // ──────────────────────────────────────────────────────────
  Widget _buildHeader(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          BackButtonWidget(
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.orders,
              (r) => false,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Theo dõi đơn hàng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  order.orderCode,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _busy ? null : () => _refresh(),
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent1,
                    ),
                  )
                : const Icon(Icons.refresh_rounded, color: AppColors.accent1),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // STATUS CARD (big banner)
  // ──────────────────────────────────────────────────────────
  Widget _buildStatusCard(OrderModel order) {
    final isCancelled = order.status == OrderStatus.cancelled;
    final isPending = order.status == OrderStatus.pending;
    final isCompleted = order.status == OrderStatus.completed;

    final emoji = isCancelled
        ? '❌'
        : isCompleted
        ? '🎉'
        : isPending
        ? '⏳'
        : '🛵';

    final title = (order.status as String?).label;
    final subtitle = isPending
        ? 'Vui lòng hoàn tất thanh toán để xác nhận đơn'
        : isCancelled
        ? 'Đơn hàng đã được huỷ'
        : isCompleted
        ? 'Cảm ơn bạn đã đặt hàng!'
        : 'Đặt lúc ${_formatDate(order.createdAt)}';

    final gradColors = isCancelled
        ? [
            AppColors.statusCancelled,
            AppColors.statusCancelled.withOpacity(0.7),
          ]
        : isCompleted
        ? [AppColors.pastel3, AppColors.pastel2]
        : isPending
        ? [AppColors.pastel4, AppColors.pastel1]
        : [AppColors.accent1, const Color(0xFFFFAB7E)];

    final textOnDark = !isCancelled && !isCompleted && !isPending;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(textOnDark ? 0.25 : 1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textOnDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textOnDark
                        ? Colors.white.withOpacity(0.92)
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // TIMELINE 5 BUOC
  // ──────────────────────────────────────────────────────────
  Widget _buildTimeline(OrderModel order) {
    if (order.status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider.withOpacity(0.4)),
        ),
        child: Row(
          children: const [
            Icon(Icons.cancel_outlined, color: AppColors.statusCancelledText),
            SizedBox(width: 8),
            Text(
              'Đơn hàng đã huỷ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.statusCancelledText,
              ),
            ),
          ],
        ),
      );
    }

    // 5 buoc — index tang dan theo tien trinh
    const stepKeys = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.shipping,
      OrderStatus.completed,
    ];
    final currentIdx = stepKeys.indexOf(order.status);

    final steps = [
      ('📝', 'Đã đặt hàng', 'Chờ xác nhận thanh toán'),
      ('✅', 'Đã xác nhận', 'Cửa hàng đã nhận đơn'),
      ('🍳', 'Đang chuẩn bị', 'Đầu bếp đang nấu'),
      ('🛵', 'Đang giao hàng', 'Tài xế đang trên đường'),
      ('📦', 'Hoàn thành', 'Giao hàng thành công'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider.withOpacity(0.4)),
      ),
      child: Column(
        children: List.generate(steps.length, (i) {
          final done = i < currentIdx;
          final active = i == currentIdx;
          final isLast = i == steps.length - 1;
          final dotColor = done
              ? AppColors.accent3
              : (active ? AppColors.accent1 : const Color(0xFFE0D5CF));

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    width: active ? 22 : 14,
                    height: active ? 22 : 14,
                    margin: const EdgeInsets.only(top: 3),
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      border: active
                          ? Border.all(
                              color: AppColors.accent1.withOpacity(0.3),
                              width: 5,
                            )
                          : null,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 42,
                      color: done
                          ? AppColors.accent3.withOpacity(0.3)
                          : const Color(0xFFE0D5CF),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${steps[i].$1}  ${steps[i].$2}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: done || active
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        steps[i].$3,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // PAYMENT
  // ──────────────────────────────────────────────────────────
  Widget _buildPaymentCard(OrderModel order) {
    final paid =
        order.status != OrderStatus.pending &&
        order.status != OrderStatus.cancelled;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.pastel2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: AppColors.accent2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phương thức thanh toán',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _paymentLabel(order.paymentMethod),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: paid ? AppColors.statusConfirmed : AppColors.statusPending,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              paid ? 'Đã thanh toán' : 'Chờ thanh toán',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: paid
                    ? AppColors.statusConfirmedText
                    : AppColors.statusPendingText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // ITEMS LIST
  // ──────────────────────────────────────────────────────────
  Widget _buildItemsCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 16,
                color: AppColors.accent3,
              ),
              const SizedBox(width: 6),
              const Text(
                'Món đã đặt',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${order.items.length} món',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...order.items.map(
            (it) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.accent1,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${it.foodName}  ×${it.quantity}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    _formatMoney(it.unitPrice * it.quantity),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // SUMMARY
  // ──────────────────────────────────────────────────────────
  Widget _buildSummaryCard(OrderModel order) {
    final subtotal =
        order.totalAmount - order.deliveryFee + order.discountAmount;
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
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0x33FF8C69), height: 1),
          const SizedBox(height: 10),
          _row('Tạm tính', _formatMoney(subtotal)),
          const SizedBox(height: 6),
          _row('Phí giao hàng', _formatMoney(order.deliveryFee)),
          if (order.discountAmount > 0) ...[
            const SizedBox(height: 6),
            _row(
              order.voucherCode != null
                  ? 'Giảm giá (${order.voucherCode})'
                  : 'Giảm giá',
              '-${_formatMoney(order.discountAmount)}',
              valueColor: AppColors.accent3,
            ),
          ],
          const SizedBox(height: 10),
          const Divider(color: Color(0x33FF8C69), height: 1),
          const SizedBox(height: 10),
          _row('Tổng cộng', _formatMoney(order.totalAmount), isTotal: true),
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
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 17 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
            color:
                valueColor ??
                (isTotal ? AppColors.accent1 : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  // CANCEL BUTTON (chi hien khi pending)
  // ──────────────────────────────────────────────────────────
  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: _cancelOrder,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.statusCancelled,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.statusCancelledText.withOpacity(0.3),
          ),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Huỷ đơn hàng',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.statusCancelledText,
          ),
        ),
      ),
    );
  }
}
