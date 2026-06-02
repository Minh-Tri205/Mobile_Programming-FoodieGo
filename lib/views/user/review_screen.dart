// lib/views/review_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/providers/review_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../models/order_model.dart';
import '../../../models/review_model.dart';
import '../../../widgets/common/back_button_widget.dart';
import '../../../widgets/common/primary_button.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 5; // rating INT CHECK (rating BETWEEN 1 AND 5) trong SQL
  final TextEditingController _commentController = TextEditingController();
  bool _submitted = false;
  bool _submitting = false;
  int _selectedItemIndex = 0; // index trong _pendingItems
  bool _initialized = false;

  // Cac mon trong don ma user CHUA danh gia (loc trong didChangeDependencies)
  List<int> _pendingItems = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final order = ModalRoute.of(context)?.settings.arguments as OrderModel?;
    if (order == null) return;

    // Dam bao reviews da load de check da review chua
    final reviewProv = context.read<ReviewProvider>();
    if (reviewProv.reviews.isEmpty && !reviewProv.isLoading) {
      reviewProv.fetchAll().then((_) {
        if (mounted) _rebuildPendingItems(order);
      });
    } else {
      _rebuildPendingItems(order);
    }
  }

  void _rebuildPendingItems(OrderModel order) {
    final userId = context.read<UserProvider>().currentUserId ?? order.userId;
    final reviewed = context
        .read<ReviewProvider>()
        .reviews
        .where(
          (r) => r.orderId == order.orderId && r.userId == userId,
        )
        .map((r) => r.foodId)
        .where((id) => id != null)
        .cast<int>()
        .toSet();

    final pending = <int>[];
    for (var i = 0; i < order.items.length; i++) {
      final fid = order.items[i].foodId;
      if (!reviewed.contains(fid)) {
        pending.add(i);
      }
    }
    setState(() {
      _pendingItems = pending;
      _selectedItemIndex = 0;
    });
  }

  String _firstLetter(String s) {
    final t = s.trim();
    if (t.isEmpty) return '?';
    return t.characters.first.toUpperCase();
  }

  Widget _buildItemThumb(String? url, String letter) {
    if (url == null || url.isEmpty) return _thumbLetterBox(letter);
    final isNet = url.startsWith('http');
    return isNet
        ? Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _thumbLetterBox(letter),
          )
        : Image.asset(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _thumbLetterBox(letter),
          );
  }

  Widget _thumbLetterBox(String letter) {
    return Container(
      color: AppColors.pastel1,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.accent1,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview(OrderModel order) async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao đánh giá')),
      );
      return;
    }
    if (order.orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đơn hàng không hợp lệ')),
      );
      return;
    }
    if (_pendingItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không còn món nào để đánh giá')),
      );
      return;
    }

    final userId = context.read<UserProvider>().currentUserId ?? order.userId;
    // Review la danh gia mon (food) -> foodId bat buoc, lay tu mon dang chon
    final itemIdx = _pendingItems[_selectedItemIndex];
    final foodId = order.items[itemIdx].foodId;

    setState(() => _submitting = true);

    final created = await context.read<ReviewProvider>().submit(
      ReviewModel(
        orderId: order.orderId!,
        userId: userId,
        foodId: foodId,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      ),
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (created != null) {
      // Loc lai danh sach pending sau khi vua submit
      _rebuildPendingItems(order);

      if (_pendingItems.isEmpty) {
        // Het mon -> hien thanh cong va dieu huong ve danh sach don
        setState(() => _submitted = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.orders,
              (r) => false,
            );
          }
        });
      } else {
        // Con mon -> reset form de danh gia mon tiep theo
        _commentController.clear();
        setState(() {
          _rating = 5;
          _selectedItemIndex = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã gửi đánh giá. Còn ${_pendingItems.length} món chưa đánh giá.',
            ),
            backgroundColor: AppColors.accent3,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } else {
      final err = context.read<ReviewProvider>().error ?? 'Lỗi không xác định';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gửi đánh giá thất bại: $err'),
          backgroundColor: AppColors.statusCancelledText,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nhận OrderModel từ arguments; nếu không có thì dùng đơn mẫu cuối
    final order = ModalRoute.of(context)?.settings.arguments as OrderModel?
        ?? OrderModel.sampleOrders.last;

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
                    'Đánh giá món ăn',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _submitted
                  ? _buildSuccessView()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),

                          // Thông tin đơn hàng
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.pastel1,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Đơn ${order.orderCode}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order.itemsSummary,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ITEM PICKER — chỉ hiện món CHƯA đánh giá
                          if (_pendingItems.isNotEmpty) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Container(
                                    width: 3,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: AppColors.accent1,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Chọn món để đánh giá (${_pendingItems.length} còn lại)',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 90,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _pendingItems.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (_, i) {
                                  final itemIdx = _pendingItems[i];
                                  final item = order.items[itemIdx];
                                  final isPicked = _selectedItemIndex == i;
                                  return GestureDetector(
                                    onTap: () => setState(
                                      () => _selectedItemIndex = i,
                                    ),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 76,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: isPicked
                                            ? AppColors.pastel1
                                            : AppColors.card,
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isPicked
                                              ? AppColors.accent1
                                              : AppColors.divider,
                                          width: isPicked ? 2 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: _buildItemThumb(
                                                item.foodImageUrl,
                                                _firstLetter(item.foodName),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Expanded(
                                            child: Text(
                                              item.foodName,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: isPicked
                                                    ? FontWeight.w800
                                                    : FontWeight.w600,
                                                color: isPicked
                                                    ? AppColors.accent1
                                                    : AppColors.textMuted,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                          ] else if (order.items.isNotEmpty) ...[
                            // Tat ca mon da duoc danh gia
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.pastel3,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.accent3,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Bạn đã đánh giá tất cả món trong đơn này',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.accent3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          const Text(
                            'Bạn cảm thấy thế nào?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Đánh giá giúp chúng tôi cải thiện dịch vụ',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Chọn sao — khớp rating BETWEEN 1 AND 5 trong SQL
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) {
                              final star = i + 1;
                              return GestureDetector(
                                onTap: () => setState(() => _rating = star),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6),
                                  child: Icon(
                                    star <= _rating
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    size: 44,
                                    color: star <= _rating
                                        ? AppColors.accent4
                                        : AppColors.divider,
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 8),
                          Text(
                            _ratingLabel(_rating),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent4,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Nhập comment — khớp comment NVARCHAR(MAX) trong SQL
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: _commentController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText:
                                    'Chia sẻ cảm nhận của bạn về món ăn và dịch vụ...',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textMuted,
                                ),
                                border: InputBorder.none,
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          PrimaryButton(
                            label: _submitting
                                ? 'Đang gửi...'
                                : (_pendingItems.isEmpty
                                    ? 'Đã đánh giá hết'
                                    : 'Gửi đánh giá'),
                            onTap: (_submitting || _pendingItems.isEmpty)
                                ? () {}
                                : () => _submitReview(order),
                          ),

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

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1: return 'Rất tệ';
      case 2: return 'Tệ';
      case 3: return 'Bình thường';
      case 4: return 'Tốt';
      case 5: return 'Xuất sắc!';
      default: return '';
    }
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: AppColors.pastel3,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_rounded,
              size: 50,
              color: AppColors.accent3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Cảm ơn bạn đã đánh giá!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Phản hồi của bạn giúp chúng tôi\ncải thiện chất lượng dịch vụ.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}