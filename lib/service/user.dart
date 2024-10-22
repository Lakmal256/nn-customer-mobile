import 'package:flutter/foundation.dart';
import 'package:nawa_niwasa/service/dto.dart';

enum UserType { guest, normal }

class User {
  String sessionId;
  UserType type;
  UserResponseDto data;

  User({required this.sessionId, required this.data, required this.type});
}

class UserService extends ValueNotifier<User?> {
  UserService(super.value);

  setValue(User user) {
    value = user;
    notifyListeners();
  }
}
