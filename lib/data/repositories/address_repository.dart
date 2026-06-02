// lib/data/repositories/address_repository.dart
import '../../models/address_model.dart';
import '../services/address_service.dart';

class AddressRepository {
  final AddressService service;

  AddressRepository(this.service);

  Future<List<AddressModel>> getAll() => service.getAll();
  Future<AddressModel> getById(int id) => service.getById(id);
  Future<List<AddressModel>> getByUser(int userId) => service.getByUser(userId);
  Future<AddressModel> create(AddressModel a) => service.create(a);
  Future<void> update(int id, AddressModel a) => service.update(id, a);
  Future<void> patch(int id, Map<String, dynamic> data) =>
      service.patch(id, data);
  Future<void> delete(int id) => service.delete(id);
}
