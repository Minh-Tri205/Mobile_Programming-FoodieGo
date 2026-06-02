// lib/views/user/address_screen.dart
// Man hinh "Dia chi cua toi" - CRUD dia chi nguoi dung qua API /api/Address
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/providers/address_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../models/address_model.dart';
import '../../widgets/notification/app_snackbar.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = context.read<UserProvider>().currentUserId;
      if (userId != null) {
        context.read<AddressProvider>().fetchByUser(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        title: const Text('Địa chỉ của tôi', style: AppTextStyles.heading2),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddressDialog(context),
            icon: const Icon(Icons.add_rounded, color: AppColors.accent1),
          ),
        ],
      ),
      body: Consumer<AddressProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.addresses.isEmpty) {
            return _buildEmpty();
          }

          // Sap xep: default len dau
          final list = [...provider.addresses]
            ..sort((a, b) {
              final ad = a.isDefault == true ? 0 : 1;
              final bd = b.isDefault == true ? 0 : 1;
              return ad.compareTo(bd);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return _buildAddressCard(list[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent1,
        onPressed: () => _showAddressDialog(context),
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text(
          'Thêm địa chỉ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // =========================================================
  // EMPTY
  // =========================================================
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
              decoration: BoxDecoration(
                color: AppColors.pastel2,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.location_off_rounded,
                size: 54,
                color: AppColors.accent2,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có địa chỉ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Thêm địa chỉ giao hàng đầu tiên để đặt món tiện hơn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ADDRESS CARD
  // =========================================================
  Widget _buildAddressCard(AddressModel a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: a.isDefault == true
            ? Border.all(color: AppColors.accent1, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.pastel2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.accent2,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          a.label ?? 'Địa chỉ',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (a.isDefault == true) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent1.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.accent1,
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Mặc định',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent1,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if ((a.recipientName ?? '').isNotEmpty ||
                        (a.recipientPhone ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${a.recipientName ?? ''}${(a.recipientName ?? '').isNotEmpty && (a.recipientPhone ?? '').isNotEmpty ? ' • ' : ''}${a.recipientPhone ?? ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showAddressActions(context, a),
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              a.fullAddress,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ACTIONS BOTTOM SHEET
  // =========================================================
  void _showAddressActions(BuildContext context, AddressModel a) {
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
              Text(a.label ?? 'Địa chỉ', style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              if (a.isDefault != true)
                _optionTile(
                  Icons.star_rounded,
                  'Đặt làm mặc định',
                  AppColors.accent4,
                  () async {
                    Navigator.pop(sheetCtx);
                    try {
                      final userId =
                          context.read<UserProvider>().currentUserId ?? 0;
                      await context
                          .read<AddressProvider>()
                          .setDefault(a.addressId!, userId);
                      if (mounted) {
                        AppSnackbar.showSuccess(
                          context,
                          'Đã đặt làm địa chỉ mặc định',
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
                  _showAddressDialog(context, address: a);
                },
              ),
              _optionTile(
                Icons.delete_outline_rounded,
                'Xóa',
                AppColors.statusCancelledText,
                () async {
                  Navigator.pop(sheetCtx);
                  final ok = await _confirmDelete(context);
                  if (ok == true && a.addressId != null) {
                    try {
                      await context
                          .read<AddressProvider>()
                          .delete(a.addressId!);
                      if (mounted) {
                        AppSnackbar.showSuccess(context, 'Đã xóa địa chỉ');
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

  // Hien dialog loi day du de user thay duoc message tu API
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.statusCancelledText,
            ),
            SizedBox(width: 8),
            Text('Có lỗi xảy ra', style: AppTextStyles.heading3),
          ],
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            message,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng',
                style: TextStyle(color: AppColors.accent1)),
          ),
        ],
      ),
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
        title: const Text('Xóa địa chỉ?'),
        content: const Text('Bạn có chắc muốn xóa địa chỉ này?'),
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
  void _showAddressDialog(BuildContext context, {AddressModel? address}) {
    final userId = context.read<UserProvider>().currentUserId;
    if (userId == null) {
      AppSnackbar.showError(context, 'Vui lòng đăng nhập lại');
      return;
    }
    final provider = context.read<AddressProvider>();

    final labelCtrl = TextEditingController(text: address?.label ?? '');
    final fullAddrCtrl =
        TextEditingController(text: address?.fullAddress ?? '');
    final nameCtrl =
        TextEditingController(text: address?.recipientName ?? '');
    final phoneCtrl =
        TextEditingController(text: address?.recipientPhone ?? '');
    bool isDefault = address?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setSt) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                address == null ? 'Thêm địa chỉ' : 'Cập nhật địa chỉ',
                style: AppTextStyles.heading3,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _input(labelCtrl, 'Nhãn (VD: Nhà, Cơ quan)'),
                    const SizedBox(height: 12),
                    _input(nameCtrl, 'Tên người nhận'),
                    const SizedBox(height: 12),
                    _input(phoneCtrl, 'Số điện thoại',
                        keyboard: TextInputType.phone),
                    const SizedBox(height: 12),
                    _input(fullAddrCtrl, 'Địa chỉ đầy đủ *', maxLines: 3),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isDefault,
                      title: const Text('Đặt làm địa chỉ mặc định'),
                      onChanged: (v) => setSt(() => isDefault = v),
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
                    if (fullAddrCtrl.text.trim().isEmpty) {
                      AppSnackbar.showError(
                          context, 'Vui lòng nhập địa chỉ đầy đủ');
                      return;
                    }
                    final model = AddressModel(
                      addressId: address?.addressId,
                      userId: userId,
                      label: labelCtrl.text.trim().isEmpty
                          ? null
                          : labelCtrl.text.trim(),
                      fullAddress: fullAddrCtrl.text.trim(),
                      recipientName: nameCtrl.text.trim().isEmpty
                          ? null
                          : nameCtrl.text.trim(),
                      recipientPhone: phoneCtrl.text.trim().isEmpty
                          ? null
                          : phoneCtrl.text.trim(),
                      isDefault: isDefault,
                    );
                    try {
                      if (address == null) {
                        await provider.create(model);
                      } else {
                        await provider.update(address.addressId!, model);
                      }
                      if (mounted) {
                        Navigator.pop(dialogCtx);
                        AppSnackbar.showSuccess(
                          context,
                          address == null
                              ? 'Đã thêm địa chỉ'
                              : 'Đã cập nhật địa chỉ',
                        );
                      }
                    } catch (e, st) {
                      // Log day du ra console de debug
                      debugPrint('[AddressDialog] Loi: $e');
                      debugPrint(st.toString());
                      // Dong dialog truoc roi moi show snackbar (de khong bi che)
                      if (Navigator.of(dialogCtx).canPop()) {
                        Navigator.pop(dialogCtx);
                      }
                      if (mounted) {
                        _showErrorDialog(context, e.toString());
                      }
                    }
                  },
                  child: Text(
                    address == null ? 'Thêm' : 'Lưu',
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
