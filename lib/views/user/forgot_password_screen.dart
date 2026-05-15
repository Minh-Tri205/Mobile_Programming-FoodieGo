// lib/views/user/forgot_password_screen.dart
// FILE MỚI HOÀN TOÀN — Màn hình quên mật khẩu
// Thêm route: AppRoutes.forgotPassword = '/forgot-password'
// Trong login_screen.dart: đổi onTap quên mật khẩu thành:
//   Navigator.pushNamed(context, AppRoutes.forgotPassword);

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  // Bước 1: nhập email → Bước 2: nhập OTP → Bước 3: đặt mật khẩu mới
  int _step = 1;
  bool _isLoading = false;

  // Bước 2
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(4, (_) => FocusNode());

  // Bước 3
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Giả lập gửi OTP
  void _sendOtp() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnack('Vui lòng nhập email hợp lệ', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _step = 2;
      });
      _showSnack('Mã OTP đã gửi tới $email');
    });
  }

  // Giả lập xác nhận OTP (mã mẫu: 1234)
  void _verifyOtp() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 4) {
      _showSnack('Vui lòng nhập đủ 4 số OTP', isError: true);
      return;
    }
    // Demo: OTP đúng là 1234
    if (otp != '1234') {
      _showSnack('Mã OTP không đúng. Thử lại!', isError: true);
      return;
    }
    setState(() => _step = 3);
  }

  // Giả lập đặt mật khẩu mới
  void _resetPassword() {
    final newPw = _newPasswordController.text.trim();
    final confirmPw = _confirmPasswordController.text.trim();
    if (newPw.length < 6) {
      _showSnack('Mật khẩu phải có ít nhất 6 ký tự', isError: true);
      return;
    }
    if (newPw != confirmPw) {
      _showSnack('Mật khẩu xác nhận không khớp', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('✅ Đổi mật khẩu thành công!');
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        Navigator.pop(context);
      });
    });
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : AppColors.accent3,
        duration: const Duration(seconds: 2),
      ),
    );
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
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_step > 1) {
                        setState(() => _step--);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Progress steps
              _buildStepIndicator(),

              const SizedBox(height: 36),

              // Nội dung từng bước
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 1
                      ? _buildStep1()
                      : _step == 2
                          ? _buildStep2()
                          : _buildStep3(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Thanh hiển thị bước 1 / 2 / 3
  Widget _buildStepIndicator() {
    const steps = ['Email', 'OTP', 'Mật khẩu'];
    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i + 1 <= _step;
        final isCurrent = i + 1 == _step;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.accent1 : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive
                              ? AppColors.accent1
                              : AppColors.divider,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isActive && !isCurrent
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textMuted,
                              ),
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w400,
                        color: isActive
                            ? AppColors.accent1
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 22),
                    color: i + 1 < _step
                        ? AppColors.accent1
                        : AppColors.divider,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  // ─── BƯỚC 1: Nhập email ───────────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quên mật khẩu? 🔑',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nhập email của bạn. Chúng tôi sẽ gửi mã OTP để xác nhận.',
          style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.5),
        ),
        const SizedBox(height: 32),
        _inputBox(
          controller: _emailController,
          hint: 'Địa chỉ email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        _primaryBtn(
          label: 'Gửi mã OTP',
          onTap: _sendOtp,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  // ─── BƯỚC 2: Nhập OTP ─────────────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nhập mã OTP 📩',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Mã 4 số đã gửi tới ${_emailController.text.trim()}',
          style: const TextStyle(
              fontSize: 14, color: AppColors.textMuted, height: 1.5),
        ),
        const SizedBox(height: 36),

        // 4 ô OTP
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (i) => _otpBox(i)),
        ),

        const SizedBox(height: 16),

        // Gửi lại OTP
        Center(
          child: GestureDetector(
            onTap: () => _showSnack('Đã gửi lại OTP!'),
            child: const Text(
              'Gửi lại mã',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.accent1,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),
        _primaryBtn(label: 'Xác nhận', onTap: _verifyOtp),

        const SizedBox(height: 12),
        Center(
          child: Text(
            '💡 Demo: nhập 1234 để tiếp tục',
            style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted.withOpacity(0.6)),
          ),
        ),
      ],
    );
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 64,
      height: 64,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.accent1, width: 2),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 3) {
            _otpFocusNodes[index + 1].requestFocus();
          } else if (val.isEmpty && index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  // ─── BƯỚC 3: Đặt mật khẩu mới ────────────────────────────────────────────
  Widget _buildStep3() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mật khẩu mới 🔒',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tạo mật khẩu mới ít nhất 6 ký tự.',
          style: TextStyle(
              fontSize: 14, color: AppColors.textMuted, height: 1.5),
        ),
        const SizedBox(height: 32),
        _inputBox(
          controller: _newPasswordController,
          hint: 'Mật khẩu mới',
          icon: Icons.lock_outline,
          isPassword: true,
          obscure: _obscureNew,
          onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
        ),
        const SizedBox(height: 14),
        _inputBox(
          controller: _confirmPasswordController,
          hint: 'Xác nhận mật khẩu',
          icon: Icons.lock_outline,
          isPassword: true,
          obscure: _obscureConfirm,
          onToggleObscure: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
        ),
        const SizedBox(height: 24),
        _primaryBtn(
          label: 'Xác nhận đổi mật khẩu',
          onTap: _resetPassword,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  // ─── Shared widgets ───────────────────────────────────────────────────────

  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword ? obscure : false,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle:
                    const TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
          ),
          if (isPassword && onToggleObscure != null)
            GestureDetector(
              onTap: onToggleObscure,
              child: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }

  Widget _primaryBtn({
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.accent1,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}