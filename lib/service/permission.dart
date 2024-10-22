import 'package:flutter/foundation.dart';

class PermissionService {
  PermissionService() : _permits = [];

  set permits(List<String> value) {
    _permits = value;
  }

  List<String> _permits;

  bool request(List<String> permits) {
    return _permits.any((p0) => permits.any((p1) => p1.contains(RegExp(p0))));
  }
}

class ListenablePermissionService extends ChangeNotifier {
  ListenablePermissionService(this.service);

  PermissionService service;

  bool? _result;

  bool request(List<String> permits) {
    final tr = _result;
    _result = service.request(permits);
    if (tr != _result) notifyListeners();
    return isPermitted;
  }

  bool get isPermitted => _result ?? false;
}
