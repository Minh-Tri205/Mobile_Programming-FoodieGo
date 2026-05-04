import 'package:doancuoiki/core/constants/app_colors.dart';
import 'package:doancuoiki/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AdminEditProductScreen extends StatefulWidget {
  final Map<String, dynamic>?
  product; // Nhận dữ liệu món ăn từ màn hình danh sách

  const AdminEditProductScreen({super.key, this.product});

  @override
  State<AdminEditProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  // Controllers cho các ô nhập liệu
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  late TextEditingController stockController;

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

    // Đổ dữ liệu từ 'product' vào controllers nếu có
    // Xử lý giá: xóa chữ 'đ' và dấu '.' để chỉ lấy số
    String rawPrice =
        widget.product?['price']?.toString().replaceAll(
          RegExp(r'[^0-9]'),
          '',
        ) ??
        '';

    nameController = TextEditingController(text: widget.product?['name'] ?? '');
    priceController = TextEditingController(text: rawPrice);
    descriptionController = TextEditingController(
      text: widget.product?['description'] ?? 'Mô tả mặc định của sản phẩm...',
    );
    stockController = TextEditingController(
      text: widget.product?['stock']?.toString() ?? '0',
    );

    // Đồng bộ category nếu type truyền vào khớp với list categories
    if (widget.product != null &&
        categories.contains(widget.product!['type'])) {
      selectedCategory = widget.product!['type'];
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chỉnh sửa sản phẩm', style: AppTextStyles.heading2),
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
              label: 'Tên sản phẩm cũ',
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
              hint: 'Nhập chi tiết thành phần...',
              icon: Icons.description_outlined,
              maxLines: 4,
            ),

            const SizedBox(height: 40),

            // 4. Nút bấm Cập nhật
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Logic Update dữ liệu
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
                  'Lưu thay đổi',
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
        onTap: () {},
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
          contentPadding: const EdgeInsets.all(16),
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
