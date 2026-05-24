import 'package:doancuoiki/widgets/admin_widgets/app_search_bar.dart';
import 'package:doancuoiki/widgets/notification/app_snackbar.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';

import '../../../data/services/auth_service.dart';

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

  final phoneController = TextEditingController();

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;

  bool isLoading = false;

  final AuthService authService = AuthService();

  Future<void> register() async {
    final fullName = fullNameController.text.trim();

    final email = emailController.text.trim();

    final password = passwordController.text.trim();

    final confirmPassword = confirmPasswordController.text.trim();

    final phone = phoneController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phone.isEmpty) {
      AppSnackbar.showError(context, "'Vui lòng nhập đầy đủ");
      return;
    }

    if (password != confirmPassword) {
      AppSnackbar.showError(context, "Mật khẩu không khớp");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final success = await authService.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
      );

      if (success) {
        AppSnackbar.showSuccess(context, "Đăng ký thành công");
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        AppSnackbar.showError(context, 'Đăng ký thất bại');
      }
    } catch (e) {
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

              const SizedBox(height: 16),

              _buildInput(
                controller: phoneController,

                hint: 'Số điện thoại',

                icon: '',
              ),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: isLoading ? null : register,

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(vertical: 15),

                  decoration: BoxDecoration(
                    color: AppColors.accent1,

                    borderRadius: BorderRadius.circular(16),
                  ),

                  alignment: Alignment.center,

                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Tạo tài khoản',

                          style: AppTextStyles.button,
                        ),
                ),
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
}
