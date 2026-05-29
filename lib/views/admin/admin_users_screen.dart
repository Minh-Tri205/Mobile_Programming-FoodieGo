import 'package:doancuoiki/core/constants/app_colors.dart';
import 'package:doancuoiki/core/constants/app_routes.dart';
import 'package:doancuoiki/core/constants/app_text_styles.dart';
import 'package:doancuoiki/data/providers/user_provider.dart';
import 'package:doancuoiki/models/user_model.dart';
import 'package:doancuoiki/widgets/admin_widgets/app_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String searchText = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<UserProvider>().fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> avatarColors = [
      AppColors.pastel1,
      AppColors.pastel2,
      AppColors.pastel3,
      AppColors.pastel5,
    ];

    final List<Color> accentColors = [
      AppColors.accent1,
      AppColors.accent2,
      AppColors.accent3,
      AppColors.accent5,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Quản lý người dùng', style: AppTextStyles.heading2),

        backgroundColor: Colors.transparent,

        elevation: 0,

        centerTitle: false,

        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list_rounded,
              color: AppColors.textPrimary,
            ),

            onPressed: () {},
          ),
        ],
      ),

      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = provider.users.where((user) {
            final keyword = searchText.toLowerCase();

            return user.fullName.toLowerCase().contains(keyword) ||
                (user.email?.toLowerCase().contains(keyword) ?? false);
          }).toList();

          if (users.isEmpty) {
            return const Center(child: Text('Không có người dùng'));
          }

          return Column(
            children: [
              // SEARCH
              AppSearchBar(
                hintText: 'Tìm kiếm tên, email...',

                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
              ),

              // LIST
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),

                  itemCount: users.length,

                  itemBuilder: (context, index) {
                    final user = users[index];

                    final colorIndex = index % avatarColors.length;

                    final bool isActive = user.isActive ?? false;

                    return InkWell(
                      borderRadius: BorderRadius.circular(24),

                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.adminUserDetail,
                          arguments: user.userId,
                        );
                      },

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),

                        decoration: BoxDecoration(
                          color: AppColors.card,

                          borderRadius: BorderRadius.circular(24),

                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textPrimary.withOpacity(0.04),

                              blurRadius: 10,

                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),

                          leading: CircleAvatar(
                            radius: 30,

                            backgroundColor: avatarColors[colorIndex],

                            child:
                                user.avatarUrl != null &&
                                    user.avatarUrl!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      user.avatarUrl!,

                                      width: 60,
                                      height: 60,

                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Text(
                                    user.fullName.substring(0, 1).toUpperCase(),

                                    style: TextStyle(
                                      color: accentColors[colorIndex],

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),

                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user.fullName,

                                  style: AppTextStyles.heading3,

                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              const SizedBox(width: 8),

                              _buildStatusBadge(isActive),
                            ],
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const SizedBox(height: 4),

                              Text(
                                user.email ?? 'Không có email',

                                style: AppTextStyles.bodyMuted,
                              ),

                              const SizedBox(height: 4),

                              Text(
                                user.role ?? 'User',

                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),

                          trailing: IconButton(
                            icon: const Icon(
                              Icons.more_vert_rounded,

                              color: AppColors.textMuted,
                            ),

                            onPressed: () => _showUserOptions(context, user),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),

      decoration: BoxDecoration(
        color: isActive ? AppColors.statusConfirmed : AppColors.statusCancelled,

        borderRadius: BorderRadius.circular(6),
      ),

      child: Text(
        isActive ? 'Hoạt động' : 'Bị khóa',

        style: AppTextStyles.label.copyWith(
          fontSize: 9,

          color: isActive
              ? AppColors.statusConfirmedText
              : AppColors.statusCancelledText,
        ),
      ),
    );
  }

  void _showUserOptions(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
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

            const SizedBox(height: 24),

            // ================= HISTORY (GIỮ NGUYÊN) =================
            _buildOptionTile(
              Icons.history_rounded,
              'Lịch sử mua hàng',
              AppColors.accent3,
              () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRoutes.adminUserHistory,
                  arguments: user.userId,
                );
              },
            ),

            // ================= LOCK / UNLOCK =================
            _buildOptionTile(
              Icons.block_flipped,
              user.isActive == true ? 'Khóa tài khoản' : 'Mở khóa tài khoản',
              AppColors.statusCancelledText,
              () async {
                Navigator.pop(context);

                // 👉 dùng toggleStatus (KHÔNG updateUser nữa)
                await context.read<UserProvider>().toggleStatus(user.userId);
              },
            ),

            // ================= CHANGE ROLE =================
            _buildOptionTile(
              Icons.admin_panel_settings,
              user.role == 'admin'
                  ? 'Chuyển thành Customer'
                  : 'Chuyển thành Admin',
              AppColors.accent1,
              () async {
                Navigator.pop(context);

                final newRole = user.role == 'admin' ? 'customer' : 'admin';

                await context.read<UserProvider>().changeRole(
                  user.userId,
                  newRole,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),

      title: Text(title, style: AppTextStyles.body),

      onTap: onTap,
    );
  }
}
