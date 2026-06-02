// lib/views/admin/admin_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../data/providers/order_provider.dart';
import '../../models/order_model.dart';

enum _Period { today, week, month, all }

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  _Period _period = _Period.today;
  String? _statusFilter; // null = tất cả

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  // =========================================================
  // HELPERS — date filter
  // =========================================================
  bool _inPeriod(DateTime? d, _Period p) {
    if (d == null) return false;
    final now = DateTime.now();
    switch (p) {
      case _Period.today:
        return d.year == now.year && d.month == now.month && d.day == now.day;
      case _Period.week:
        // Tuần bắt đầu thứ Hai (weekday 1) → Chủ nhật (7)
        final start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        final end = start.add(const Duration(days: 7));
        return !d.isBefore(start) && d.isBefore(end);
      case _Period.month:
        return d.year == now.year && d.month == now.month;
      case _Period.all:
        return true;
    }
  }

  String _periodLabel(_Period p) {
    switch (p) {
      case _Period.today:
        return 'Hôm nay';
      case _Period.week:
        return 'Tuần này';
      case _Period.month:
        return 'Tháng này';
      case _Period.all:
        return 'Tất cả';
    }
  }

  // =========================================================
  // STATS — tính từ orders đã filter theo period
  // =========================================================
  _OrderStats _computeStats(List<OrderModel> orders) {
    final inPeriod = orders.where((o) => _inPeriod(o.createdAt, _period));
    final completed =
        inPeriod.where((o) => o.status == OrderStatus.completed);
    final cancelled =
        inPeriod.where((o) => o.status == OrderStatus.cancelled);
    final processing = inPeriod.where(
      (o) =>
          o.status == OrderStatus.preparing ||
          o.status == OrderStatus.shipping ||
          o.status == OrderStatus.confirmed ||
          o.status == OrderStatus.pending,
    );
    final revenue = inPeriod
        .where((o) => o.status != OrderStatus.cancelled)
        .fold<double>(0, (sum, o) => sum + o.totalAmount);

    return _OrderStats(
      total: inPeriod.length,
      completed: completed.length,
      processing: processing.length,
      cancelled: cancelled.length,
      revenue: revenue,
    );
  }

  List<OrderModel> _filterList(List<OrderModel> orders) {
    return orders.where((o) {
      if (!_inPeriod(o.createdAt, _period)) return false;
      if (_statusFilter != null && o.status != _statusFilter) return false;
      return true;
    }).toList()
      ..sort((a, b) {
        final ad = a.createdAt ?? DateTime(0);
        final bd = b.createdAt ?? DateTime(0);
        return bd.compareTo(ad); // mới nhất lên trên
      });
  }

  String _formatMoney(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }

  String _formatTime(DateTime? d) {
    if (d == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)}';
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}';
  }

  // =========================================================
  // BUILD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Consumer<OrderProvider>(
          builder: (context, provider, _) {
            final stats = _computeStats(provider.orders);
            final list = _filterList(provider.orders);

            return Column(
              children: [
                _buildHeader(stats.total),
                _buildPeriodTabs(),
                const SizedBox(height: 4),
                _buildStatsGrid(stats),
                _buildStatusChips(),
                Expanded(
                  child: _buildList(
                    list,
                    provider.isLoading,
                    provider.error,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(int totalInPeriod) {
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
                  'Quản lý đơn hàng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$totalInPeriod đơn trong ${_periodLabel(_period).toLowerCase()}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.read<OrderProvider>().fetchOrders(),
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
                Icons.refresh_rounded,
                size: 20,
                color: AppColors.accent1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PERIOD TABS — segmented control
  // =========================================================
  Widget _buildPeriodTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: _Period.values.map((p) {
            final isActive = _period == p;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _period = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [AppColors.accent1, Color(0xFFFFAB7E)],
                          )
                        : null,
                    color: isActive ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.accent1.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _periodLabel(p),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isActive ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // =========================================================
  // STATS GRID — 4 cards
  // =========================================================
  Widget _buildStatsGrid(_OrderStats s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _bigStat(
                  label: 'Doanh thu',
                  value: '${_formatMoney(s.revenue)}đ',
                  sub: '${s.total} đơn',
                  icon: Icons.payments_rounded,
                  gradient: const [AppColors.accent1, Color(0xFFFFAB7E)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _smallStat(
                  label: 'Hoàn thành',
                  value: '${s.completed}',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.statusDeliveredText,
                  bg: AppColors.statusDelivered,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _smallStat(
                  label: 'Đang xử lý',
                  value: '${s.processing}',
                  icon: Icons.cached_rounded,
                  color: AppColors.statusDeliveringText,
                  bg: AppColors.statusDelivering,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _smallStat(
                  label: 'Đã huỷ',
                  value: '${s.cancelled}',
                  icon: Icons.cancel_rounded,
                  color: AppColors.statusCancelledText,
                  bg: AppColors.statusCancelled,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bigStat({
    required String label,
    required String value,
    required String sub,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STATUS CHIPS — filter theo status
  // =========================================================
  Widget _buildStatusChips() {
    final items = <(String?, String)>[
      (null, 'Tất cả'),
      (OrderStatus.pending, OrderStatus.pending.label),
      (OrderStatus.confirmed, OrderStatus.confirmed.label),
      (OrderStatus.preparing, OrderStatus.preparing.label),
      (OrderStatus.shipping, OrderStatus.shipping.label),
      (OrderStatus.completed, OrderStatus.completed.label),
      (OrderStatus.cancelled, OrderStatus.cancelled.label),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final entry = items[i];
          final isActive = _statusFilter == entry.$1;
          return GestureDetector(
            onTap: () => setState(() => _statusFilter = entry.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent1 : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: isActive
                    ? null
                    : Border.all(color: AppColors.divider),
              ),
              alignment: Alignment.center,
              child: Text(
                entry.$2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // LIST
  // =========================================================
  Widget _buildList(List<OrderModel> list, bool loading, String? error) {
    if (loading && list.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && list.isEmpty) {
      return _buildError(error);
    }
    if (list.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      color: AppColors.accent1,
      onRefresh: () => context.read<OrderProvider>().fetchOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildOrderCard(list[i]),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return GestureDetector(
      onTap: () => _showOrderActions(order),
      onLongPress: () => Navigator.pushNamed(
        context,
        AppRoutes.orderDetail,
        arguments: order,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: order.status.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _statusIcon(order.status),
                    color: order.status.textColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderCode,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.recipientName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: order.status.bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: order.status.textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF5EEE9)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatDate(order.createdAt)}  ${_formatTime(order.createdAt)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.shopping_basket_rounded,
                  size: 12,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${order.items.length} món',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_formatMoney(order.totalAmount)}đ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ACTION SHEET — chuyển trạng thái đơn (kết hợp xem chi tiết)
  // =========================================================
  void _showOrderActions(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            // Header thông tin đơn
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: order.status.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _statusIcon(order.status),
                    color: order.status.textColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderCode,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.recipientName} · ${_formatMoney(order.totalAmount)}đ',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: order.status.bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: order.status.textColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 26),
            // Action: xem chi tiết
            _actionTile(
              ctx,
              icon: Icons.visibility_outlined,
              color: AppColors.accent2,
              label: 'Xem chi tiết đơn',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(
                  context,
                  AppRoutes.orderDetail,
                  arguments: order,
                );
              },
            ),
            // Actions chuyển status theo trạng thái hiện tại
            ..._nextActions(order).map(
              (a) => _actionTile(
                ctx,
                icon: a.icon,
                color: a.color,
                label: a.label,
                onTap: () async {
                  Navigator.pop(ctx);
                  await _changeStatus(order, a.action, a.label);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action phù hợp với từng trạng thái — đúng nghiệp vụ:
  // pending → confirmed/cancelled
  // confirmed → preparing/cancelled
  // preparing → shipping/cancelled
  // shipping → completed/cancelled
  // completed/cancelled → không cho đổi tiếp
  List<_StatusAction> _nextActions(OrderModel order) {
    switch (order.status) {
      case OrderStatus.pending:
        return [
          _StatusAction(
            label: 'Xác nhận đơn',
            icon: Icons.task_alt_rounded,
            color: AppColors.statusConfirmedText,
            action: _StatusOp.confirm,
          ),
          _StatusAction(
            label: 'Huỷ đơn',
            icon: Icons.cancel_rounded,
            color: AppColors.statusCancelledText,
            action: _StatusOp.cancel,
          ),
        ];
      case OrderStatus.confirmed:
        return [
          _StatusAction(
            label: 'Bắt đầu chuẩn bị',
            icon: Icons.restaurant_rounded,
            color: AppColors.statusPreparingText,
            action: _StatusOp.preparing,
          ),
          _StatusAction(
            label: 'Huỷ đơn',
            icon: Icons.cancel_rounded,
            color: AppColors.statusCancelledText,
            action: _StatusOp.cancel,
          ),
        ];
      case OrderStatus.preparing:
        return [
          _StatusAction(
            label: 'Bắt đầu giao',
            icon: Icons.delivery_dining_rounded,
            color: AppColors.statusDeliveringText,
            action: _StatusOp.shipping,
          ),
          _StatusAction(
            label: 'Huỷ đơn',
            icon: Icons.cancel_rounded,
            color: AppColors.statusCancelledText,
            action: _StatusOp.cancel,
          ),
        ];
      case OrderStatus.shipping:
        return [
          _StatusAction(
            label: 'Đánh dấu hoàn thành',
            icon: Icons.check_circle_rounded,
            color: AppColors.statusDeliveredText,
            action: _StatusOp.complete,
          ),
          _StatusAction(
            label: 'Huỷ đơn',
            icon: Icons.cancel_rounded,
            color: AppColors.statusCancelledText,
            action: _StatusOp.cancel,
          ),
        ];
      default:
        return const [];
    }
  }

  Widget _actionTile(
    BuildContext ctx, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeStatus(
    OrderModel order,
    _StatusOp op,
    String label,
  ) async {
    if (order.orderId == null) return;
    final id = order.orderId!;
    final prov = context.read<OrderProvider>();
    try {
      switch (op) {
        case _StatusOp.confirm:
          await prov.confirmOrder(id);
          break;
        case _StatusOp.preparing:
          await prov.preparingOrder(id);
          break;
        case _StatusOp.shipping:
          await prov.shippingOrder(id);
          break;
        case _StatusOp.complete:
          await prov.completeOrder(id);
          break;
        case _StatusOp.cancel:
          await prov.cancelOrder(id);
          break;
      }
      if (mounted) _toast('$label thành công');
    } catch (e) {
      if (mounted) _toast('Lỗi: $e', error: true);
    }
  }

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            error ? AppColors.statusCancelledText : AppColors.accent3,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
        return Icons.receipt_long_rounded;
    }
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.pastel1, AppColors.pastel5],
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('📋', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 16),
            Text(
              'Không có đơn hàng nào ${_periodLabel(_period).toLowerCase()}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Thử chọn khoảng thời gian khác',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.statusCancelledText,
            ),
            const SizedBox(height: 12),
            const Text(
              'Không tải được đơn hàng',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              msg,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => context.read<OrderProvider>().fetchOrders(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent1,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderStats {
  final int total;
  final int completed;
  final int processing;
  final int cancelled;
  final double revenue;

  const _OrderStats({
    required this.total,
    required this.completed,
    required this.processing,
    required this.cancelled,
    required this.revenue,
  });
}

enum _StatusOp { confirm, preparing, shipping, complete, cancel }

class _StatusAction {
  final String label;
  final IconData icon;
  final Color color;
  final _StatusOp action;
  const _StatusAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.action,
  });
}
