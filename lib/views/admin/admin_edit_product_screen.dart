// lib/views/admin/admin_edit_product_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
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
      imageUrl: _imageUrlCtrl.text.trim().isEmpty
          ? null
          : _imageUrlCtrl.text.trim(),
      isActive: _isActive,
      totalSold: _original!.totalSold,
      avgRating: _original!.avgRating,
    );

    try {
      await context
          .read<FoodProvider>()
          .updateFood(_original!.foodId!, updated);
      if (!mounted) return;
      _toast('Đã cập nhật "${updated.name}"');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) _toast('Lỗi: $e', error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
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
      backgroundColor: AppColors.background,
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
    if (url.isEmpty) {
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

    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: child,
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
