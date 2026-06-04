// lib/data/services/otp_email_service.dart
// Service gui OTP qua Gmail SMTP.
//
// SETUP TRUOC KHI DUNG:
//   1) Bat 2FA cho tai khoan Gmail (myaccount.google.com -> Security).
//   2) Vao https://myaccount.google.com/apppasswords tao "App password"
//      moi cho ung dung -> copy 16 ky tu (vd: abcd efgh ijkl mnop).
//   3) Dien `senderEmail` + `senderAppPassword` ben duoi (KHONG dung mat
//      khau Gmail thuong — phai dung App Password vi Google chan SMTP
//      voi mat khau thuong).
//
// LUU Y BAO MAT:
//   - Trong production NEN dat endpoint gui email o backend (.NET) thay vi
//     bundle credential trong app. Day la fix tam thoi cho do an.
//   - File nay co the duoc dua vao .gitignore neu can tranh leak.

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class OtpEmailService {
  static const String senderEmail = 'triprozx3@gmail.com';
  static const String senderAppPassword = 'gsgv exkd lthr ruaq';
  static const String senderName = 'FoodieGo';

  static String generateOtp() {
    final r = Random.secure();
    return List.generate(4, (_) => r.nextInt(10)).join();
  }

  // Gui OTP toi `toEmail`. Throw Exception khi gui that bai.
  static Future<void> sendOtp({
    required String toEmail,
    required String otp,
  }) async {
    if (senderEmail.contains('YOUR_EMAIL') ||
        senderAppPassword.contains('YOUR_16_CHAR')) {
      throw Exception(
        'Chua cau hinh Gmail App Password trong otp_email_service.dart',
      );
    }

    final smtpServer = gmail(senderEmail, senderAppPassword);

    final message = Message()
      ..from = Address(senderEmail, senderName)
      ..recipients.add(toEmail)
      ..subject = '[FoodieGo] Mã OTP đặt lại mật khẩu'
      ..text =
          'Mã OTP của bạn là: $otp\n\nMã có hiệu lực 5 phút. Vui lòng không chia sẻ.'
      ..html =
          '''
<div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto;
            padding: 24px; background: #FFF8F2; border-radius: 16px;">
  <h2 style="color: #FF8A4C; margin: 0 0 12px;">FoodieGo</h2>
  <p style="font-size: 14px; color: #333;">Xin chào,</p>
  <p style="font-size: 14px; color: #333;">
    Bạn vừa yêu cầu đặt lại mật khẩu. Mã OTP của bạn là:
  </p>
  <div style="font-size: 32px; font-weight: 800; letter-spacing: 8px;
              text-align: center; color: #FF8A4C; padding: 16px;
              background: #FFFFFF; border-radius: 12px; margin: 16px 0;">
    $otp
  </div>
  <p style="font-size: 12px; color: #888;">
    Mã có hiệu lực trong 5 phút. Nếu bạn không yêu cầu, hãy bỏ qua email này.
  </p>
</div>
''';

    try {
      final report = await send(message, smtpServer);
      debugPrint('[OtpEmailService] sent: ${report.toString()}');
    } on MailerException catch (e) {
      debugPrint('[OtpEmailService] FAIL: ${e.message}');
      for (final p in e.problems) {
        debugPrint('  - ${p.code}: ${p.msg}');
      }
      throw Exception('Gửi email thất bại: ${e.message}');
    }
  }
}
