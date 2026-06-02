// lib/data/providers/voucher_provider.dart
import 'package:flutter/material.dart';
import '../../models/voucher_model.dart';
import '../repositories/voucher_repository.dart';

class VoucherProvider extends ChangeNotifier {
  final VoucherRepository repository;

  VoucherProvider(this.repository);

  List<VoucherModel> vouchers = [];
  bool isLoading = false;
  String? error;

  List<VoucherModel> get activeVouchers => vouchers
      .where((v) =>
          (v.isActive ?? false) &&
          (v.endDate == null || v.endDate!.isAfter(DateTime.now())))
      .toList();

  Future<void> fetchAll() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();
      vouchers = await repository.getAll();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> create(VoucherModel v) async {
    final created = await repository.create(v);
    vouchers.add(created);
    notifyListeners();
  }

  Future<void> update(int id, VoucherModel v) async {
    final updated = await repository.update(id, v);
    final idx = vouchers.indexWhere((x) => x.voucherId == id);
    if (idx != -1) {
      vouchers[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> toggleActive(VoucherModel v) async {
    final id = v.voucherId;
    if (id == null) return;
    final newVal = !(v.isActive ?? false);
    // Gui kem code de backend PATCH biet voucher nao (va de log/kiem tra unique)
    await repository.patch(id, {'code': v.code, 'isActive': newVal});
    final idx = vouchers.indexWhere((x) => x.voucherId == id);
    if (idx != -1) {
      vouchers[idx] = v.copyWith(isActive: newVal);
      notifyListeners();
    }
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    vouchers = vouchers.where((v) => v.voucherId != id).toList();
    notifyListeners();
  }
}
