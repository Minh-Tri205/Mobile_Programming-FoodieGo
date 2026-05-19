import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/back_button_widget.dart';
import '../../widgets/common/primary_button.dart';

class CustomerProfileEditScreen extends StatefulWidget {
  const CustomerProfileEditScreen({super.key});

  @override
  State<CustomerProfileEditScreen> createState() =>
      _CustomerProfileEditScreenState();
}

class _CustomerProfileEditScreenState extends State<CustomerProfileEditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  // Profile Info Controllers
  final _fullNameController = TextEditingController(text: 'Nguyễn Minh Anh');
  final _emailController =
      TextEditingController(text: 'minhanh@gmail.com');
  final _phoneController = TextEditingController(text: '0901234567');
  final _addressController =
      TextEditingController(text: '123 Nguyễn Huệ, Quận 1, TP.HCM');
  String _selectedGender = 'Nữ';
  String _selectedDOB = '05/10/1995';

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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_fullNameController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập tên đầy đủ', isError: true);
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

  void _changePassword() {
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

    _showSnackBar('✅ Thay đổi mật khẩu thành công!', isError: false);
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xóa tài khoản',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded,
                color: AppColors.statusCancelledText, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Bạn chắc chắn muốn xóa tài khoản?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hành động này không thể hoàn tác. Tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCancelledText,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _showPasswordVerificationDialog();
            },
            child: const Text('Xóa tài khoản',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPasswordVerificationDialog() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận mật khẩu',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nhập mật khẩu để xác nhận',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Mật khẩu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCancelledText,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (passwordController.text.isEmpty) {
                _showSnackBar('Vui lòng nhập mật khẩu', isError: true);
                return;
              }
              Navigator.pop(ctx);
              _showSnackBar('✅ Tài khoản đã được xóa', isError: false);
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pop(context);
              });
            },
            child: const Text('Xác nhận',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 10, 5),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDOB =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  BackButtonWidget(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  const Text(
                    'Quản lý hồ sơ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accent1,
                labelColor: AppColors.accent1,
                unselectedLabelColor: AppColors.textMuted,
                tabs: const [
                  Tab(text: 'Thông tin'),
                  Tab(text: 'Mật khẩu'),
                  Tab(text: 'Xóa TK'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Profile Information
                  _buildProfileInfoTab(),

                  // Tab 2: Change Password
                  _buildChangePasswordTab(),

                  // Tab 3: Delete Account
                  _buildDeleteAccountTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Thông tin cá nhân'),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _fullNameController,
            label: 'Họ tên',
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
          const SizedBox(height: 20),
          _buildSectionLabel('Thêm thông tin'),
          const SizedBox(height: 12),
          _buildGenderSelector(),
          const SizedBox(height: 12),
          _buildDateOfBirthSelector(),
          const SizedBox(height: 24),
          PrimaryButton(
            label: '💾 Lưu thay đổi',
            onTap: _saveProfile,
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
          _buildSectionLabel('Mật khẩu hiện tại'),
          const SizedBox(height: 12),
          _buildPasswordField(
            controller: _currentPasswordController,
            label: 'Mật khẩu hiện tại',
            showPassword: _showCurrentPassword,
            onToggle: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
          ),
          const SizedBox(height: 24),
          _buildSectionLabel('Mật khẩu mới'),
          const SizedBox(height: 12),
          _buildPasswordField(
            controller: _newPasswordController,
            label: 'Mật khẩu mới (Tối thiểu 6 ký tự)',
            showPassword: _showNewPassword,
            onToggle: () => setState(() => _showNewPassword = !_showNewPassword),
          ),
          const SizedBox(height: 12),
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Xác nhận mật khẩu',
            showPassword: _showConfirmPassword,
            onToggle: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: '🔐 Thay đổi mật khẩu',
            onTap: _changePassword,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.statusCancelled.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.statusCancelledText.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_rounded,
                      color: AppColors.statusCancelledText,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cảnh báo: Xóa tài khoản không thể hoàn tác',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.statusCancelledText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Khi bạn xóa tài khoản:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildWarningItem('Tất cả thông tin cá nhân sẽ bị xóa'),
                _buildWarningItem('Không thể truy cập các đơn hàng cũ'),
                _buildWarningItem('Điểm tích lũy sẽ mất'),
                _buildWarningItem('Không thể phục hồi dữ liệu'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Muốn giữ tài khoản?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nếu bạn có bất kỳ vấn đề nào, hãy liên hệ với đội hỗ trợ khách hàng của chúng tôi.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Liên hệ hỗ trợ →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusCancelledText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _deleteAccount,
              child: const Text(
                '🗑️ Xóa tài khoản vĩnh viễn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.close_rounded,
              size: 16, color: AppColors.statusCancelledText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
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
              showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButton<String>(
        value: _selectedGender,
        isExpanded: true,
        underline: const SizedBox(),
        items: ['Nam', 'Nữ', 'Khác'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedGender = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildDateOfBirthSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              'Ngày sinh: $_selectedDOB',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
