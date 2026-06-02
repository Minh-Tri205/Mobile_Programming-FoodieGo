// lib/data/repositories/voucher_usage_repository.dart
import '../../models/voucher_usage_model.dart';
import '../services/voucher_usage_service.dart';

class VoucherUsageRepository {
  final VoucherUsageService service;

  VoucherUsageRepository(this.service);

  Future<List<VoucherUsageModel>> getAll() => service.getAll();
  Future<VoucherUsageModel> getById(int id) => service.getById(id);
  Future<List<VoucherUsageModel>> getByUser(int userId) =>
      service.getByUser(userId);
  Future<VoucherUsageModel> create(VoucherUsageModel u) => service.create(u);
  Future<void> delete(int id) => service.delete(id);
}
