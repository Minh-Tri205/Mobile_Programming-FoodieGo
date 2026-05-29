import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../data/providers/order_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final int userId;

  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  late Future<_UserDetailData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_UserDetailData> _load() async {
    final userRepo = context.read<UserProvider>().repository;
    final orderRepo = context.read<OrderProvider>().repository;

    final results = await Future.wait([
      userRepo.getUserById(widget.userId),
      orderRepo.getOrdersByUserId(widget.userId),
    ]);

    return _UserDetailData(
      user: results[0] as UserModel,
      orders: results[1] as List<OrderModel>,
    );
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _toggleLock(UserModel user) async {
    final isActive = user.isActive ?? false;
    final confirmed = await _confirmDialog(
      title: isActive ? 'Khoá tài khoản?' : 'Mở khoá tài khoản?',
      content: isActive
          ? 'Người dùng sẽ không thể đăng nhập sau khi khoá.'
          : 'Người dùng sẽ có thể đăng nhập trở lại.',
      confirmLabel: isActive ? 'Khoá' : 'Mở khoá',
      destructive: isActive,
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<UserProvider>().toggleStatus(user.userId);
      if (!mounted) return;
      _showSnack(isActive ? 'Đã khoá tài khoản' : 'Đã mở khoá tài khoản');
      _refresh();
    } catch (e) {
      if (mounted) _showSnack('Lỗi: $e', error: true);
    }
  }

  Future<void> _changeRole(UserModel user) async {
    final isAdmin = (user.role ?? '').toLowerCase() == 'admin';
    final newRole = isAdmin ? 'customer' : 'admin';

    final confirmed = await _confirmDialog(
      title: isAdmin ? 'Hạ quyền về Customer?' : 'Nâng quyền lên Admin?',
      content: isAdmin
          ? 'Tài khoản sẽ mất quyền quản trị.'
          : 'Tài khoản sẽ có toàn quyền quản trị.',
      confirmLabel: 'Xác nhận',
      destructive: false,
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<UserProvider>().changeRole(user.userId, newRole);
      if (!mounted) return;
      _showSnack('Đã đổi quyền thành $newRole');
      _refresh();
    } catch (e) {
      if (mounted) _showSnack('Lỗi: $e', error: true);
    }
  }

  Future<bool> _confirmDialog({
    required String title,
    required String content,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: destructive
                  ? AppColors.statusCancelledText
                  : AppColors.accent1,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error
            ? AppColors.statusCancelledText
            : AppColors.accent3,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<_UserDetailData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _buildError(snap.error.toString());
          }
          final data = snap.data!;
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(data.user),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -28),
                    child: _buildStatsCard(data),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildInfoSection(data.user),
                      const SizedBox(height: 20),
                      _buildRecentOrders(data.orders),
                      const SizedBox(height: 20),
                      _buildActionsSection(
                        data.user,
                        orderCount: data.orders.length,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
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
              size: 64,
              color: AppColors.statusCancelledText,
            ),
            const SizedBox(height: 16),
            Text(
              'Không tải được dữ liệu',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              msg,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refresh,
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

  // =========================================================
  // SLIVER APP BAR — gradient + curved bottom + avatar + badges
  // =========================================================
  Widget _buildSliverAppBar(UserModel user) {
    final tier = _tierFor(user.loyaltyPoints ?? 0);
    final isAdmin = (user.role ?? '').toLowerCase() == 'admin';
    final isActive = user.isActive ?? false;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.pastel1,
      leading: Container(
        margin: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
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
                    top: -20,
                    right: -30,
                    child: _decorCircle(140, Colors.white.withOpacity(0.18)),
                  ),
                  Positioned(
                    top: 60,
                    left: -40,
                    child: _decorCircle(90, Colors.white.withOpacity(0.12)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 60),
                    child: Column(
                      children: [
                        // Avatar with tier badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: _buildAvatar(user),
                            ),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: tier.color,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  tier.label,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _miniBadge(
                              text: isAdmin ? 'ADMIN' : 'CUSTOMER',
                              bg: isAdmin
                                  ? AppColors.accent5.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.7),
                              fg: isAdmin
                                  ? AppColors.accent5
                                  : AppColors.accent1,
                              icon: isAdmin
                                  ? Icons.shield_rounded
                                  : Icons.person_rounded,
                            ),
                            const SizedBox(width: 8),
                            _miniBadge(
                              text: isActive ? 'HOẠT ĐỘNG' : 'BỊ KHOÁ',
                              bg: isActive
                                  ? AppColors.statusConfirmed
                                  : AppColors.statusCancelled,
                              fg: isActive
                                  ? AppColors.statusConfirmedText
                                  : AppColors.statusCancelledText,
                              icon: isActive
                                  ? Icons.check_circle_rounded
                                  : Icons.lock_rounded,
                            ),
                          ],
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

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildAvatar(UserModel user) {
    final url = user.avatarUrl;
    final initial = _firstLetter(user.fullName);
    return ClipOval(
      child: SizedBox(
        width: 80,
        height: 80,
        child: (url != null && url.isNotEmpty)
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initialAvatar(initial),
              )
            : _initialAvatar(initial),
      ),
    );
  }

  Widget _initialAvatar(String letter) {
    return Container(
      color: AppColors.pastel5,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: AppColors.accent5,
        ),
      ),
    );
  }

  Widget _miniBadge({
    required String text,
    required Color bg,
    required Color fg,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STATS CARD — floating, real data
  // =========================================================
  Widget _buildStatsCard(_UserDetailData data) {
    final totalSpent = data.orders
        .where((o) => o.status != OrderStatus.cancelled)
        .fold<double>(0, (sum, o) => sum + o.totalAmount);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 8),
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
      child: Row(
        children: [
          _statCell(
            icon: Icons.receipt_long_rounded,
            color: AppColors.accent1,
            value: '${data.orders.length}',
            label: 'Đơn hàng',
            showDivider: true,
          ),
          _statCell(
            icon: Icons.payments_rounded,
            color: AppColors.accent3,
            value: _formatMoney(totalSpent),
            label: 'Tổng chi',
            showDivider: true,
          ),
          _statCell(
            icon: Icons.workspace_premium_rounded,
            color: AppColors.accent4,
            value: '${data.user.loyaltyPoints ?? 0}',
            label: 'Điểm',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _statCell({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    required bool showDivider,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  right: BorderSide(color: Color(0xFFF0EAE5), width: 1),
                )
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // INFO SECTION
  // =========================================================
  Widget _buildInfoSection(UserModel user) {
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
        children: [
          _sectionTitle('Thông tin cá nhân', Icons.badge_outlined),
          _infoTile(
            Icons.email_outlined,
            AppColors.accent2,
            'Email',
            user.email ?? '(chưa cập nhật)',
          ),
          _divider(),
          _infoTile(
            Icons.phone_android_rounded,
            AppColors.accent3,
            'Số điện thoại',
            user.phone ?? '(chưa cập nhật)',
          ),
          _divider(),
          _infoTile(
            Icons.shield_outlined,
            AppColors.accent5,
            'Vai trò',
            user.role ?? 'customer',
          ),
          _divider(),
          _infoTile(
            Icons.calendar_today_rounded,
            AppColors.accent4,
            'Ngày tham gia',
            _formatDate(user.createdAt),
          ),
          _divider(),
          _infoTile(
            Icons.update_rounded,
            AppColors.accent1,
            'Cập nhật gần nhất',
            _formatDate(user.updatedAt),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.accent1),
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

  Widget _infoTile(
    IconData icon,
    Color color,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 18),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
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

  // =========================================================
  // RECENT ORDERS PREVIEW
  // =========================================================
  Widget _buildRecentOrders(List<OrderModel> orders) {
    final recent = orders.take(3).toList();

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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: 16,
                  color: AppColors.accent1,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Đơn hàng gần đây',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (orders.isNotEmpty)
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.adminUserHistory,
                      arguments: widget.userId,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Xem tất cả',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent1,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.accent1,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 36,
                      color: AppColors.textMuted.withOpacity(0.5),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Chưa có đơn hàng nào',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...recent.asMap().entries.map((e) {
              final isLast = e.key == recent.length - 1;
              return Column(
                children: [
                  _orderRow(e.value),
                  if (!isLast) _divider(),
                ],
              );
            }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _orderRow(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.pastel1,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.receipt_outlined,
              size: 18,
              color: AppColors.accent1,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(order.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatMoney(order.totalAmount),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent1,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
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
        ],
      ),
    );
  }

  // =========================================================
  // ACTIONS SECTION
  // =========================================================
  Widget _buildActionsSection(UserModel user, {int orderCount = 0}) {
    final isAdmin = (user.role ?? '').toLowerCase() == 'admin';
    final isActive = user.isActive ?? false;

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
        children: [
          _sectionTitle('Thao tác quản trị', Icons.admin_panel_settings_outlined),
          _actionTile(
            icon: Icons.history_rounded,
            color: AppColors.accent3,
            title: 'Xem lịch sử mua hàng',
            subtitle: 'Chi tiết $orderCount đơn hàng đã đặt',
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.adminUserHistory,
              arguments: widget.userId,
            ),
          ),
          _divider(),
          _actionTile(
            icon: isAdmin
                ? Icons.person_remove_outlined
                : Icons.shield_outlined,
            color: AppColors.accent5,
            title: isAdmin ? 'Hạ quyền về Customer' : 'Nâng quyền Admin',
            subtitle: isAdmin
                ? 'Tài khoản sẽ mất quyền quản trị'
                : 'Cấp quyền truy cập trang quản trị',
            onTap: () => _changeRole(user),
          ),
          _divider(),
          _actionTile(
            icon: isActive
                ? Icons.lock_outline_rounded
                : Icons.lock_open_rounded,
            color: isActive
                ? AppColors.statusCancelledText
                : AppColors.statusConfirmedText,
            title: isActive ? 'Khoá tài khoản' : 'Mở khoá tài khoản',
            subtitle: isActive
                ? 'Người dùng sẽ không thể đăng nhập'
                : 'Cho phép người dùng đăng nhập lại',
            onTap: () => _toggleLock(user),
            destructive: isActive,
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 20),
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
                      color: destructive
                          ? AppColors.statusCancelledText
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HELPERS
  // =========================================================
  String _firstLetter(String s) {
    final t = s.trim();
    if (t.isEmpty) return '?';
    return t.characters.first.toUpperCase();
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  String _formatMoney(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  _Tier _tierFor(int points) {
    if (points >= 500) return const _Tier('VIP', Color(0xFFB07BFF));
    if (points >= 200) return const _Tier('GOLD', Color(0xFFE6A817));
    if (points >= 50) return const _Tier('SILVER', Color(0xFF9DA9B5));
    return const _Tier('NEW', Color(0xFF7CC891));
  }
}

class _UserDetailData {
  final UserModel user;
  final List<OrderModel> orders;
  const _UserDetailData({required this.user, required this.orders});
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

class _Tier {
  final String label;
  final Color color;
  const _Tier(this.label, this.color);
}
