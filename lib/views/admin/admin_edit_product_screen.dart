// lib/views/admin/admin_edit_product_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/providers/admin_settings_provider.dart';
import '../../data/providers/category_provider.dart';
import '../../data/providers/food_provider.dart';
import '../../models/category_model.dart';
import '../../models/food_model.dart';

class AdminEditProductScreen extends StatefulWidget {
  const AdminEditProductScreen({super.key});

  @override
  State<AdminEditProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  CategoryModel? _selectedCategory;
  bool _isActive = true;
  bool _submitting = false;
  bool _loaded = false;
  FoodModel? _original;

  // File anh chon tu camera/gallery — neu khac null se upload multipart
  String? _localFilePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catProv = context.read<CategoryProvider>();
      if (catProv.categories.isEmpty) catProv.fetchCategories();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is FoodModel) {
      _hydrate(args);
    } else if (args is int) {
      Future.microtask(() async {
        try {
          await context.read<FoodProvider>().fetchFoodById(args);
          final f = context.read<FoodProvider>().selectedFood;
          if (f != null && mounted) _hydrate(f);
        } catch (e) {
          if (mounted) _toast('Lỗi tải món: $e', error: true);
        }
      });
    }
  }

  void _hydrate(FoodModel f) {
    _original = f;
    _nameCtrl.text = f.name;
    _priceCtrl.text = f.price.toStringAsFixed(0);
    _descCtrl.text = f.description ?? '';
    _stockCtrl.text = f.stockQuantity.toString();
    _imageUrlCtrl.text = f.imageUrl ?? '';
    _isActive = f.isActive;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cats = context.read<CategoryProvider>().categories;
      final match = cats.where((c) => c.categoryId == f.categoryId);
      if (match.isNotEmpty) {
        setState(() => _selectedCategory = match.first);
      }
    });
    setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _stockCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _toast('Vui lòng chọn danh mục', error: true);
      return;
    }
    if (_original?.foodId == null) {
      _toast('Không xác định được món', error: true);
      return;
    }

    setState(() => _submitting = true);

    final hasLocalFile = _localFilePath != null && _localFilePath!.isNotEmpty;
    final urlValue = _imageUrlCtrl.text.trim();

    final updated = FoodModel(
      foodId: _original!.foodId,
      categoryId: _selectedCategory!.categoryId,
      categoryName: _selectedCategory!.name,
      name: _nameCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
      description: _descCtrl.text.trim().isEmpty
          ? null
          : _descCtrl.text.trim(),
      stockQuantity: int.tryParse(_stockCtrl.text.trim()) ?? 0,
      // Co file upload moi -> bo qua URL, backend luu filename
      imageUrl: hasLocalFile
          ? null
          : (urlValue.isEmpty ? null : urlValue),
      isActive: _isActive,
      totalSold: _original!.totalSold,
      avgRating: _original!.avgRating,
    );

    try {
      await context.read<FoodProvider>().updateFood(
            _original!.foodId!,
            updated,
            localFilePath: hasLocalFile ? _localFilePath : null,
          );
      if (!mounted) return;
      _toast('Đã cập nhật "${updated.name}"');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) _toast('Lỗi: $e', error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // =========================================================
  // IMAGE PICKER — camera / gallery
  // =========================================================
  void _showImagePickerSheet() {
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
                'Đổi ảnh món ăn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _pickerTile(
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
              _pickerTile(
                icon: Icons.photo_library_outlined,
                iconBg: AppColors.pastel2,
                iconColor: AppColors.accent2,
                label: 'Chọn từ thư viện',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _pickFromGallery();
                },
              ),
              if (_localFilePath != null) ...[
                const SizedBox(height: 10),
                _pickerTile(
                  icon: Icons.delete_outline_rounded,
                  iconBg: const Color(0xFFFFE5E5),
                  iconColor: AppColors.statusCancelledText,
                  label: 'Bỏ ảnh đã chọn',
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    setState(() => _localFilePath = null);
                  },
                ),
              ],
              const SizedBox(height: 10),
              _pickerTile(
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

  Widget _pickerTile({
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
      final x = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1280,
      );
      if (x != null) {
        setState(() {
          _localFilePath = x.path;
          _imageUrlCtrl.clear();
        });
      }
    } catch (e) {
      _toast('Không mở được camera: $e', error: true);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1280,
      );
      if (x != null) {
        setState(() {
          _localFilePath = x.path;
          _imageUrlCtrl.clear();
        });
      }
    } catch (e) {
      _toast('Không mở được thư viện: $e', error: true);
    }
  }

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error
            ? AppColors.statusCancelledText
            : AppColors.accent3,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _firstLetter(String s) {
    final t = s.trim();
    if (t.isEmpty) return '?';
    return t.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (_original == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor:
          context.watch<AdminSettingsProvider>().backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagePreview(),
                      const SizedBox(height: 12),
                      _buildMetaStats(),
                      const SizedBox(height: 20),
                      _section('Thông tin cơ bản'),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _nameCtrl,
                        label: 'Tên món',
                        icon: Icons.restaurant_menu_rounded,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                      ),
                      const SizedBox(height: 14),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _priceCtrl,
                        label: 'Giá (VNĐ)',
                        icon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Bắt buộc';
                          final n = double.tryParse(v);
                          if (n == null || n < 0) return 'Không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _stockCtrl,
                        label: 'Số lượng tồn kho',
                        icon: Icons.inventory_2_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 20),
                      _section('Hình ảnh & mô tả'),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _imageUrlCtrl,
                        label: 'URL ảnh',
                        icon: Icons.image_outlined,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _descCtrl,
                        label: 'Mô tả',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),
                      _buildActiveToggle(),
                      const SizedBox(height: 28),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chỉnh sửa món',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Cập nhật thông tin món ăn',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    final url = _imageUrlCtrl.text.trim();
    final letter = _firstLetter(_nameCtrl.text);

    Widget child;
    if (_localFilePath != null && _localFilePath!.isNotEmpty) {
      child = Image.file(
        File(_localFilePath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initialBox(letter),
      );
    } else if (url.isEmpty) {
      child = _initialBox(letter);
    } else if (url.startsWith('http')) {
      child = Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initialBox(letter),
      );
    } else {
      child = Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initialBox(letter),
      );
    }

    return GestureDetector(
      onTap: _showImagePickerSheet,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: child,
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent1,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            if (_localFilePath != null)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent3,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Ảnh mới',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _initialBox(String letter) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.pastel1, AppColors.pastel5],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.w800,
          color: AppColors.accent1.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildMetaStats() {
    final f = _original!;
    return Row(
      children: [
        _metaChip(
          icon: Icons.tag_rounded,
          color: AppColors.accent5,
          label: 'ID #${f.foodId}',
        ),
        const SizedBox(width: 8),
        _metaChip(
          icon: Icons.local_fire_department_rounded,
          color: AppColors.accent1,
          label: 'Đã bán ${f.totalSold}',
        ),
        const SizedBox(width: 8),
        _metaChip(
          icon: Icons.star_rounded,
          color: AppColors.accent4,
          label: f.avgRating > 0 ? f.avgRating.toStringAsFixed(1) : 'Mới',
        ),
      ],
    );
  }

  Widget _metaChip({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.accent1,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(icon, color: AppColors.accent1, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer<CategoryProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading && prov.categories.isEmpty) {
          return Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CategoryModel>(
              isExpanded: true,
              value: _selectedCategory,
              hint: Row(
                children: const [
                  Icon(
                    Icons.category_outlined,
                    color: AppColors.accent1,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Chọn danh mục',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMuted,
              ),
              items: prov.categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.label_outline_rounded,
                            color: AppColors.accent1,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            c.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (c) => setState(() => _selectedCategory = c),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (_isActive ? AppColors.accent3 : AppColors.textMuted)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              _isActive
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: _isActive ? AppColors.accent3 : AppColors.textMuted,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hiển thị trên thực đơn',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Khách hàng có thể nhìn thấy món này',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            activeColor: AppColors.accent3,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _submitting ? null : _submit,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: _submitting
              ? null
              : const LinearGradient(
                  colors: [AppColors.accent1, Color(0xFFFFAB7E)],
                ),
          color: _submitting ? AppColors.divider : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _submitting
              ? null
              : [
                  BoxShadow(
                    color: AppColors.accent1.withOpacity(0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: _submitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.save_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Cập nhật món ăn',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
