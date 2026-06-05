import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/notification_model.dart';

class NotificationService {
  // Cung kieu pattern voi cac service khac trong project
  static const String baseUrl = 'http://10.0.2.2:5187/api/Notification';

  // GET ALL
  Future<List<NotificationModel>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    }
    throw Exception('Fetch notifications failed: ${res.statusCode}');
  }

  // GET BY USER
  Future<List<NotificationModel>> getByUser(int userId) async {
    final uri = Uri.parse('$baseUrl/user/$userId');
    debugPrint('[NotificationService] GET $uri');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    }
    throw Exception('Fetch user notifications failed: ${res.statusCode}');
  }

  // GET UNREAD COUNT
  Future<int> getUnreadCount(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl/unread-count/$userId'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final count = data['unreadCount'] ?? data['UnreadCount'] ?? 0;
      return count is int ? count : int.tryParse(count.toString()) ?? 0;
    }
    throw Exception('Fetch unread count failed: ${res.statusCode}');
  }

  // MARK AS READ
  Future<void> markAsRead(int notificationId) async {
    final res = await http.patch(Uri.parse('$baseUrl/read/$notificationId'));
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Mark as read failed: ${res.statusCode}');
    }
  }

  // MARK ALL AS READ
  Future<void> markAllAsRead(int userId) async {
    final res = await http.patch(Uri.parse('$baseUrl/read-all/$userId'));
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Mark all as read failed: ${res.statusCode}');
    }
  }

  // DELETE
  Future<void> delete(int notificationId) async {
    final res = await http.delete(Uri.parse('$baseUrl/$notificationId'));
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Delete notification failed: ${res.statusCode}');
    }
  }
}
