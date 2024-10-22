import 'package:flutter/material.dart';
import 'package:nawa_niwasa/service/service.dart';

class InAppNotificationHandler extends ChangeNotifier {
  InAppNotificationHandler({required this.restService}) : notifications = List.empty(growable: true);

  final RestService restService;

  List<NotificationDto> notifications;

  Future sync() async {
    notifications = await restService.getAllNotifications();
    notifyListeners();
  }

  Future markAsRead(NotificationDto notification) async {
    final isOk = await restService.markNotificationAsRead(id: notification.id);
    if (!isOk) return;

    notifications = await restService.getAllNotifications();
    notifyListeners();
  }

  int get count => notifications.length;
}
