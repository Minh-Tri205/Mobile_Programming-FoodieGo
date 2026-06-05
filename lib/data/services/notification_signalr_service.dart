// SignalR realtime cho Notification.
// - Backend hub mac dinh: http://10.0.2.2:5187/hubs/notification
// - Event lang nghe: "ReceiveNotification" (payload = NotificationModel JSON)
// - Auto-reconnect khi mat mang (signalr_netcore tu xu ly neu set withAutomaticReconnect)
//
// Khong dung GetX. Service nay chi giu HubConnection va expose callback;
// NotificationProvider se subscribe roi notifyListeners.
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../models/notification_model.dart';

class NotificationSignalRService {
  // Doi URL nay neu hub backend mount o path khac.
  static const String hubUrl = 'http://10.0.2.2:5187/hubs/notification';

  HubConnection? _hub;
  bool _isConnecting = false;

  // Callback khi nhan notification moi tu server
  void Function(NotificationModel n)? onReceiveNotification;

  bool get isConnected =>
      _hub != null && _hub!.state == HubConnectionState.Connected;

  Future<void> connect(int userId) async {
    if (isConnected || _isConnecting) return;
    _isConnecting = true;

    try {
      // Truyen userId qua query de hub group user khi join (server tu xu ly)
      final url = '$hubUrl?userId=$userId';

      _hub = HubConnectionBuilder()
          .withUrl(url)
          .withAutomaticReconnect(
            retryDelays: [0, 2000, 5000, 10000, 30000],
          )
          .build();

      _hub!.onclose(({Exception? error}) {
        debugPrint('[SignalR] connection closed: $error');
      });
      _hub!.onreconnecting(({Exception? error}) {
        debugPrint('[SignalR] reconnecting: $error');
      });
      _hub!.onreconnected(({String? connectionId}) {
        debugPrint('[SignalR] reconnected: $connectionId');
      });

      // Lang nghe event "ReceiveNotification"
      _hub!.on('ReceiveNotification', _handleReceive);

      await _hub!.start();
      debugPrint('[SignalR] connected userId=$userId');
    } catch (e) {
      debugPrint('[SignalR] connect FAILED: $e');
      _hub = null;
    } finally {
      _isConnecting = false;
    }
  }

  void _handleReceive(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    try {
      final raw = args.first;
      if (raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        final notif = NotificationModel.fromJson(map);
        onReceiveNotification?.call(notif);
      }
    } catch (e) {
      debugPrint('[SignalR] parse notification error: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      await _hub?.stop();
    } catch (_) {}
    _hub = null;
  }
}
