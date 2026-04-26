import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;

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

              /// Logo / Title
              Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
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

              /// Email
              _buildInput(
                controller: emailController,
                hint: 'Email',
                icon: '📧',
              ),

              const SizedBox(height: 16),

              /// Password
              _buildInput(
                controller: passwordController,
                hint: 'Mật khẩu',
                icon: '🔒',
                isPassword: true,
              ),

              const SizedBox(height: 12),

              /// Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // TODO
                  },
                  child: const Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Login Button
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.accent1,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Đăng nhập', style: AppTextStyles.button),
                ),
              ),

              const SizedBox(height: 20),

              /// Divider
              Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: AppColors.divider),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Hoặc'),
                  ),
                  Expanded(
                    child: Container(height: 1, color: AppColors.divider),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Social login
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _socialButton('G'),
                  _socialButton('f'),
                  _socialButton(''),
                ],
              ),

              const Spacer(),

              /// Register
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

  /// INPUT FIELD
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
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Text(_obscurePassword ? '👁️' : '🙈'),
            ),
        ],
      ),
    );
  }

  /// SOCIAL BUTTON
  Widget _socialButton(String label) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }
}
