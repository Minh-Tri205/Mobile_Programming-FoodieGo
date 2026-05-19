class BankTransferDetail {
  final int detailId;
  final String bankName;
  final String accountNumber;
  final String accountOwner;
  final String? qrCodeUrl;
  final String? paymentInstructions;
  final bool isActive;

  const BankTransferDetail({
    required this.detailId,
    required this.bankName,
    required this.accountNumber,
    required this.accountOwner,
    this.qrCodeUrl,
    this.paymentInstructions,
    this.isActive = true,
  });

  static List<BankTransferDetail> sampleBankDetails = [
    BankTransferDetail(
      detailId: 1,
      bankName: 'Ngân hàng Vietcombank',
      accountNumber: '1234567890',
      accountOwner: 'FoodieGo Restaurant',
      paymentInstructions:
          'Chuyển khoản nhanh (VCB) để xác nhận đơn hàng. Ghi rõ mã đơn hàng trong nội dung chuyển khoản.',
      isActive: true,
    ),
    BankTransferDetail(
      detailId: 2,
      bankName: 'Ngân hàng Techcombank',
      accountNumber: '0987654321',
      accountOwner: 'FoodieGo Restaurant',
      paymentInstructions:
          'Sử dụng tính năng chuyển khoản 24/7. Quý khách vui lòng ghi mã đơn hàng trong phần nội dung.',
      isActive: true,
    ),
  ];
}
