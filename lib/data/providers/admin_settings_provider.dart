// lib/data/providers/admin_settings_provider.dart
// Provider luu cac tuy chinh chi-runtime cho khu vuc admin:
//   - backgroundColor: mau nen Scaffold cua cac man hinh admin
//   - notificationsEnabled: bat/tat thong bao
//   - compactMode: rut gon padding (visual hint, chua apply sau)
//
// Khong persist sang lan mo app sau (chua co shared_preferences trong
// pubspec). Doi voi do an thi du dung; muon persist thi them
// shared_preferences va save/restore trong constructor.

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AdminBgPreset {
  final String label;
  final Color color;
  const AdminBgPreset(this.label, this.color);
}

class AdminSettingsProvider extends ChangeNotifier {
  // Bang mau preset cho nen man hinh admin
  static const List<AdminBgPreset> presets = [
    AdminBgPreset('Kem', AppColors.background), // #FFFAF8 mac dinh
    AdminBgPreset('Trang', Color(0xFFFFFFFF)),
    AdminBgPreset('Hong nhat', Color(0xFFFFF1F0)),
    AdminBgPreset('Xanh nhat', Color(0xFFF1F7FF)),
    AdminBgPreset('Tim nhat', Color(0xFFF6F1FF)),
    AdminBgPreset('Xam', Color(0xFFF2F2F4)),
  ];

  Color _backgroundColor = AppColors.background;
  bool _notificationsEnabled = true;
  bool _compactMode = false;

  Color get backgroundColor => _backgroundColor;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get compactMode => _compactMode;

  void setBackground(Color c) {
    if (_backgroundColor == c) return;
    _backgroundColor = c;
    notifyListeners();
  }

  void toggleNotifications(bool v) {
    _notificationsEnabled = v;
    notifyListeners();
  }

  void toggleCompactMode(bool v) {
    _compactMode = v;
    notifyListeners();
  }

  void resetToDefaults() {
    _backgroundColor = AppColors.background;
    _notificationsEnabled = true;
    _compactMode = false;
    notifyListeners();
  }
}
