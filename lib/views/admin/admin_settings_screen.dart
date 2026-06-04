// lib/views/admin/admin_settings_screen.dart
// Trang cai dat danh cho admin:
//   - Card thong tin tai khoan admin
//   - Doi mat khau (xac thuc mat khau cu qua AuthService.login)
//   - Chon mau nen cho cac man hinh admin (chuyen background)
//   - Bat/tat thong bao
//   - Refresh du lieu
//   - Dang xuat
//
// Khi user chon background o day, ScaffoldcurrentScreen + dashboard
// se phan anh ngay nho AdminSettingsProvider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../data/providers/admin_settings_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/category_provider.dart';
import '../../data/providers/food_provider.dart';
import '../../data/providers/order_provider.dart';
import '../../models/user_model.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Login chi setCurrentUserId, KHONG fetch user object -> currentUser
    // co the null khi vao day. Phai fetch de bat duoc email, fullName,
    // avatar... va de nut "Doi mat khau" co the bam duoc.
    Future.microtask(() {
      if (!mounted) return;
      final prov = context.read<UserProvider>();
      final id = prov.currentUserId ?? prov.currentUser?.userId;
      if (id != null && prov.currentUser == null) {
        prov.fetchUserById(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AdminSettingsProvider>();
    final user = context.watch<UserProvider>().currentUser;

    return Scaffold(
      backgroundColor: settings.backgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            if (user != null) _buildProfileCard(user),
            const SizedBox(height: 18),
            _sectionTitle('Bảo mật'),
            _buildSecurityCard(user),
            const SizedBox(height: 18),
            _sectionTitle('Giao diện'),
            _buildAppearanceCard(settings),
            const SizedBox(height: 18),
            _sectionTitle('Tuỳ chọn'),
            _buildPreferencesCard(settings),
            const SizedBox(height: 18),
            _sectionTitle('Hệ thống'),
            _buildSystemCard(),
            const SizedBox(height: 18),
            _buildLogoutCard(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader() {
    return Row(
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
                'Cài đặt',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Quản lý tài khoản và tuỳ chỉnh giao diện',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PROFILE CARD
  // ============================================================
  Widget _buildProfileCard(UserModel user) {
    final initial = user.fullName.trim().isNotEmpty
        ? user.fullName.trim().characters.first.toUpperCase()
        : '?';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent1, Color(0xFFFFAB7E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent1.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                ? ClipOval(
                    child: Image.network(
                      user.avatarUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _initialAvatar(initial),
                    ),
                  )
                : _initialAvatar(initial),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? user.phone ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shield_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        (user.role ?? 'ADMIN').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.6,
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
    );
  }

  Widget _initialAvatar(String letter) {
    return Text(
      letter,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.accent1,
      ),
    );
  }

  // ============================================================
  // SECURITY
  // ============================================================
  Widget _buildSecurityCard(UserModel? user) {
    return _card(
      children: [
        _tile(
          icon: Icons.lock_outline_rounded,
          iconBg: AppColors.pastel4,
          iconColor: AppColors.accent4,
          label: 'Đổi mật khẩu',
          subtitle: 'Gửi OTP về email và đặt mật khẩu mới',
          // Dung chung man hinh ForgotPassword voi user: khi admin da dang
          // nhap, didChangeDependencies cua man do tu fill email tu
          // currentUser va gui OTP ngay -> bo qua buoc 1.
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.forgotPassword),
        ),
      ],
    );
  }

  // ============================================================
  // APPEARANCE — background picker
  // ============================================================
  Widget _buildAppearanceCard(AdminSettingsProvider settings) {
    return _card(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.pastel5,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.palette_outlined,
                  size: 18,
                  color: AppColors.accent5,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Màu nền',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Áp dụng cho các trang quản trị',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AdminSettingsProvider.presets.map((p) {
              final isActive = p.color.value == settings.backgroundColor.value;
              return GestureDetector(
                onTap: () => settings.setBackground(p.color),
                child: Container(
                  width: 64,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isActive
                          ? AppColors.accent1
                          : AppColors.divider,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: p.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: isActive
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: AppColors.accent1,
                              )
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? AppColors.accent1
                              : AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PREFERENCES — switches
  // ============================================================
  Widget _buildPreferencesCard(AdminSettingsProvider settings) {
    return _card(
      children: [
        _switchTile(
          icon: Icons.notifications_active_outlined,
          iconBg: AppColors.pastel1,
          iconColor: AppColors.accent1,
          label: 'Thông báo',
          subtitle: 'Nhận thông báo đơn hàng mới',
          value: settings.notificationsEnabled,
          onChanged: settings.toggleNotifications,
        ),
        _divider(),
        _switchTile(
          icon: Icons.format_size_rounded,
          iconBg: AppColors.pastel2,
          iconColor: AppColors.accent2,
          label: 'Chế độ gọn',
          subtitle: 'Thu gọn khoảng cách hiển thị',
          value: settings.compactMode,
          onChanged: settings.toggleCompactMode,
        ),
      ],
    );
  }

  // ============================================================
  // SYSTEM
  // ============================================================
  Widget _buildSystemCard() {
    return _card(
      children: [
        _tile(
          icon: Icons.refresh_rounded,
          iconBg: AppColors.pastel3,
          iconColor: AppColors.accent3,
          label: 'Làm mới dữ liệu',
          subtitle: 'Tải lại đơn / món / danh mục từ máy chủ',
          onTap: _refreshAll,
        ),
        _divider(),
        _tile(
          icon: Icons.restore_rounded,
          iconBg: AppColors.pastel4,
          iconColor: AppColors.accent4,
          label: 'Khôi phục cài đặt mặc định',
          subtitle: 'Reset giao diện và tuỳ chọn',
          onTap: _confirmResetSettings,
        ),
      ],
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  Widget _buildLogoutCard() {
    return InkWell(
      onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.statusCancelled,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.statusCancelledText,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.statusCancelledText,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.statusCancelledText,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SHARED WIDGETS
  // ============================================================
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
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
      child: Column(children: children),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
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

  Widget _switchTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent1,
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Divider(height: 1, color: Color(0xFFF5EEE9)),
      );

  // ============================================================
  // ACTIONS
  // ============================================================
  Future<void> _refreshAll() async {
    final ord = context.read<OrderProvider>();
    final food = context.read<FoodProvider>();
    final cat = context.read<CategoryProvider>();
    await Future.wait([
      ord.fetchOrders(),
      food.fetchFoods(),
      cat.fetchCategories(),
    ]);
    if (!mounted) return;
    _toast('Đã tải lại dữ liệu');
  }

  Future<void> _confirmResetSettings() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Khôi phục mặc định?'),
        content: const Text(
          'Mọi tuỳ chỉnh giao diện và bật/tắt sẽ trở về mặc định.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent1,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Khôi phục'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    context.read<AdminSettingsProvider>().resetToDefaults();
    _toast('Đã khôi phục cài đặt mặc định');
  }

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            error ? AppColors.statusCancelledText : AppColors.accent3,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

}
