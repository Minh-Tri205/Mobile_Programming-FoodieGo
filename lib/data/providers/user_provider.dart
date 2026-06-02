import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository repository;

  UserProvider(this.repository);

  List<UserModel> users = [];

  bool isLoading = false;

  UserModel? currentUser;

  bool isLoadingProfile = false;

  int? currentUserId;

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

  // GET BY ID
  void setCurrentUserId(int id) {
    currentUserId = id;
    notifyListeners();
  }

  Future<void> fetchUserById(int id) async {
    try {
      isLoadingProfile = true;
      notifyListeners();

      currentUser = await repository.getUserById(id);
    } finally {
      isLoadingProfile = false;
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

  // UPDATE MULTIPART - dung cho upload avatar
  // Tra ve UserModel da update; cap nhat currentUser neu trung id
  Future<UserModel> updateUserMultipart(
    int id, {
    Map<String, String>? fields,
    String? avatarFilePath,
  }) async {
    try {
      isLoadingProfile = true;
      notifyListeners();

      final updated = await repository.updateUserMultipart(
        id,
        fields: fields,
        avatarFilePath: avatarFilePath,
      );

      // Backend tra ve thieu mot so truong (vd: passwordHash, createdAt)
      // -> merge voi currentUser cu de giu nguyen cac truong khac
      if (currentUser != null && currentUser!.userId == id) {
        currentUser = UserModel(
          userId: updated.userId,
          fullName: updated.fullName.isNotEmpty
              ? updated.fullName
              : currentUser!.fullName,
          email: updated.email ?? currentUser!.email,
          phone: updated.phone ?? currentUser!.phone,
          passwordHash: currentUser!.passwordHash,
          avatarUrl: updated.avatarUrl ?? currentUser!.avatarUrl,
          deviceToken: currentUser!.deviceToken,
          role: updated.role ?? currentUser!.role,
          isActive: updated.isActive ?? currentUser!.isActive,
          loyaltyPoints: updated.loyaltyPoints ?? currentUser!.loyaltyPoints,
          passwordResetToken: currentUser!.passwordResetToken,
          resetTokenExpiry: currentUser!.resetTokenExpiry,
          createdAt: currentUser!.createdAt,
          updatedAt: DateTime.now(),
        );
      }

      // Cap nhat trong list users (neu co)
      final idx = users.indexWhere((u) => u.userId == id);
      if (idx != -1) {
        users[idx] = currentUser ?? updated;
      }

      error = null;
      return currentUser ?? updated;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoadingProfile = false;
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
