// lib/views/user/checkout_screen.dart
// - Lay du lieu cart tu CartProvider (khong dung sample nua)
// - Dia chi & SDT load tu UserProvider / AddressProvider (defaultAddress)
// - Bo phan ma giam gia (da chon o CartScreen)
// - Khi dat hang: neu co voucher dang ap dung -> tao VoucherUsage
// - Giu nguyen UI: COD / Chuyen khoan
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/providers/address_provider.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/providers/voucher_usage_provider.dart';
import '../../../data/services/payment_service.dart';
import '../../../models/cart_model.dart';
import '../../../models/notification_model.dart';
import '../../../models/order_item_model.dart';
import '../../../models/order_model.dart';
import '../../../models/voucher_usage_model.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/notification/app_snackbar.dart';

// Enum phương thức thanh toán
enum PaymentMethod { cod, transfer, vnpay }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _phoneController   = TextEditingController();
  final _noteController    = TextEditingController();

  PaymentMethod _paymentMethod = PaymentMethod.cod;
  bool _prefilledOnce = false;

  // ── QR state ──────────────────────────────────────────────
  final _paymentService = PaymentService();
  PaymentQrInfo? _qrInfo;      // null = chưa load / chưa tạo đơn
  bool _qrLoading = false;
  String? _qrError;
  // ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = context.read<UserProvider>().currentUserId;
      if (userId != null) {
        final addrProv = context.read<AddressProvider>();
        if (addrProv.addresses.isEmpty) {
          addrProv.fetchByUser(userId).then((_) => _prefill());
        } else {
          _prefill();
        }
      }
    });
  }

  void _prefill() {
    if (_prefilledOnce) return;
    final user = context.read<UserProvider>().currentUser;
    final addr = context.read<AddressProvider>().defaultAddress;

    final autoAddress = addr?.fullAddress ?? '';
    final autoPhone   = addr?.recipientPhone ?? user?.phone ?? '';

    if (_addressController.text.isEmpty && autoAddress.isNotEmpty) {
      _addressController.text = autoAddress;
    }
    if (_phoneController.text.isEmpty && autoPhone.isNotEmpty) {
      _phoneController.text = autoPhone;
    }
    _prefilledOnce = true;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════
  // VALIDATE → PHÂN NHÁNH COD / TRANSFER
  // ══════════════════════════════════════════════════════════
  void _placeOrder() {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ giao hàng')),
      );
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số điện thoại')),
      );
      return;
    }

    if (_paymentMethod == PaymentMethod.transfer) {
      // Tạo đơn trước → lấy QR → hiện dialog xác nhận
      _createOrderThenShowQr();
    } else if (_paymentMethod == PaymentMethod.vnpay) {
      // Tạo đơn → gọi backend xin paymentUrl → mở trình duyệt/cong VNPay sandbox
      _createOrderThenOpenVnpay();
    } else {
      _finishOrder();
    }
  }

  // ══════════════════════════════════════════════════════════
  // [VNPAY] Tao don (pending) -> mo browser VNPay -> hien BottomSheet
  // "Cho xac nhan thanh toan".
  //
  // Co 2 nguon de biet payment thanh cong:
  //  1) SignalR push (notificationType=payment, relatedId=orderId,
  //     title chua "thanh cong") -> auto chuyen tracking
  //  2) User bam nut "Toi da thanh toan" -> goi API check status, neu
  //     status >= confirmed -> chuyen tracking
  //
  // Chi navigate tracking khi status da chuyen khoi pending.
  // ══════════════════════════════════════════════════════════
  Future<void> _createOrderThenOpenVnpay() async {
    final OrderModel? created = await _buildAndCreateOrder();
    if (created == null) return;

    final orderId = created.orderId ?? 0;
    if (orderId == 0) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'Đơn hàng không hợp lệ');
      return;
    }

    // 1) Lay URL thanh toan
    String url;
    try {
      url = await _paymentService.createVnpayUrl(orderId);
      debugPrint('[VNPay] paymentUrl=$url');
    } catch (e) {
      debugPrint('[VNPay] error: $e');
      if (!mounted) return;
      _showErrorDialog(context, e.toString());
      return;
    }

    // 2) Mo browser VNPay (external)
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'Không mở được trang thanh toán VNPay');
      return;
    }

    if (!mounted) return;
    // 3) Hien sheet cho + listener
    _showVnpayWaitingSheet(created);
  }

  // ──────────────────────────────────────────────────────────
  // SHEET "DANG CHO THANH TOAN VNPAY"
  // ──────────────────────────────────────────────────────────
  void _showVnpayWaitingSheet(OrderModel order) {
    final notifProv = context.read<NotificationProvider>();
    final orderProv = context.read<OrderProvider>();
    final cartProv = context.read<CartProvider>();
    final prevOnPushed = notifProv.onPushed;

    // Khi SignalR push thong bao payment cua don nay -> auto check
    notifProv.onPushed = (NotificationModel n) {
      prevOnPushed?.call(n);
      if (n.relatedId != order.orderId) return;
      if (n.notificationType.toLowerCase() != 'payment') return;
      final ok = n.title.toLowerCase().contains('thành công') ||
          n.title.toLowerCase().contains('thanh cong');
      if (!ok) return;
      // Auto close sheet + navigate
      Navigator.of(context, rootNavigator: true).pop('paid');
    };

    showModalBottomSheet<String>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        bool checking = false;
        return StatefulBuilder(
          builder: (ctx, setSt) {
            Future<void> check() async {
              if (checking) return;
              setSt(() => checking = true);
              try {
                // Timeout 8s — neu backend cham hoac mat ket noi
                // se khong treo UI vinh vien.
                await orderProv
                    .refreshOrderById(order.orderId!)
                    .timeout(const Duration(seconds: 8));

                final latest = orderProv.selectedOrder;
                // BAT BUOC: latest phai dung don nay (so sanh orderId)
                // de tranh nham order cu trong selectedOrder.
                final isThisOrder =
                    latest != null && latest.orderId == order.orderId;
                final notPending = isThisOrder &&
                    latest.status != OrderStatus.pending &&
                    latest.status != OrderStatus.cancelled;

                if (notPending) {
                  if (sheetCtx.mounted) Navigator.pop(sheetCtx, 'paid');
                  return;
                }
                if (sheetCtx.mounted) {
                  AppSnackbar.showInfo(
                    ctx,
                    'Chưa nhận được xác nhận thanh toán. Vui lòng thử lại sau.',
                  );
                }
              } on Object catch (e) {
                if (sheetCtx.mounted) {
                  AppSnackbar.showError(ctx, 'Không kết nối được: $e');
                }
              } finally {
                if (sheetCtx.mounted) setSt(() => checking = false);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
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
                  const SizedBox(height: 18),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.pastel2,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '💳',
                      style: TextStyle(fontSize: 36),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Đang chờ xác nhận thanh toán',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hoàn tất giao dịch VNPay trong trình duyệt cho đơn '
                    '${order.orderCode}.\n'
                    'Sau khi thanh toán xong, hệ thống sẽ tự xác nhận.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.pop(sheetCtx, 'cancel'),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                              color: AppColors.divider,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Để sau',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: checking ? null : check,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent3,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: checking
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Tôi đã thanh toán ✓',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((result) async {
      // Restore SignalR callback cu
      notifProv.onPushed = prevOnPushed;
      if (!mounted) return;
      if (result == 'paid') {
        // Fetch lai don MOI nhat (status confirmed/preparing/...)
        try {
          await orderProv.refreshOrderById(order.orderId!);
        } catch (_) {}
        final confirmed = orderProv.selectedOrder ?? order;
        _recordVoucherUsage(confirmed);
        cartProv.clear();
        if (!mounted) return;
        AppSnackbar.showSuccess(
          context,
          'Thanh toán thành công ${confirmed.orderCode}',
        );
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.tracking,
          arguments: confirmed,
        );
      } else {
        // User huy -> giu nguyen don status pending, chi quay ve checkout
        // (user co the vao Lich su don hang de thanh toan lai sau)
        AppSnackbar.showInfo(
          context,
          'Đơn ${order.orderCode} đang chờ thanh toán. '
          'Bạn có thể hoàn tất sau ở Lịch sử đơn hàng.',
        );
      }
    });
  }

  // ══════════════════════════════════════════════════════════
  // [CHUYỂN KHOẢN] Tạo đơn → gọi API QR → hiện dialog
  // ══════════════════════════════════════════════════════════
  Future<void> _createOrderThenShowQr() async {
    // 1. Tạo đơn hàng
    final OrderModel? created = await _buildAndCreateOrder();
    if (created == null) return; // lỗi đã xử lý bên trong

    // 2. Gọi API lấy QR
    setState(() {
      _qrLoading = true;
      _qrError   = null;
      _qrInfo    = null;
    });

    try {
      final qr = await _paymentService.getQrInfo(
  created.orderId ?? 0,
);

debugPrint('========== QR INFO ==========');
debugPrint('OrderId: ${qr.orderId}');
debugPrint('OrderCode: ${qr.orderCode}');
debugPrint('Bank: ${qr.bankName}');
debugPrint('Account: ${qr.accountNo}');
debugPrint('Amount: ${qr.amount}');
debugPrint('Content: ${qr.transferContent}');
debugPrint('QR URL: ${qr.qrImageUrl}');
debugPrint('============================');
      setState(() {
        _qrInfo    = qr;
        _qrLoading = false;
      });
    } catch (e) {
      setState(() {
        _qrError   = e.toString();
        _qrLoading = false;
      });
    }

    // 3. Hiện dialog QR (dù load lỗi vẫn hiện dialog, chỉ thay bằng thông báo lỗi)
    if (!mounted) return;
    _showQrDialog(created);
  }

  // ══════════════════════════════════════════════════════════
  // DIALOG QR THANH TOÁN
  // ══════════════════════════════════════════════════════════
  void _showQrDialog(OrderModel created) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.pastel2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: AppColors.accent2,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Quét QR thanh toán',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),

                // ── ẢNH QR ─────────────────────────────────
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.divider, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _buildQrImage(),
                ),

                const SizedBox(height: 16),

                // ── THÔNG TIN CHUYỂN KHOẢN ──────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _qrInfo != null
                      ? Column(
                          children: [
                            _infoRow('Ngân hàng',    _qrInfo!.bankName),
                            const SizedBox(height: 8),
                            _infoRowCopy('Số TK',    _qrInfo!.accountNo),
                            const SizedBox(height: 8),
                            _infoRow('Chủ TK',       _qrInfo!.accountName),
                            const SizedBox(height: 8),
                            _infoRow(
                              'Số tiền',
                              _formatAmount(_qrInfo!.amount),
                              valueColor: AppColors.accent1,
                              valueBold:  true,
                            ),
                            const SizedBox(height: 8),
                            _infoRowCopy(
                              'Nội dung CK',
                              _qrInfo!.transferContent,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 12),

                // ── CHÚ Ý ───────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pastel4,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: AppColors.accent4,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Nhập đúng nội dung chuyển khoản để đơn hàng được xác nhận tự động.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accent4,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
          actions: [
            // Huỷ — xoá đơn vừa tạo (nếu cần) hoặc chỉ đóng
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Quay lại',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _afterTransferCreated(created);
              },
              child: const Text(
                'Đã chuyển khoản ✓',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị ảnh QR (loading / error / thật)
Widget _buildQrImage() {
  if (_qrLoading) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  if (_qrError != null) {
    return Center(
      child: Text(
        _qrError!,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  if (_qrInfo == null) {
    return const Center(
      child: Text(
        'Không có dữ liệu QR',
      ),
    );
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: Image.network(
      _qrInfo!.qrImageUrl,
      fit: BoxFit.contain,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      errorBuilder: (_, __, ___) {
        return const Center(
          child: Text(
            'Không tải được ảnh QR',
            textAlign: TextAlign.center,
          ),
        );
      },
    ),
  );
}

  // ══════════════════════════════════════════════════════════
  // SAU KHI USER NHẤN "ĐÃ CHUYỂN KHOẢN" — gia lap thanh toan thanh cong
  // -> confirm don (pending -> confirmed) -> moi chuyen tracking.
  // ══════════════════════════════════════════════════════════
  Future<void> _afterTransferCreated(OrderModel created) async {
    final orderProv = context.read<OrderProvider>();
    final cartProv = context.read<CartProvider>();

    try {
      await orderProv.confirmOrder(created.orderId!);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'Không xác nhận được đơn: $e');
      return;
    }

    try {
      await orderProv.refreshOrderById(created.orderId!);
    } catch (_) {}
    final confirmed = orderProv.selectedOrder ?? created;

    _recordVoucherUsage(confirmed);
    cartProv.clear();
    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      'Đặt hàng thành công ${confirmed.orderCode}',
    );
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.tracking,
      arguments: confirmed,
    );
  }

  // ══════════════════════════════════════════════════════════
  // [COD] Tao don (status=pending) -> CONFIRM (gia lap thanh toan
  // thanh cong) -> chuyen sang trang theo doi don hang voi don MOI da
  // duoc confirm (status=confirmed).
  // ══════════════════════════════════════════════════════════
  Future<void> _finishOrder() async {
    final created = await _buildAndCreateOrder();
    if (created == null) return;

    final orderProv = context.read<OrderProvider>();
    final cartProv = context.read<CartProvider>();

    // Gia lap thanh toan thanh cong: confirm don tu pending -> confirmed
    try {
      await orderProv.confirmOrder(created.orderId!);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'Không xác nhận được đơn: $e');
      return;
    }

    // Lay lai don MOI (da co status=confirmed) tu API
    try {
      await orderProv.refreshOrderById(created.orderId!);
    } catch (_) {}
    final confirmed = orderProv.selectedOrder ?? created;

    _recordVoucherUsage(confirmed);
    cartProv.clear();

    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      'Đặt hàng thành công ${confirmed.orderCode}',
    );
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.tracking,
      arguments: confirmed,
    );
  }

  // ══════════════════════════════════════════════════════════
  // BUILD ORDER MODEL + GỌI API TẠO ĐƠN
  // Trả về OrderModel nếu thành công, null nếu lỗi
  // ══════════════════════════════════════════════════════════
  Future<OrderModel?> _buildAndCreateOrder() async {
    final cart     = context.read<CartProvider>();
    final userProv = context.read<UserProvider>();
    final userId   = userProv.currentUserId;
    final addrProv = context.read<AddressProvider>();

    if (userId == null) {
      AppSnackbar.showError(context, 'Vui lòng đăng nhập lại');
      return null;
    }

    // Đảm bảo có user object
    var user = userProv.currentUser;
    if (user == null) {
      try {
        await userProv.fetchUserById(userId);
        user = userProv.currentUser;
      } catch (e) {
        debugPrint('[Checkout] fetchUser lỗi: $e');
      }
    }

    final defaultAddr   = addrProv.defaultAddress;
    final addrName      = defaultAddr?.recipientName?.trim() ?? '';
    final userName      = user?.fullName.trim() ?? '';
    final recipientName = addrName.isNotEmpty
        ? addrName
        : (userName.isNotEmpty ? userName : 'Khách hàng');

    final items = cart.selectedItems.isNotEmpty ? cart.selectedItems : cart.items;
    if (items.isEmpty) {
      AppSnackbar.showError(context, 'Giỏ hàng trống');
      return null;
    }

    final orderItems = items
        .map((it) => OrderItemModel(
              foodId:       it.food.foodId ?? 0,
              quantity:     it.quantity,
              unitPrice:    it.food.price,
              foodName:     it.food.name,
              foodImageUrl: it.food.imageUrl,
            ))
        .toList();

    final code   = 'DH-${DateTime.now().millisecondsSinceEpoch}';
    final addrId = (defaultAddr != null &&
            defaultAddr.fullAddress == _addressController.text.trim())
        ? defaultAddr.addressId
        : null;

    final String paymentStr;
    switch (_paymentMethod) {
      case PaymentMethod.cod:
        paymentStr = 'cash';
        break;
      case PaymentMethod.transfer:
        paymentStr = 'bank_transfer';
        break;
      case PaymentMethod.vnpay:
        paymentStr = 'vnpay';
        break;
    }

    final order = OrderModel(
      userId:          userId,
      orderCode:       code,
      recipientName:   recipientName,
      deliveryAddress: _addressController.text.trim(),
      deliveryPhone:   _phoneController.text.trim(),
      deliveryFee:     cart.deliveryFee,
      note:            _noteController.text.trim().isEmpty
                           ? null
                           : _noteController.text.trim(),
      addressId:       addrId,
      paymentMethod:   paymentStr,
      voucherId:       cart.appliedVoucherId,
      voucherCode:     cart.appliedVoucherCode,
      discountAmount:  cart.discountAmount,
      status:          OrderStatus.pending,
      totalAmount:     cart.total,
      items:           orderItems,
    );

    try {
      final created = await context.read<OrderProvider>().createOrder(order);
      return created;
    } catch (e, st) {
      debugPrint('[Checkout] Tạo đơn lỗi: $e');
      debugPrint(st.toString());
      if (mounted) _showErrorDialog(context, e.toString());
      return null;
    }
  }

  // Ghi nhận voucher usage sau khi có orderId
  Future<void> _recordVoucherUsage(OrderModel created) async {
    final cart   = context.read<CartProvider>();
    final userId = context.read<UserProvider>().currentUserId;

    if (cart.appliedVoucherId != null && userId != null) {
      try {
        await context.read<VoucherUsageProvider>().create(
              VoucherUsageModel(
                voucherId: cart.appliedVoucherId!,
                userId:    userId,
                orderId:   created.orderId,
                usedAt:    DateTime.now(),
              ),
            );
      } catch (e) {
        debugPrint('[Checkout] VoucherUsage lỗi (bỏ qua): $e');
      }
    }
  }

  // ══════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ══════════════════════════════════════════════════════════

  Widget _infoRow(
    String label,
    String value, {
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: valueBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // Row có nút copy
  Widget _infoRowCopy(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã copy: $value'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.copy_rounded,
                size: 14,
                color: AppColors.accent2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}.000đ';
    }
    return '${amount}đ';
  }

  // Label nut dat hang theo phuong thuc dang chon
  String _buttonLabel(CartProvider cart) {
    final money = '${(cart.total / 1000).toStringAsFixed(0)}.000đ';
    switch (_paymentMethod) {
      case PaymentMethod.cod:
        return 'Đặt hàng (COD)  •  $money';
      case PaymentMethod.transfer:
        return 'Xem QR & Đặt hàng  •  $money';
      case PaymentMethod.vnpay:
        return 'Thanh toán VNPay  •  $money';
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded,
                color: AppColors.statusCancelledText),
            SizedBox(width: 8),
            Text(
              'Đặt hàng lỗi',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
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

  // ══════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final cart  = context.watch<CartProvider>();
    final items = cart.selectedItems.isNotEmpty
        ? cart.selectedItems
        : cart.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Xác nhận đơn hàng',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body scroll ─────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Thông tin giao hàng'),
                    _buildInputField(
                      controller: _addressController,
                      hint: 'Địa chỉ giao hàng',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(
                      controller: _phoneController,
                      hint: 'Số điện thoại nhận hàng',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(
                      controller: _noteController,
                      hint: 'Ghi chú (không bắt buộc)',
                      icon: Icons.note_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),

                    _buildSectionTitle('Món đã chọn'),
                    if (items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Chưa có món nào được chọn',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textMuted),
                        ),
                      )
                    else
                      ...items.map((it) => _buildOrderItem(it)),

                    const SizedBox(height: 20),

                    if (cart.appliedVoucherCode != null) ...[
                      _buildAppliedVoucherCard(cart),
                      const SizedBox(height: 20),
                    ],

                    _buildSectionTitle('Phương thức thanh toán'),
                    _buildPaymentSelector(),

                    // Preview thông tin ngân hàng khi chọn chuyển khoản
                    // (chưa có QR thật — QR thật hiện trong dialog sau khi tạo đơn)
                    if (_paymentMethod == PaymentMethod.transfer) ...[
                      const SizedBox(height: 12),
                      _buildTransferPreview(cart),
                    ],

                    const SizedBox(height: 20),
                    _buildSummaryCard(cart),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ── Nút đặt hàng ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: PrimaryButton(
                label: _buttonLabel(cart),
                onTap: _placeOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Voucher card ──────────────────────────────────────────
  Widget _buildAppliedVoucherCard(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent1, Color(0xFFFFAB7E)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đã áp dụng ${cart.appliedVoucherCode}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '-${(cart.discountAmount / 1000).toStringAsFixed(0)}.000đ',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Payment selector ──────────────────────────────────────
  Widget _buildPaymentSelector() {
    return Column(
      children: [
        _paymentOption(
          method:   PaymentMethod.cod,
          icon:     Icons.delivery_dining_outlined,
          title:    'Thanh toán khi nhận hàng (COD)',
          subtitle: 'Trả tiền mặt khi shipper giao tới',
        ),
        const SizedBox(height: 10),
        _paymentOption(
          method:   PaymentMethod.transfer,
          icon:     Icons.qr_code_rounded,
          title:    'Chuyển khoản ngân hàng',
          subtitle: 'Quét mã QR sau khi đặt hàng',
        ),
        const SizedBox(height: 10),
        _paymentOption(
          method:   PaymentMethod.vnpay,
          icon:     Icons.account_balance_wallet_outlined,
          title:    'Thanh toán VNPay',
          subtitle: 'Cổng VNPay – ATM/Visa/QR ngân hàng',
        ),
      ],
    );
  }

  Widget _paymentOption({
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pastel1 : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.accent1 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent1 : AppColors.divider,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.accent1 : Colors.white,
                border: Border.all(
                  color: isSelected ? AppColors.accent1 : AppColors.divider,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Preview thông tin CK (trước khi tạo đơn — không có QR thật) ──
  Widget _buildTransferPreview(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.pastel2.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent2.withValues(alpha:0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent2.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.qr_code_2_rounded,
                color: AppColors.accent2, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mã QR sẽ hiện sau khi đặt',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Nhấn "Xem QR & Đặt hàng" để tạo đơn và hiện mã QR chuyển khoản.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary card ──────────────────────────────────────────
  Widget _buildSummaryCard(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pastel1,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _row('Tạm tính',
              '${(cart.subtotal / 1000).toStringAsFixed(0)}.000đ'),
          const SizedBox(height: 7),
          _row('Phí giao hàng',
              '${(cart.deliveryFee / 1000).toStringAsFixed(0)}.000đ'),
          if (cart.discountAmount > 0) ...[
            const SizedBox(height: 7),
            _row(
              'Giảm giá${cart.appliedVoucherCode != null ? ' (${cart.appliedVoucherCode})' : ''}',
              '-${(cart.discountAmount / 1000).toStringAsFixed(0)}.000đ',
              valueColor: AppColors.accent3,
            ),
          ],
          const Divider(color: Color(0x33FF8C69), height: 20),
          _row(
            'Tổng cộng',
            '${(cart.total / 1000).toStringAsFixed(0)}.000đ',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Icon(icon, size: 18, color: AppColors.textMuted),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItemModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.pastel1,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildFoodImage(item),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.food.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  'x${item.quantity}  •  ${(item.food.price / 1000).toStringAsFixed(0)}.000đ/món',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Text(
            '${(item.totalPrice / 1000).toStringAsFixed(0)}.000đ',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.accent1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage(CartItemModel item) {
    final url = item.food.imageUrl;
    if (url == null || url.isEmpty) {
      return const Icon(Icons.fastfood, color: AppColors.accent1);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: url.startsWith('http')
          ? Image.network(url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.fastfood, color: AppColors.accent1))
          : Image.asset(url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.fastfood, color: AppColors.accent1)),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w400,
            color: isTotal ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ??
                (isTotal ? AppColors.accent1 : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

// QR placeholder (fallback khi API lỗi)
class _QrPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final cellSize = size.width / 10;
    final pattern = [
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 0],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 0, 1, 0, 1, 1, 0],
      [0, 1, 0, 0, 1, 0, 1, 0, 0, 1],
    ];
    for (int row = 0; row < pattern.length; row++) {
      for (int col = 0; col < pattern[row].length; col++) {
        if (pattern[row][col] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * cellSize + 4,
              row * cellSize + 4,
              cellSize - 1,
              cellSize - 1,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}