import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.pastel5,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('📝', style: TextStyle(fontSize: 32)),
              ),

              const SizedBox(height: 18),

              const Text('Tạo tài khoản mới', style: AppTextStyles.heading2),

              const SizedBox(height: 6),

              const Text(
                'Đăng ký để bắt đầu hành trình ẩm thực',
                style: AppTextStyles.bodyMuted,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              _buildInput(
                controller: fullNameController,
                hint: 'Họ và tên',
                icon: '👤',
              ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

              _buildInput(
                controller: confirmPasswordController,
                hint: 'Xác nhận mật khẩu',
                icon: '🔐',
                isConfirmPassword: true,
              ),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.accent1,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent1.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Tạo tài khoản',
                    style: AppTextStyles.button,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: AppColors.divider),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Hoặc đăng ký với'),
                  ),
                  Expanded(
                    child: Container(height: 1, color: AppColors.divider),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _socialButton('G'),
                  _socialButton('f'),
                  _socialButton(''),
                ],
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Đã có tài khoản?',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent1,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
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
    bool isConfirmPassword = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword
                  ? _obscurePassword
                  : isConfirmPassword
                  ? _obscureConfirmPassword
                  : false,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodyMuted,
                border: InputBorder.none,
              ),
            ),
          ),
          if (isPassword || isConfirmPassword)
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isPassword) {
                    _obscurePassword = !_obscurePassword;
                  } else {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  }
                });
              },
              child: Text(
                (isPassword && _obscurePassword) ||
                        (isConfirmPassword && _obscureConfirmPassword)
                    ? '👁️'
                    : '🙈',
              ),
            ),
        ],
      ),
    );
  }

  Widget _socialButton(String label) {
    return Container(
      width: 54,
      height: 54,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}
