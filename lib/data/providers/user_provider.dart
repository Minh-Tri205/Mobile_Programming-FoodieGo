import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository repository;

  UserProvider(this.repository);

  List<UserModel> users = [];

  bool isLoading = false;

  String? error;

  // GET ALL
  Future<void> fetchUsers() async {
    try {
      isLoading = true;

      notifyListeners();

      users = await repository.getUsers();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  // CREATE
  Future<void> createUser(UserModel user) async {
    await repository.createUser(user);

    await fetchUsers();
  }

  // UPDATE
  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    await repository.updateUser(id, data);

    final index = users.indexWhere((e) => e.userId == id);

    if (index != -1) {
      final oldUser = users[index];

      users[index] = UserModel(
        userId: oldUser.userId,

        fullName: data['fullName'] ?? oldUser.fullName,

        email: data['email'] ?? oldUser.email,

        phone: data['phone'] ?? oldUser.phone,

        passwordHash: data['passwordHash'] ?? oldUser.passwordHash,

        avatarUrl: data['avatarUrl'] ?? oldUser.avatarUrl,

        deviceToken: data['deviceToken'] ?? oldUser.deviceToken,

        role: data['role'] ?? oldUser.role,

        isActive: data['isActive'] ?? oldUser.isActive,

        loyaltyPoints: data['loyaltyPoints'] ?? oldUser.loyaltyPoints,

        passwordResetToken:
            data['passwordResetToken'] ?? oldUser.passwordResetToken,

        resetTokenExpiry: data['resetTokenExpiry'] ?? oldUser.resetTokenExpiry,

        createdAt: oldUser.createdAt,

        updatedAt: DateTime.now(),
      );

      notifyListeners();
    }
  }

  // DELETE
  Future<void> deleteUser(int id) async {
    try {
      await repository.deleteUser(id);

      users = users.where((e) => e.userId != id).toList();

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
    Future<void> toggleStatus(int id) async {
    try {
      await repository.toggleStatus(id);

      final index = users.indexWhere((u) => u.userId == id);

      if (index != -1) {
        users[index].isActive = !(users[index].isActive ?? false);
        notifyListeners();
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }

      Future<void> deactivateUser(int id) async {
      try {
        await repository.deactivateUser(id);

        final index = users.indexWhere((u) => u.userId == id);

        if (index != -1) {
          users[index].isActive = false;
          notifyListeners();
        }
      } catch (e) {
        error = e.toString();
        notifyListeners();
      }
    }
  }
    Future<void> activateUser(int id) async {
    try {
      await repository.activateUser(id);

      final index = users.indexWhere((u) => u.userId == id);

      if (index != -1) {
        users[index].isActive = true;
        notifyListeners();
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
    Future<void> changeRole(int id, String role) async {
    try {
      await repository.changeRole(id, role);

      final index = users.indexWhere((u) => u.userId == id);

      if (index != -1) {
        users[index].role = role;
        notifyListeners();
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
