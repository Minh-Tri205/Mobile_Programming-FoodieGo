// lib/data/providers/address_provider.dart
import 'package:flutter/material.dart';
import '../../models/address_model.dart';
import '../repositories/address_repository.dart';

class AddressProvider extends ChangeNotifier {
  final AddressRepository repository;

  AddressProvider(this.repository);

  List<AddressModel> addresses = [];
  bool isLoading = false;
  String? error;

  AddressModel? get defaultAddress {
    for (final a in addresses) {
      if (a.isDefault == true) return a;
    }
    return addresses.isNotEmpty ? addresses.first : null;
  }

  Future<void> fetchByUser(int userId) async {
    try {
      isLoading = true;
      notifyListeners();
      addresses = await repository.getByUser(userId);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> create(AddressModel address) async {
    final created = await repository.create(address);
    // Neu dia chi moi la default thi cac dia chi cu khac da bi backend xu ly
    if (created.isDefault == true) {
      addresses = addresses
          .map((a) => a.copyWith(isDefault: false))
          .toList();
    }
    addresses.add(created);
    notifyListeners();
  }

  Future<void> update(int id, AddressModel address) async {
    await repository.update(id, address);
    final idx = addresses.indexWhere((a) => a.addressId == id);
    if (idx != -1) {
      // Neu set default cho cai nay, cac cai khac thanh false
      if (address.isDefault == true) {
        addresses = addresses
            .map((a) => a.addressId == id
                ? address
                : a.copyWith(isDefault: false))
            .toList();
      } else {
        addresses[idx] = address;
      }
      notifyListeners();
    }
  }

  Future<void> setDefault(int id, int userId) async {
    final target = addresses.firstWhere((a) => a.addressId == id);
    final updated = target.copyWith(isDefault: true);
    await update(id, updated);
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    addresses = addresses.where((a) => a.addressId != id).toList();
    notifyListeners();
  }
}
