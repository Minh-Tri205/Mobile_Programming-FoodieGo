import 'package:doancuoiki/core/constants/app_colors.dart';
import 'package:doancuoiki/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AdminUserHistoryScreen extends StatelessWidget {
  final int userId;
  const AdminUserHistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lịch sử đơn hàng', style: AppTextStyles.heading2),
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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 8, // Giả lập 8 đơn hàng
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.divider.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đơn hàng #FG-120${8 - index}',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusTag(index % 2 == 0),
                  ],
                ),
                const Divider(height: 24, thickness: 0.5),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.pastel3,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fastfood_rounded,
                        color: AppColors.accent3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Combo Gà Rán + Pepsi',
                            style: AppTextStyles.body,
                          ),
                          const SizedBox(height: 4),
                          Text('24/04/2026', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    Text(
                      '150.000đ',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.accent1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTag(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.statusConfirmed
            : AppColors.statusCancelled,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isCompleted ? 'Hoàn thành' : 'Đã hủy',
        style: TextStyle(
          color: isCompleted
              ? AppColors.statusConfirmedText
              : AppColors.statusCancelledText,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
