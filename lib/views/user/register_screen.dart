import 'package:doancuoiki/widgets/notification/app_snackbar.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';

import '../../../data/services/auth_service.dart';
import '../../../data/services/user_service.dart';

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
  final UserService userService = UserService();

  // Rang buoc SDT VN: bat dau 0, theo sau 9 chu so (vd: 0901234567)
  // Cac dau so dau dung: 03x/05x/07x/08x/09x
  static final RegExp _phoneRegex = RegExp(r'^0(3|5|7|8|9)\d{8}$');
  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

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
      AppSnackbar.showError(context, "Vui lòng nhập đầy đủ");
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      AppSnackbar.showError(context, "Email không hợp lệ");
      return;
    }

    if (!_phoneRegex.hasMatch(phone)) {
      AppSnackbar.showError(
        context,
        "Số điện thoại không hợp lệ (10 số, bắt đầu bằng 03/05/07/08/09)",
      );
      return;
    }

    if (password.length < 6) {
      AppSnackbar.showError(context, "Mật khẩu phải có ít nhất 6 ký tự");
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
      // Check email duy nhat trong DB (UNIQUE) — fail-fast truoc khi POST
      // de hien thong bao ro rang thay vi de backend tra SqlException.
      // SDT cung kiem ket hop de tranh UNIQUE violation tu phia DB.
      final existing = await userService.getUsers();
      final emailLower = email.toLowerCase();
      final emailDup = existing.any(
        (u) => (u.email ?? '').toLowerCase() == emailLower,
      );
      if (emailDup) {
        setState(() => isLoading = false);
        AppSnackbar.showError(context, "Email đã được sử dụng");
        return;
      }
      final phoneDup = existing.any((u) => (u.phone ?? '') == phone);
      if (phoneDup) {
        setState(() => isLoading = false);
        AppSnackbar.showError(context, "Số điện thoại đã được sử dụng");
        return;
      }

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

                icon: '📱',

                keyboardType: TextInputType.phone,
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

    TextInputType? keyboardType,
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

              keyboardType: keyboardType,

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
