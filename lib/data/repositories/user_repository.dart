import '../../models/user_model.dart';
import '../services/user_service.dart';

class UserRepository {
  final UserService service;

  UserRepository(this.service);

  Future<List<UserModel>> getUsers() {
    return service.getUsers();
  }

  Future<UserModel> getUserById(int id) {
    return service.getUserById(id);
  }

  Future<void> createUser(UserModel user) {
    return service.createUser(user);
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) {
    return service.updateUser(id, data);
  }

  Future<UserModel> updateUserMultipart(
    int id, {
    Map<String, String>? fields,
    String? avatarFilePath,
  }) {
    return service.updateUserMultipart(
      id,
      fields: fields,
      avatarFilePath: avatarFilePath,
    );
  }

  Future<void> deleteUser(int id) {
    return service.deleteUser(id);
  }

  Future<void> toggleStatus(int id) {
    return service.toggleStatus(id);
  }

  Future<void> activateUser(int id) {
    return service.activateUser(id);
  }

  Future<void> deactivateUser(int id) {
    return service.deactivateUser(id);
  }

  Future<void> changeRole(int id, String role) {
    return service.changeRole(id, role);
  }
}
