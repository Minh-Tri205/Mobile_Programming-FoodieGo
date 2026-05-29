// lib/views/admin/admin_statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/providers/food_provider.dart';
import '../../data/providers/order_provider.dart';
import '../../models/order_item_model.dart';
import '../../models/order_model.dart';

enum _Period { today, week, month, quarter }

class AdminStatisticsScreen extends StatefulWidget {
  const AdminStatisticsScreen({super.key});

  @override
  State<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {
  _Period _period = _Period.week;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProv = context.read<OrderProvider>();
      final foodProv = context.read<FoodProvider>();
      if (orderProv.orders.isEmpty) orderProv.fetchOrders();
      if (foodProv.foods.isEmpty) foodProv.fetchFoods();
    });
  }

  // =========================================================
  // PERIOD HELPERS
  // =========================================================
  String _periodLabel(_Period p) {
    switch (p) {
      case _Period.today:
        return 'Hôm nay';
      case _Period.week:
        return '7 ngày';
      case _Period.month:
        return '30 ngày';
      case _Period.quarter:
        return '3 tháng';
    }
  }

  int _periodDays(_Period p) {
    switch (p) {
      case _Period.today:
        return 1;
      case _Period.week:
        return 7;
      case _Period.month:
        return 30;
      case _Period.quarter:
        return 90;
    }
  }

  // Khoảng [start, end) hiện tại
  (DateTime, DateTime) _currentRange() {
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day).add(
      const Duration(days: 1),
    );
    final start = endOfToday.subtract(Duration(days: _periodDays(_period)));
    return (start, endOfToday);
  }

  // Khoảng so sánh kỳ trước (cùng độ dài)
  (DateTime, DateTime) _previousRange() {
    final (start, end) = _currentRange();
    final len = end.difference(start);
    return (start.subtract(len), start);
  }

  // =========================================================
  // STATS COMPUTE
  // =========================================================
  _Stats _computeStats(List<OrderModel> orders) {
    final (curStart, curEnd) = _currentRange();
    final (prevStart, prevEnd) = _previousRange();

    bool inRange(DateTime? d, DateTime s, DateTime e) {
      if (d == null) return false;
      return !d.isBefore(s) && d.isBefore(e);
    }

    final current = orders.where((o) => inRange(o.createdAt, curStart, curEnd));
    final previous =
        orders.where((o) => inRange(o.createdAt, prevStart, prevEnd));

    final curRevenue = current
        .where((o) => o.status != OrderStatus.cancelled)
        .fold<double>(0, (s, o) => s + o.totalAmount);

    final prevRevenue = previous
        .where((o) => o.status != OrderStatus.cancelled)
        .fold<double>(0, (s, o) => s + o.totalAmount);

    final curOrders = current.length;
    final prevOrders = previous.length;

    final completedCount = current
        .where((o) => o.status == OrderStatus.completed)
        .length;

    final cancelledCount = current
        .where((o) => o.status == OrderStatus.cancelled)
        .length;

    final avgValue = curOrders > 0 ? curRevenue / curOrders : 0.0;

    final completionRate = curOrders > 0
        ? (completedCount / curOrders) * 100
        : 0.0;

    return _Stats(
      revenue: curRevenue,
      prevRevenue: prevRevenue,
      orders: curOrders,
      prevOrders: prevOrders,
      avgValue: avgValue,
      completionRate: completionRate,
      completed: completedCount,
      cancelled: cancelledCount,
      orderList: current.toList(),
    );
  }

  // Phân bổ doanh thu theo từng ngày trong period
  List<_DayBucket> _dailyBuckets(List<OrderModel> orders) {
    final (start, end) = _currentRange();
    final days = end.difference(start).inDays;
    final buckets = List.generate(days, (i) {
      final d = start.add(Duration(days: i));
      return _DayBucket(date: d, revenue: 0);
    });

    for (final o in orders) {
      final d = o.createdAt;
      if (d == null) continue;
      if (d.isBefore(start) || !d.isBefore(end)) continue;
      if (o.status == OrderStatus.cancelled) continue;
      final idx = d.difference(DateTime(start.year, start.month, start.day))
          .inDays;
      if (idx >= 0 && idx < buckets.length) {
        buckets[idx] = buckets[idx].copyWith(
          revenue: buckets[idx].revenue + o.totalAmount,
        );
      }
    }
    return buckets;
  }

  // Top N món bán chạy trong period
  List<_TopItem> _topItems(List<OrderModel> orders, {int limit = 5}) {
    final map = <int, _TopItem>{};
    for (final o in orders) {
      if (o.status == OrderStatus.cancelled) continue;
      for (final OrderItemModel item in o.items) {
        final id = item.foodId;
        final cur = map[id];
        if (cur == null) {
          map[id] = _TopItem(
            foodId: id,
            foodName: item.foodName,
            foodImageUrl: item.foodImageUrl,
            quantity: item.quantity,
            revenue: item.subtotal,
          );
        } else {
          map[id] = cur.copyWith(
            quantity: cur.quantity + item.quantity,
            revenue: cur.revenue + item.subtotal,
          );
        }
      }
    }
    final list = map.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
    return list.take(limit).toList();
  }

  // =========================================================
  // FORMAT
  // =========================================================
  String _money(double a) {
    if (a >= 1000000) return '${(a / 1000000).toStringAsFixed(1)}M';
    if (a >= 1000) return '${(a / 1000).toStringAsFixed(0)}K';
    return a.toStringAsFixed(0);
  }

  String _moneyFull(double a) {
    final s = a.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()}đ';
  }

  String _growthText(double cur, double prev) {
    if (prev == 0) return cur == 0 ? '0%' : '+100%';
    final delta = ((cur - prev) / prev) * 100;
    final sign = delta >= 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(1)}%';
  }

  bool _isPositive(double cur, double prev) => cur >= prev;

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
          builder: (context, prov, _) {
            if (prov.isLoading && prov.orders.isEmpty) {
              return Column(
                children: [
                  _buildHeader(),
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }

            final stats = _computeStats(prov.orders);
            final buckets = _dailyBuckets(prov.orders);
            final tops = _topItems(stats.orderList);

            return RefreshIndicator(
              color: AppColors.accent1,
              onRefresh: () => prov.fetchOrders(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _buildHeader(),
                  _buildPeriodTabs(),
                  const SizedBox(height: 8),
                  _buildRevenueCard(stats),
                  const SizedBox(height: 14),
                  _buildSmallStatsRow(stats),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Doanh thu theo ngày'),
                  _buildBarChart(buckets),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Phân bố trạng thái'),
                  _buildStatusBreakdown(stats),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Top 5 món bán chạy'),
                  _buildTopItems(tops),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================
  Widget _buildHeader() {
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Báo cáo doanh thu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Phân tích hiệu suất kinh doanh',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
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
  // PERIOD TABS
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
  // REVENUE CARD — big gradient
  // =========================================================
  Widget _buildRevenueCard(_Stats s) {
    final positive = _isPositive(s.revenue, s.prevRevenue);
    final growth = _growthText(s.revenue, s.prevRevenue);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent1, Color(0xFFFFAB7E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent1.withOpacity(0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tổng doanh thu',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      positive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      growth,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _moneyFull(s.revenue),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'So với kỳ trước: ${_moneyFull(s.prevRevenue)}',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SMALL STATS ROW
  // =========================================================
  Widget _buildSmallStatsRow(_Stats s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _smallStat(
              icon: Icons.receipt_long_rounded,
              color: AppColors.accent2,
              bg: AppColors.pastel2,
              value: '${s.orders}',
              label: 'Tổng đơn',
              growth: _growthText(s.orders.toDouble(), s.prevOrders.toDouble()),
              positive: _isPositive(
                s.orders.toDouble(),
                s.prevOrders.toDouble(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _smallStat(
              icon: Icons.payment_rounded,
              color: AppColors.accent3,
              bg: AppColors.pastel3,
              value: '${_money(s.avgValue)}đ',
              label: 'Đơn TB',
              growth: null,
              positive: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _smallStat(
              icon: Icons.verified_rounded,
              color: AppColors.accent5,
              bg: AppColors.pastel5,
              value: '${s.completionRate.toStringAsFixed(0)}%',
              label: 'Hoàn thành',
              growth: null,
              positive: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallStat({
    required IconData icon,
    required Color color,
    required Color bg,
    required String value,
    required String label,
    required String? growth,
    required bool positive,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (growth != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  positive
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 10,
                  color: positive
                      ? AppColors.statusDeliveredText
                      : AppColors.statusCancelledText,
                ),
                Text(
                  growth,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: positive
                        ? AppColors.statusDeliveredText
                        : AppColors.statusCancelledText,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // SECTION TITLE
  // =========================================================
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.accent1,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
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
    );
  }

  // =========================================================
  // BAR CHART — daily revenue
  // =========================================================
  Widget _buildBarChart(List<_DayBucket> buckets) {
    if (buckets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _emptyChart(),
      );
    }
    final maxRevenue = buckets.fold<double>(
      0,
      (m, b) => b.revenue > m ? b.revenue : m,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: buckets.map((b) {
                final ratio = maxRevenue > 0 ? b.revenue / maxRevenue : 0.0;
                final showLabel = b.revenue > 0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (showLabel)
                          Text(
                            _money(b.revenue),
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent1,
                            ),
                          ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 320),
                          height: 8 + ratio * 110,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: ratio > 0
                                  ? [
                                      AppColors.accent1,
                                      const Color(0xFFFFAB7E),
                                    ]
                                  : [
                                      AppColors.divider,
                                      AppColors.divider,
                                    ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: buckets.map((b) {
              return Expanded(
                child: Text(
                  _shortDateLabel(b.date, buckets.length),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _shortDateLabel(DateTime d, int total) {
    // Khi nhiều ngày, label thưa đi
    if (total <= 7) return '${d.day}/${d.month}';
    if (total <= 30) {
      // Mỗi 3 ngày 1 nhãn
      return d.day % 3 == 0 ? '${d.day}' : '';
    }
    // 90 ngày — mỗi 7 ngày
    return d.day % 7 == 1 ? '${d.day}/${d.month}' : '';
  }

  Widget _emptyChart() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Chưa có dữ liệu',
        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
      ),
    );
  }

  // =========================================================
  // STATUS BREAKDOWN — horizontal bar
  // =========================================================
  Widget _buildStatusBreakdown(_Stats s) {
    final completed = s.completed;
    final cancelled = s.cancelled;
    final processing = s.orders - completed - cancelled;
    final total = s.orders == 0 ? 1 : s.orders;

    final segments = <_Segment>[
      _Segment(
        label: 'Hoàn thành',
        count: completed,
        ratio: completed / total,
        color: AppColors.statusDeliveredText,
        bg: AppColors.statusDelivered,
      ),
      _Segment(
        label: 'Đang xử lý',
        count: processing,
        ratio: processing / total,
        color: AppColors.statusDeliveringText,
        bg: AppColors.statusDelivering,
      ),
      _Segment(
        label: 'Đã huỷ',
        count: cancelled,
        ratio: cancelled / total,
        color: AppColors.statusCancelledText,
        bg: AppColors.statusCancelled,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Stacked horizontal bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 14,
              child: Row(
                children: segments
                    .where((seg) => seg.count > 0)
                    .map(
                      (seg) => Expanded(
                        flex: seg.count,
                        child: Container(color: seg.color),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...segments.map(
            (seg) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: seg.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      seg.label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${seg.count}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: seg.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: seg.bg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${(seg.ratio * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: seg.color,
                      ),
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

  // =========================================================
  // TOP ITEMS
  // =========================================================
  Widget _buildTopItems(List<_TopItem> tops) {
    if (tops.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Chưa có món nào được bán',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(tops.length, (i) {
          final item = tops[i];
          final isLast = i == tops.length - 1;
          return Column(
            children: [
              _topItemRow(item, rank: i + 1),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: Color(0xFFF5EEE9)),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _topItemRow(_TopItem item, {required int rank}) {
    final letter = item.foodName.isEmpty
        ? '?'
        : item.foodName.trim().characters.first.toUpperCase();

    Color rankColor;
    switch (rank) {
      case 1:
        rankColor = const Color(0xFFE6A817);
        break;
      case 2:
        rankColor = const Color(0xFF9DA9B5);
        break;
      case 3:
        rankColor = const Color(0xFFB07BFF);
        break;
      default:
        rankColor = AppColors.textMuted;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      child: Row(
        children: [
          // Rank
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: rankColor,
              ),
            ),
          ),
          // Thumb
          SizedBox(
            width: 44,
            height: 44,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _topItemImage(item, letter),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.foodName.isEmpty ? 'Món #${item.foodId}' : item.foodName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Đã bán ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_money(item.revenue)}đ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.accent1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _topItemImage(_TopItem item, String letter) {
    final url = item.foodImageUrl;
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
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.accent1,
        ),
      ),
    );
  }
}

// =============================================================
// DATA CLASSES
// =============================================================
class _Stats {
  final double revenue;
  final double prevRevenue;
  final int orders;
  final int prevOrders;
  final double avgValue;
  final double completionRate;
  final int completed;
  final int cancelled;
  final List<OrderModel> orderList;

  const _Stats({
    required this.revenue,
    required this.prevRevenue,
    required this.orders,
    required this.prevOrders,
    required this.avgValue,
    required this.completionRate,
    required this.completed,
    required this.cancelled,
    required this.orderList,
  });
}

class _DayBucket {
  final DateTime date;
  final double revenue;
  const _DayBucket({required this.date, required this.revenue});

  _DayBucket copyWith({DateTime? date, double? revenue}) {
    return _DayBucket(
      date: date ?? this.date,
      revenue: revenue ?? this.revenue,
    );
  }
}

class _TopItem {
  final int foodId;
  final String foodName;
  final String? foodImageUrl;
  final int quantity;
  final double revenue;

  const _TopItem({
    required this.foodId,
    required this.foodName,
    this.foodImageUrl,
    required this.quantity,
    required this.revenue,
  });

  _TopItem copyWith({int? quantity, double? revenue}) {
    return _TopItem(
      foodId: foodId,
      foodName: foodName,
      foodImageUrl: foodImageUrl,
      quantity: quantity ?? this.quantity,
      revenue: revenue ?? this.revenue,
    );
  }
}

class _Segment {
  final String label;
  final int count;
  final double ratio;
  final Color color;
  final Color bg;

  const _Segment({
    required this.label,
    required this.count,
    required this.ratio,
    required this.color,
    required this.bg,
  });
}
