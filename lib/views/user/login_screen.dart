import 'package:doancuoiki/data/providers/notification_provider.dart';
import 'package:doancuoiki/data/providers/user_provider.dart';
import 'package:doancuoiki/widgets/notification/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';

import '../../../data/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  bool _obscurePassword = true;

  bool isLoading = false;

  final AuthService authService = AuthService();

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đầy đủ')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = await authService.login(email, password);
      if (!mounted) return;

      if (user == null) {
        AppSnackbar.showError(context, "Email hoặc mật khẩu không chính xác");
        return;
      }

      context.read<UserProvider>().setCurrentUserId(user.userId);

      // Khoi dong Notification: fetch list + unread + ket noi SignalR realtime.
      // Dat hook onPushed de hien Snackbar khi co thong bao moi (toan app).
      final notifProv = context.read<NotificationProvider>();
      notifProv.onPushed = (n) {
        if (!mounted) return;
        AppSnackbar.showInfo(context, '${n.title}: ${n.body}');
      };
      notifProv.bootstrap(user.userId); // khong await — chay nen

      // CHECK ROLE
      if (user.role?.toLowerCase() == 'admin') {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'Lỗi: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            children: [
              const SizedBox(height: 40),

              Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,

                    decoration: const BoxDecoration(
                      color: AppColors.pastel1,

                      shape: BoxShape.circle,
                    ),

                    alignment: Alignment.center,

                    child: const Text('🍔', style: TextStyle(fontSize: 30)),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Chào mừng trở lại 👋',
                    style: AppTextStyles.heading2,
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Đăng nhập để tiếp tục',
                    style: AppTextStyles.bodyMuted,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              _buildInput(
                controller: emailController,
                hint: 'Email',
                icon: '📧',
              ),

              const SizedBox(height: 16),

              _buildInput(
                controller: passwordController,

                hint: 'Mật khẩu',

                icon: '🔒',

                isPassword: true,
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.forgotPassword,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent1,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              GestureDetector(
                onTap: isLoading ? null : login,

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(vertical: 14),

                  decoration: BoxDecoration(
                    color: AppColors.accent1,

                    borderRadius: BorderRadius.circular(16),
                  ),

                  alignment: Alignment.center,

                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Đăng nhập', style: AppTextStyles.button),
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text(
                    'Chưa có tài khoản?',
                    style: AppTextStyles.bodyMuted,
                  ),

                  const SizedBox(width: 6),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },

                    child: const Text(
                      'Đăng ký',

                      style: TextStyle(
                        fontWeight: FontWeight.w700,

                        color: AppColors.accent1,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,

    required String hint,

    required String icon,

    bool isPassword = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          Text(icon),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: controller,

              obscureText: isPassword ? _obscurePassword : false,

              decoration: InputDecoration(
                hintText: hint,

                border: InputBorder.none,
              ),
            ),
          ),

          if (isPassword)
            GestureDetector(
              onTap: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },

              child: Text(_obscurePassword ? '👁️' : '🙈'),
            ),
        ],
      ),
    );
  }
}
