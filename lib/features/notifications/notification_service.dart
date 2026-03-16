import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService(this._messaging);

  final FirebaseMessaging _messaging;

  Future<void> init() async {
    await _messaging.requestPermission();
    await _messaging.getToken();
  }
}
