// lib/data/providers/voucher_usage_provider.dart
import 'package:flutter/material.dart';
import '../../models/voucher_usage_model.dart';
import '../repositories/voucher_usage_repository.dart';

class VoucherUsageProvider extends ChangeNotifier {
  final VoucherUsageRepository repository;

  VoucherUsageProvider(this.repository);

  List<VoucherUsageModel> usages = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchAll() async {
    try {
      isLoading = true;
      notifyListeners();
      usages = await repository.getAll();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchByUser(int userId) async {
    try {
      isLoading = true;
      notifyListeners();
      usages = await repository.getByUser(userId);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<VoucherUsageModel> create(VoucherUsageModel u) async {
    final created = await repository.create(u);
    usages.add(created);
    notifyListeners();
    return created;
  }

  int countByVoucher(int voucherId) =>
      usages.where((u) => u.voucherId == voucherId).length;
}
