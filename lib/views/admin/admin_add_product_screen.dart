import 'package:doancuoiki/core/constants/app_colors.dart';
import 'package:doancuoiki/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AdminAddProductScreen extends StatefulWidget {
  final int? productId; // null nếu là thêm mới, có giá trị nếu là chỉnh sửa

  const AdminAddProductScreen({super.key, this.productId});

  @override
  State<AdminAddProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminAddProductScreen> {
  // Controllers cho các ô nhập liệu
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final stockController = TextEditingController();

  String selectedCategory = 'Món chính';
  final List<String> categories = [
    'Món chính',
    'Đồ uống',
    'Tráng miệng',
    'Ăn vặt',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      // Giả lập load dữ liệu sản phẩm cũ để sửa
      nameController.text = "Combo Gà Rán $widget.productId";
      priceController.text = "150000";
      descriptionController.text =
          "Gà rán giòn rụm kèm khoai tây và nước ngọt...";
      stockController.text = "50";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.productId == null ? 'Thêm sản phẩm mới' : 'Chỉnh sửa sản phẩm',
          style: AppTextStyles.heading2,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hình ảnh sản phẩm
            _buildImagePicker(),
            const SizedBox(height: 32),

            // 2. Tên sản phẩm
            _buildSectionTitle('Thông tin cơ bản'),
            _buildTextField(
              controller: nameController,
              label: 'Tên sản phẩm',
              hint: 'Ví dụ: Pizza Hải Sản Size L',
              icon: Icons.fastfood_outlined,
            ),

            // 3. Danh mục (Dropdown)
            _buildCategoryDropdown(),

            const SizedBox(height: 24),
            _buildSectionTitle('Giá và Kho hàng'),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: priceController,
                    label: 'Giá bán',
                    hint: '0',
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: stockController,
                    label: 'Số lượng',
                    hint: '0',
                    icon: Icons.inventory_2_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Mô tả chi tiết'),
            _buildTextField(
              controller: descriptionController,
              label: 'Mô tả',
              hint: 'Nhập chi tiết thành phần, hương vị...',
              icon: Icons.description_outlined,
              maxLines: 4,
            ),

            const SizedBox(height: 40),

            // 4. Nút bấm Lưu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Xử lý logic lưu ở đây
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Cập nhật sản phẩm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: AppTextStyles.heading3),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: () {}, // Logic chọn ảnh từ gallery
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.divider.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_rounded,
                size: 40,
                color: AppColors.accent1.withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              Text('Thay đổi ảnh', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.accent1, size: 22),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.accent1,
          ),
          items: categories.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: AppTextStyles.body),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedCategory = newValue!;
            });
          },
        ),
      ),
    );
  }
}
