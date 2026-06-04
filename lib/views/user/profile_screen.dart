// lib/views/user/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/providers/favorite_provider.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/providers/review_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../models/user_model.dart';
import '../../../widgets/navigation/app_bottom_nav.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final userProvider = context.read<UserProvider>();
      final orderProvider = context.read<OrderProvider>();
      final favProvider = context.read<FavoriteProvider>();
      final reviewProvider = context.read<ReviewProvider>();

      final id = userProvider.currentUserId;
      if (id != null) {
        userProvider.fetchUserById(id);
        orderProvider.fetchOrdersByUserId(id);
        favProvider.ensureLoadedForUser(id);
        if (reviewProvider.reviews.isEmpty) reviewProvider.fetchAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          final user = provider.currentUser;

          if (provider.isLoadingProfile || user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                // Header gradient + curved bottom + decorative circles
                _buildHeader(user),

                // Floating stats card (overlap header)
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: _buildStatsCard(user),
                ),

                const SizedBox(height: 4),

                // Menu groups
                _buildMenuGroup(
                  title: 'TÀI KHOẢN',
                  items: [
                    _MenuEntry(
                      icon: Icons.notifications_outlined,
                      iconBg: AppColors.pastel4,
                      iconColor: AppColors.accent4,
                      label: 'Thông báo',
                      badge: '3',
                      route: AppRoutes.notifications,
                    ),
                    _MenuEntry(
                      icon: Icons.location_on_outlined,
                      iconBg: AppColors.pastel2,
                      iconColor: AppColors.accent2,
                      label: 'Địa chỉ của tôi',
                      route: AppRoutes.addresses,
                    ),
                    _MenuEntry(
                      icon: Icons.credit_card_outlined,
                      iconBg: AppColors.pastel3,
                      iconColor: AppColors.accent3,
                      label: 'Phương thức thanh toán',
                    ),
                    _MenuEntry(
                      icon: Icons.favorite_border_rounded,
                      iconBg: AppColors.pastel5,
                      iconColor: AppColors.accent5,
                      label: 'Món ăn yêu thích',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FavoritesScreen(),
                        ),
                      ),
                    ),
                    _MenuEntry(
                      icon: Icons.receipt_long_outlined,
                      iconBg: AppColors.pastel1,
                      iconColor: AppColors.accent1,
                      label: 'Lịch sử đơn hàng',
                      route: AppRoutes.orders,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _buildMenuGroup(
                  title: 'BẢO MẬT',
                  items: [
                    _MenuEntry(
                      icon: Icons.lock_outline_rounded,
                      iconBg: AppColors.pastel4,
                      iconColor: AppColors.accent4,
                      label: 'Đổi mật khẩu',
                      route: AppRoutes.forgotPassword,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _buildMenuGroup(
                  title: 'HỖ TRỢ',
                  items: [
                    _MenuEntry(
                      icon: Icons.headset_mic_outlined,
                      iconBg: AppColors.pastel1,
                      iconColor: AppColors.accent1,
                      label: 'Trung tâm hỗ trợ',
                    ),
                    _MenuEntry(
                      icon: Icons.info_outline_rounded,
                      iconBg: AppColors.pastel2,
                      iconColor: AppColors.accent2,
                      label: 'Về ứng dụng',
                    ),
                    _MenuEntry(
                      icon: Icons.settings_outlined,
                      iconBg: AppColors.pastel3,
                      iconColor: AppColors.accent3,
                      label: 'Cài đặt',
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _buildLogoutCard(context),

                const SizedBox(height: 20),

                Text(
                  'FoodieGo  •  v1.0.0',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  // =========================================================
  // HEADER — gradient + curved bottom + decorative circles
  // =========================================================
  Widget _buildHeader(UserModel user) {
    final tier = _tierFor(user.loyaltyPoints ?? 0);

    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 64, 20, 60),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.pastel1, AppColors.pastel5],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative circles
            Positioned(
              top: -30,
              right: -20,
              child: _decorCircle(120, Colors.white.withOpacity(0.18)),
            ),
            Positioned(
              top: 40,
              left: -40,
              child: _decorCircle(90, Colors.white.withOpacity(0.12)),
            ),

            Column(
              children: [
                // Avatar with white ring + shadow + tier badge overlay
                GestureDetector(
                  onTap: _uploadingAvatar ? null : _showAvatarPickerSheet,
                  child: Stack(
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
                      if (_uploadingAvatar)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            tier.label,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  user.email ?? user.phone ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),

                const SizedBox(height: 12),

                // Edit profile pill — mo form sua ten + SDT
                GestureDetector(
                  onTap: _uploadingAvatar ? null : () => _showEditInfoSheet(user),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.accent1.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: AppColors.accent1,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Chỉnh sửa hồ sơ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
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
        width: 84,
        height: 84,
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
      color: AppColors.pastel1,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: AppColors.accent1,
        ),
      ),
    );
  }

  String _firstLetter(String s) {
    final t = s.trim();
    if (t.isEmpty) return '?';
    return t.characters.first.toUpperCase();
  }

  // =========================================================
  // STATS CARD — floating elevated card with 3 stats + dividers
  // =========================================================
  Widget _buildStatsCard(UserModel user) {
    final ordersCount = context.watch<OrderProvider>().orders.length;
    final reviewsCount = context
        .watch<ReviewProvider>()
        .ofUser(user.userId)
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
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
            icon: Icons.workspace_premium_rounded,
            color: AppColors.accent4,
            value: '${user.loyaltyPoints ?? 0}',
            label: 'Điểm',
            showDivider: true,
          ),
          _statCell(
            icon: Icons.receipt_long_rounded,
            color: AppColors.accent1,
            value: '$ordersCount',
            label: 'Đơn hàng',
            showDivider: true,
          ),
          _statCell(
            icon: Icons.star_rounded,
            color: AppColors.accent3,
            value: '$reviewsCount',
            label: 'Đánh giá',
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
                fontSize: 18,
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
  // MENU GROUP — section title + card chứa list item
  // =========================================================
  Widget _buildMenuGroup({
    required String title,
    required List<_MenuEntry> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
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
              children: List.generate(items.length, (i) {
                final isLast = i == items.length - 1;
                return _buildMenuItem(items[i], isLast: isLast);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuEntry e, {required bool isLast}) {
    return InkWell(
      onTap: e.onTap ??
          (e.route != null
              ? () => Navigator.pushNamed(context, e.route!)
              : () {}),
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(18),
        bottom: isLast ? const Radius.circular(18) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFFF5EEE9), width: 1),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: e.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(e.icon, color: e.iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                e.label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (e.badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent1,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  e.badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // LOGOUT — standalone red card
  // =========================================================
  Widget _buildLogoutCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
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
      ),
    );
  }

  // =========================================================
  // EDIT INFO SHEET — sua ten + SDT
  // =========================================================
  void _showEditInfoSheet(UserModel user) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final phoneCtrl = TextEditingController(text: user.phone ?? '');
    final phoneRegex = RegExp(r'^0(3|5|7|8|9)\d{8}$');
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              Future<void> save() async {
                final name = nameCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                if (name.isEmpty) {
                  _toast(ctx, 'Vui lòng nhập họ tên', error: true);
                  return;
                }
                if (phone.isEmpty) {
                  _toast(ctx, 'Vui lòng nhập số điện thoại', error: true);
                  return;
                }
                if (!phoneRegex.hasMatch(phone)) {
                  _toast(
                    ctx,
                    'SĐT không hợp lệ (10 số, bắt đầu 03/05/07/08/09)',
                    error: true,
                  );
                  return;
                }

                // Khong co gi thay doi -> dong sheet
                if (name == user.fullName && phone == (user.phone ?? '')) {
                  Navigator.pop(ctx);
                  return;
                }

                setSheetState(() => saving = true);
                try {
                  await context.read<UserProvider>().updateUser(
                    user.userId,
                    {'fullName': name, 'phone': phone},
                  );
                  // Refresh tu server de chac chan
                  await context
                      .read<UserProvider>()
                      .fetchUserById(user.userId);
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  _toast(context, 'Cập nhật hồ sơ thành công');
                } catch (e) {
                  if (!ctx.mounted) return;
                  setSheetState(() => saving = false);
                  _toast(ctx, _friendlyUserUpdateError(e), error: true);
                }
              }

              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      'Chỉnh sửa hồ sơ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _editField(
                      controller: nameCtrl,
                      icon: Icons.person_outline_rounded,
                      hint: 'Họ và tên',
                    ),
                    const SizedBox(height: 12),
                    _editField(
                      controller: phoneCtrl,
                      icon: Icons.phone_iphone_rounded,
                      hint: 'Số điện thoại (10 số)',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: saving ? null : () => Navigator.pop(ctx),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFEFEF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Huỷ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: saving ? null : save,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.accent1,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Lưu thay đổi',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _editField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toast(BuildContext ctx, String msg, {bool error = false}) {
    ScaffoldMessenger.of(ctx).showSnackBar(
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

  // Map loi backend (SqlException UNIQUE / 409 / "duplicate") -> message tieng Viet
  String _friendlyUserUpdateError(Object e) {
    final raw = e.toString().toLowerCase();
    if (raw.contains('unique') ||
        raw.contains('duplicate') ||
        raw.contains('uq_users_phone') ||
        raw.contains('ix_users_phone') ||
        raw.contains('cannot insert duplicate')) {
      // Phone va email deu co UNIQUE — phan biet neu detect duoc
      if (raw.contains('phone')) {
        return 'Số điện thoại đã được sử dụng bởi tài khoản khác';
      }
      if (raw.contains('email')) {
        return 'Email đã được sử dụng bởi tài khoản khác';
      }
      return 'Thông tin đã được sử dụng bởi tài khoản khác';
    }
    if (raw.contains('failed host lookup') || raw.contains('socketexception')) {
      return 'Không kết nối được máy chủ';
    }
    return 'Cập nhật thất bại: $e';
  }

  // =========================================================
  // AVATAR PICKER — bottom sheet: camera / gallery
  // =========================================================
  void _showAvatarPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Đổi ảnh đại diện',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _avatarOptionTile(
                icon: Icons.photo_camera_outlined,
                iconBg: AppColors.pastel1,
                iconColor: AppColors.accent1,
                label: 'Chụp ảnh',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _pickFromCamera();
                },
              ),
              const SizedBox(height: 10),
              _avatarOptionTile(
                icon: Icons.photo_library_outlined,
                iconBg: AppColors.pastel2,
                iconColor: AppColors.accent2,
                label: 'Chọn từ thư viện',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _pickFromGallery();
                },
              ),
              const SizedBox(height: 10),
              _avatarOptionTile(
                icon: Icons.close_rounded,
                iconBg: const Color(0xFFEFEFEF),
                iconColor: AppColors.textMuted,
                label: 'Huỷ',
                onTap: () => Navigator.pop(sheetCtx),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _avatarOptionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F4),
          borderRadius: BorderRadius.circular(14),
        ),
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
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? x = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (x != null) {
        await _uploadAvatar(x.path);
      }
    } catch (e) {
      _showErrorDialog('Không mở được camera: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? x = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (x != null) {
        await _uploadAvatar(x.path);
      }
    } catch (e) {
      _showErrorDialog('Không mở được thư viện: $e');
    }
  }

  Future<void> _uploadAvatar(String filePath) async {
    final userProv = context.read<UserProvider>();
    final id = userProv.currentUserId ?? userProv.currentUser?.userId;
    if (id == null) {
      _showErrorDialog('Vui lòng đăng nhập lại');
      return;
    }

    setState(() => _uploadingAvatar = true);
    try {
      await userProv.updateUserMultipart(
        id,
        avatarFilePath: filePath,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật ảnh đại diện thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
      }
    }
  }

  void _showErrorDialog(String msg) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lỗi'),
        content: SelectableText(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TIER — badge theo loyaltyPoints (gán cứng ngưỡng)
  // =========================================================
  _Tier _tierFor(int points) {
    if (points >= 500) return const _Tier('VIP', Color(0xFFB07BFF));
    if (points >= 200) return const _Tier('GOLD', Color(0xFFE6A817));
    if (points >= 50) return const _Tier('SILVER', Color(0xFF9DA9B5));
    return const _Tier('NEW', Color(0xFF7CC891));
  }
}

// Clipper tạo curved bottom cho header
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

// Model class cho menu entry — tránh truyền nhiều args
class _MenuEntry {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String? badge;
  final String? route;
  final VoidCallback? onTap;

  const _MenuEntry({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.badge,
    this.route,
    this.onTap,
  });
}

class _Tier {
  final String label;
  final Color color;
  const _Tier(this.label, this.color);
}
