import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PaymentQrInfo {
  final int orderId;
  final String orderCode;
  final int amount;
  final String transferContent;
  final String bankId;
  final String bankName;
  final String accountNo;
  final String accountName;
  final String qrImageUrl;

  PaymentQrInfo({
    required this.orderId,
    required this.orderCode,
    required this.amount,
    required this.transferContent,
    required this.bankId,
    required this.bankName,
    required this.accountNo,
    required this.accountName,
    required this.qrImageUrl,
  });

  factory PaymentQrInfo.fromJson(Map<String, dynamic> json) {
    return PaymentQrInfo(
      orderId:         json['orderId']         as int,
      orderCode:       json['orderCode']        as String,
      amount:          (json['amount'] as num).toInt(),
      transferContent: json['transferContent']  as String,
      bankId:          json['bankId']           as String,
      bankName:        json['bankName']         as String,
      accountNo:       json['accountNo']        as String,
      accountName:     json['accountName']      as String,
      qrImageUrl:      json['qrImageUrl']       as String,
    );
  }
}

class PaymentService {
  static const String _baseUrl = 'http://10.0.2.2:5187/api/Payment';

  /// Lấy thông tin QR thanh toán cho đơn hàng đã tạo
  Future<PaymentQrInfo> getQrInfo(int orderId) async {
    final uri = Uri.parse('$_baseUrl/qr/$orderId');
    debugPrint('[PaymentService] GET $uri');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return PaymentQrInfo.fromJson(data);
    }

    throw Exception(
      'Không thể tải thông tin QR (${response.statusCode}): ${response.body}',
    );
  }

  /// Tao URL thanh toan VNPay tu backend.
  /// Backend tu ky HMAC SHA512 voi Hash Secret cua merchant -> KHONG lo lo key o client.
  /// Endpoint backend du kien:
  ///   POST /api/Payment/vnpay/{orderId}
  ///   Response: { "paymentUrl": "https://sandbox.vnpayment.vn/..." }
  Future<String> createVnpayUrl(int orderId) async {
    final uri = Uri.parse('$_baseUrl/vnpay/$orderId');
    debugPrint('[PaymentService] POST $uri');

    final response = await http.post(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final url = (data['paymentUrl'] ?? data['PaymentUrl'] ?? '').toString();
      if (url.isEmpty) {
        throw Exception('Backend khong tra ve paymentUrl');
      }
      return url;
    }

    throw Exception(
      'Khong tao duoc URL VNPay (${response.statusCode}): ${response.body}',
    );
  }
}