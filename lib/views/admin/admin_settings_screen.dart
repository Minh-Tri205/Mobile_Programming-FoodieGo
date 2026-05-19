import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/common/back_button_widget.dart';
import '../../widgets/common/primary_button.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  // Profile Info Controllers
  final _adminNameController = TextEditingController(text: 'Quản trị viên');
  final _emailController =
      TextEditingController(text: 'admin@foodapp.com');
  final _phoneController = TextEditingController(text: '0987654321');
  final _addressController =
      TextEditingController(text: '456 Lý Tự Trọng, Quận 1, TP.HCM');

  // Password Controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _adminNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveAdminProfile() {
    if (_adminNameController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập tên quản trị viên', isError: true);
      return;
    }
    if (_emailController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập email', isError: true);
      return;
    }
    if (_phoneController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập số điện thoại', isError: true);
      return;
    }
    if (_addressController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập địa chỉ', isError: true);
      return;
    }

    _showSnackBar('✅ Cập nhật thông tin thành công!', isError: false);
  }

  void _changeAdminPassword() {
    if (_currentPasswordController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập mật khẩu hiện tại', isError: true);
      return;
    }
    if (_newPasswordController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập mật khẩu mới', isError: true);
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showSnackBar('Mật khẩu phải có ít nhất 6 ký tự', isError: true);
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Mật khẩu không khớp', isError: true);
      return;
    }

    _showSnackBar('✅ Thay đổi mật khẩu thành công! Vui lòng đăng nhập lại.',
        isError: false);
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AppColors.statusCancelledText
            : AppColors.accent3,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButtonWidget(onTap: () => Navigator.pop(context)),
        title: const Text('Cài đặt quản trị', style: AppTextStyles.heading2),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.accent1,
              labelColor: AppColors.accent1,
              unselectedLabelColor: AppColors.textMuted,
              tabs: const [
                Tab(text: 'Chỉnh sửa hồ sơ'),
                Tab(text: 'Đổi mật khẩu'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Edit Profile
                _buildEditProfileTab(),

                // Tab 2: Change Password
                _buildChangePasswordTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Thông tin cá nhân'),
          const SizedBox(height: 12),
          
          // Avatar
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.pastel1,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const Icon(Icons.admin_panel_settings_rounded,
                      size: 50, color: AppColors.accent1),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.accent1,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildInputField(
            controller: _adminNameController,
            label: 'Tên quản trị viên',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _phoneController,
            label: 'Số điện thoại',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _addressController,
            label: 'Địa chỉ',
            icon: Icons.location_on_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: '💾 Lưu thay đổi',
            onTap: _saveAdminProfile,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildChangePasswordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pastel3.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.accent1.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 20, color: AppColors.accent1),
                const SizedBox(width: 12),
                Expanded(
                  child: const Text(
                    'Mật khẩu mạnh giúp bảo vệ tài khoản quản trị của bạn.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionLabel('Mật khẩu hiện tại'),
          const SizedBox(height: 12),
          _buildPasswordField(
            controller: _currentPasswordController,
            label: 'Mật khẩu hiện tại',
            showPassword: _showCurrentPassword,
            onToggle: () =>
                setState(() => _showCurrentPassword = !_showCurrentPassword),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionLabel('Mật khẩu mới'),
          const SizedBox(height: 12),
          _buildPasswordField(
            controller: _newPasswordController,
            label: 'Mật khẩu mới (Tối thiểu 6 ký tự)',
            showPassword: _showNewPassword,
            onToggle: () =>
                setState(() => _showNewPassword = !_showNewPassword),
          ),
          const SizedBox(height: 12),
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Xác nhận mật khẩu',
            showPassword: _showConfirmPassword,
            onToggle: () =>
                setState(() => _showConfirmPassword = !_showConfirmPassword),
          ),
          
          const SizedBox(height: 24),
          
          PrimaryButton(
            label: '🔐 Thay đổi mật khẩu',
            onTap: _changeAdminPassword,
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Icon(icon, size: 18, color: AppColors.textMuted),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool showPassword,
    required Function() onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: !showPassword,
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              showPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
