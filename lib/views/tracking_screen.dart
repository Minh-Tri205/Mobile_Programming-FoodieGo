import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/back_button_widget.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

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
                  BackButtonWidget(
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/orders',
                      (r) => false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Theo dõi đơn hàng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '#DH240401 • Dự kiến 25 phút',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMapArea(),
                    const SizedBox(height: 36),
                    _buildStepList(),
                    const SizedBox(height: 16),
                    _buildOrderSummaryCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapArea() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Map placeholder
        Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.pastel3, AppColors.pastel2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.center,
          child: const Text('🗺️', style: TextStyle(fontSize: 52)),
        ),
        // Driver info card
        Positioned(
          bottom: -22,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.pastel2,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('🛵',
                        style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Nguyễn Văn Tài',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '⭐ 4.9 • Tài xế',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.pastel3,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '📞 Gọi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepList() {
    final steps = [
      {
        'icon': '✅',
        'title': 'Đơn hàng đã được xác nhận',
        'time': '09:41 - Nhà hàng đã nhận đơn',
        'done': true,
      },
      {
        'icon': '🍳',
        'title': 'Đang chuẩn bị món ăn',
        'time': '09:45 - Đầu bếp đang nấu',
        'done': true,
      },
      {
        'icon': '🛵',
        'title': 'Tài xế đang đến lấy hàng',
        'time': '09:52 - Đang trên đường',
        'done': false,
        'active': true,
      },
      {
        'icon': '📦',
        'title': 'Giao hàng thành công',
        'time': '~10:15 - Dự kiến',
        'done': false,
        'active': false,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          final bool done = step['done'] as bool? ?? false;
          final bool active = step['active'] as bool? ?? false;
          final bool isLast = i == steps.length - 1;
          final Color dotColor = done
              ? AppColors.accent3
              : (active ? AppColors.accent4 : const Color(0xFFE0D5CF));

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dot + line
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(top: 3),
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 44,
                      color: done
                          ? AppColors.accent3.withOpacity(0.3)
                          : const Color(0xFFE0D5CF),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${step['icon']}  ${step['title']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: done || active
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step['time'] as String,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pastel2,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '📋 Chi tiết đơn hàng',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.accent2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '2x Bún Bò Huế  •  1x Pizza Hải Sản',
            style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
          SizedBox(height: 6),
          Text(
            'Tổng: 174.000đ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.accent2,
            ),
          ),
        ],
      ),
    );
  }
}
