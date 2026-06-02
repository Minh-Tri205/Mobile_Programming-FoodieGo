// lib/data/repositories/voucher_repository.dart
import '../../models/voucher_model.dart';
import '../services/voucher_service.dart';

class VoucherRepository {
  final VoucherService service;

  VoucherRepository(this.service);

  Future<List<VoucherModel>> getAll() => service.getAll();
  Future<VoucherModel> getById(int id) => service.getById(id);
  Future<VoucherModel> create(VoucherModel v) => service.create(v);
  Future<VoucherModel> update(int id, VoucherModel v) => service.update(id, v);
  Future<void> patch(int id, Map<String, dynamic> data) =>
      service.patch(id, data);
  Future<void> delete(int id) => service.delete(id);
}
