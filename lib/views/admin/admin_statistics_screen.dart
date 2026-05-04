import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AdminStatisticsScreen extends StatefulWidget {
  const AdminStatisticsScreen({super.key});

  @override
  State<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {
  String selectedPeriod = 'Tuần này';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Doanh thu", style: AppTextStyles.heading2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Bộ lọc thời gian (Khác biệt so với Dashboard)
            _buildTimeFilter(),
            const SizedBox(height: 24),

            // 2. Các chỉ số phân tích sâu (Có kèm % tăng trưởng)
            _buildAnalyticalCards(),
            const SizedBox(height: 32),

            // 3. Biểu đồ hiệu suất (Chiếm diện tích lớn hơn, chi tiết hơn)
            _buildSectionTitle("Biểu đồ doanh thu"),
            const SizedBox(height: 16),
            _buildMainChart(),
            const SizedBox(height: 32),

            // 4. Phân tích sản phẩm bán chạy (Thay vì danh sách đơn hàng)
            _buildSectionTitle("Sản phẩm phổ biến nhất"),
            const SizedBox(height: 16),
            _buildTopProductsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilter() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: ['Hôm nay', 'Tuần này', 'Tháng này'].map((period) {
          bool isSelected = selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedPeriod = period),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  period,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected ? AppColors.accent1 : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnalyticalCards() {
    return Column(
      children: [
        _buildLongStatCard(
          "Lợi nhuận ròng",
          "₫8,240,000",
          "+12.5%",
          AppColors.pastel3,
          AppColors.accent3,
        ),
        const SizedBox(height: 12),
        _buildLongStatCard(
          "Giá trị đơn trung bình",
          "₫450,000",
          "-2.4%",
          AppColors.pastel2,
          AppColors.accent2,
        ),
      ],
    );
  }

  Widget _buildLongStatCard(
    String title,
    String value,
    String growth,
    Color color,
    Color accent,
  ) {
    bool isPositive = growth.contains('+');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMuted),
              const SizedBox(height: 4),
              Text(value, style: AppTextStyles.heading2),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              growth,
              style: AppTextStyles.label.copyWith(
                color: isPositive ? accent : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainChart() {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent1, // Đổi màu chủ đạo để khác Dashboard
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tổng doanh thu ($selectedPeriod)",
            style: AppTextStyles.heading3.copyWith(color: Colors.white),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) => _buildChartBar(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(int index) {
    double height = [60.0, 80.0, 40.0, 100.0, 70.0, 90.0, 110.0][index];
    return Column(
      children: [
        Container(
          height: height,
          width: 15,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(index == 6 ? 1 : 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "T${index + 2}",
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildTopProductsList() {
    return Column(
      children: List.generate(3, (index) {
        final products = ['Phở', 'Cơm sườn', 'Trà Đào Cam Sả'];
        final sales = [0.85, 0.65, 0.45];
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(products[index], style: AppTextStyles.body),
                  Text(
                    "${(sales[index] * 100).toInt()}%",
                    style: AppTextStyles.label,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: sales[index],
                backgroundColor: AppColors.surface,
                color: [
                  AppColors.accent1,
                  AppColors.accent2,
                  AppColors.accent5,
                ][index],
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.heading3);
  }
}
