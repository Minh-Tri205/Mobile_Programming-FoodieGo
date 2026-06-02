// lib/views/admin/admin_vouchers_screen.dart
// Quan ly voucher - CRUD voucher cho admin qua API /api/Voucher
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/providers/voucher_provider.dart';
import '../../models/voucher_model.dart';
import '../../widgets/notification/app_snackbar.dart';

class AdminVouchersScreen extends StatefulWidget {
  const AdminVouchersScreen({super.key});

  @override
  State<AdminVouchersScreen> createState() => _AdminVouchersScreenState();
}

class _AdminVouchersScreenState extends State<AdminVouchersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<VoucherProvider>().fetchAll();
    });
  }

  String _money(double a) {
    final s = a.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()}đ';
  }

  String _date(DateTime? d) {
    if (d == null) return '—';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  bool _isExpired(VoucherModel v) {
    if (v.endDate == null) return false;
    return v.endDate!.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        title: const Text('Quản lý mã giảm giá', style: AppTextStyles.heading2),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showVoucherDialog(context),
            icon: const Icon(Icons.add_rounded, color: AppColors.accent1),
          ),
        ],
      ),
      body: Consumer<VoucherProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.vouchers.isEmpty) {
            return _buildEmpty();
          }

          return RefreshIndicator(
            color: AppColors.accent1,
            onRefresh: () => provider.fetchAll(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.vouchers.length,
              itemBuilder: (context, index) {
                return _buildVoucherCard(provider.vouchers[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent1,
        onPressed: () => _showVoucherDialog(context),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Thêm voucher',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: AppColors.pastel4,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_offer_outlined,
                size: 54,
                color: AppColors.accent4,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có voucher',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tạo mã giảm giá đầu tiên cho khách hàng',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherCard(VoucherModel v) {
    final expired = _isExpired(v);
    final isActive = v.isActive ?? false;
    final disabled = expired || !isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: code + status + actions
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: disabled
                    ? [AppColors.surface, AppColors.surface]
                    : const [AppColors.accent1, Color(0xFFFFAB7E)],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.local_offer_rounded,
                    color: disabled ? AppColors.textMuted : Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.code,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: disabled
                              ? AppColors.textMuted
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '-${_money(v.discountAmount)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: disabled
                              ? AppColors.textMuted
                              : Colors.white.withOpacity(0.95),
                        ),
                      ),
                    ],
                  ),
                ),
                if (expired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.statusCancelled,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Hết hạn',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.statusCancelledText,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withOpacity(0.25)
                          : AppColors.statusCancelled,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isActive ? 'Đang dùng' : 'Tắt',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isActive
                            ? Colors.white
                            : AppColors.statusCancelledText,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: () => _showVoucherActions(context, v),
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: disabled ? AppColors.textMuted : Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((v.description ?? '').isNotEmpty) ...[
                  Text(
                    v.description!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _infoChip(
                      Icons.shopping_basket_rounded,
                      'Đơn từ ${_money(v.minOrderValue ?? 0)}',
                      AppColors.accent2,
                      AppColors.pastel2,
                    ),
                    if (v.usageLimit != null)
                      _infoChip(
                        Icons.confirmation_number_rounded,
                        '${v.usageLimit} lượt',
                        AppColors.accent3,
                        AppColors.pastel3,
                      ),
                    _infoChip(
                      Icons.event_rounded,
                      '${_date(v.startDate)} → ${_date(v.endDate)}',
                      AppColors.accent5,
                      AppColors.pastel5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ACTIONS
  // =========================================================
  void _showVoucherActions(BuildContext context, VoucherModel v) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(v.code, style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              _optionTile(
                (v.isActive ?? false)
                    ? Icons.toggle_off_outlined
                    : Icons.toggle_on_outlined,
                (v.isActive ?? false)
                    ? 'Tắt voucher'
                    : 'Bật voucher',
                AppColors.accent4,
                () async {
                  Navigator.pop(sheetCtx);
                  try {
                    await context.read<VoucherProvider>().toggleActive(v);
                    if (mounted) {
                      AppSnackbar.showSuccess(
                        context,
                        (v.isActive ?? false)
                            ? 'Đã tắt voucher'
                            : 'Đã bật voucher',
                      );
                    }
                  } catch (e) {
                    if (mounted) AppSnackbar.showError(context, 'Lỗi: $e');
                  }
                },
              ),
              _optionTile(
                Icons.edit_outlined,
                'Chỉnh sửa',
                AppColors.accent2,
                () {
                  Navigator.pop(sheetCtx);
                  _showVoucherDialog(context, voucher: v);
                },
              ),
              _optionTile(
                Icons.delete_outline_rounded,
                'Xóa voucher',
                AppColors.statusCancelledText,
                () async {
                  Navigator.pop(sheetCtx);
                  final ok = await _confirmDelete(context);
                  if (ok == true && v.voucherId != null) {
                    try {
                      await context
                          .read<VoucherProvider>()
                          .delete(v.voucherId!);
                      if (mounted) {
                        AppSnackbar.showSuccess(context, 'Đã xóa voucher');
                      }
                    } catch (e) {
                      if (mounted) AppSnackbar.showError(context, 'Lỗi: $e');
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _optionTile(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title, style: AppTextStyles.body),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xóa voucher?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCancelledText,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CREATE + UPDATE DIALOG
  // =========================================================
  void _showVoucherDialog(BuildContext context, {VoucherModel? voucher}) {
    final provider = context.read<VoucherProvider>();

    final codeCtrl = TextEditingController(text: voucher?.code ?? '');
    final descCtrl = TextEditingController(text: voucher?.description ?? '');
    final discountCtrl = TextEditingController(
      text: voucher == null ? '' : voucher.discountAmount.toStringAsFixed(0),
    );
    final minOrderCtrl = TextEditingController(
      text: voucher?.minOrderValue == null
          ? ''
          : voucher!.minOrderValue!.toStringAsFixed(0),
    );
    final limitCtrl = TextEditingController(
      text: voucher?.usageLimit == null ? '' : voucher!.usageLimit.toString(),
    );
    DateTime? start = voucher?.startDate;
    DateTime? end = voucher?.endDate;
    bool isActive = voucher?.isActive ?? true;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setSt) {
            String _btnDate(DateTime? d, String hint) {
              if (d == null) return hint;
              String two(int n) => n.toString().padLeft(2, '0');
              return '${two(d.day)}/${two(d.month)}/${d.year}';
            }

            Future<void> pickStart() async {
              final picked = await showDatePicker(
                context: ctx,
                initialDate: start ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) setSt(() => start = picked);
            }

            Future<void> pickEnd() async {
              final picked = await showDatePicker(
                context: ctx,
                initialDate: end ?? DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) setSt(() => end = picked);
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                voucher == null ? 'Thêm voucher' : 'Cập nhật voucher',
                style: AppTextStyles.heading3,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _input(codeCtrl, 'Mã code (VD: SALE50K) *'),
                    const SizedBox(height: 12),
                    _input(descCtrl, 'Mô tả', maxLines: 2),
                    const SizedBox(height: 12),
                    _input(
                      discountCtrl,
                      'Giá trị giảm (VNĐ) *',
                      keyboard: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _input(
                      minOrderCtrl,
                      'Đơn tối thiểu (VNĐ)',
                      keyboard: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _input(
                      limitCtrl,
                      'Số lượt sử dụng tối đa',
                      keyboard: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: pickStart,
                            icon: const Icon(
                              Icons.event_rounded,
                              size: 16,
                              color: AppColors.accent2,
                            ),
                            label: Text(
                              _btnDate(start, 'Bắt đầu'),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: pickEnd,
                            icon: const Icon(
                              Icons.event_busy_rounded,
                              size: 16,
                              color: AppColors.accent5,
                            ),
                            label: Text(
                              _btnDate(end, 'Kết thúc'),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isActive,
                      title: const Text('Kích hoạt'),
                      onChanged: (v) => setSt(() => isActive = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Hủy',
                      style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final code = codeCtrl.text.trim();
                    final discount =
                        double.tryParse(discountCtrl.text.trim()) ?? 0;
                    if (code.isEmpty) {
                      AppSnackbar.showError(context, 'Vui lòng nhập mã code');
                      return;
                    }
                    if (discount <= 0) {
                      AppSnackbar.showError(
                          context, 'Giá trị giảm phải lớn hơn 0');
                      return;
                    }

                    final model = VoucherModel(
                      voucherId: voucher?.voucherId,
                      code: code,
                      description: descCtrl.text.trim().isEmpty
                          ? null
                          : descCtrl.text.trim(),
                      discountAmount: discount,
                      minOrderValue: minOrderCtrl.text.trim().isEmpty
                          ? null
                          : double.tryParse(minOrderCtrl.text.trim()),
                      startDate: start,
                      endDate: end,
                      usageLimit: limitCtrl.text.trim().isEmpty
                          ? null
                          : int.tryParse(limitCtrl.text.trim()),
                      isActive: isActive,
                    );

                    try {
                      if (voucher == null) {
                        await provider.create(model);
                      } else {
                        await provider.update(voucher.voucherId!, model);
                      }
                      if (mounted) {
                        Navigator.pop(dialogCtx);
                        AppSnackbar.showSuccess(
                          context,
                          voucher == null
                              ? 'Đã thêm voucher'
                              : 'Đã cập nhật voucher',
                        );
                      }
                    } catch (e) {
                      if (mounted) AppSnackbar.showError(context, 'Lỗi: $e');
                    }
                  },
                  child: Text(
                    voucher == null ? 'Thêm' : 'Lưu',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _input(
    TextEditingController c,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboard,
  }) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
