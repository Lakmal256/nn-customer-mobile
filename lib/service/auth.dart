import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';

import 'dto.dart';
import 'permission.dart';

class AuthData {
  AuthData({
    required this.identityId,
    required this.accessToken,
    required this.refreshToken,
    required this.userIdentificationRecord,
  });

  final String identityId;

  /// This would be the user email
  final String userIdentificationRecord;
  final String accessToken;
  final String refreshToken;

  AuthData copyWith({
    String? identityId,
    String? accessToken,
    String? refreshToken,
    String? userIdentificationRecord,
  }) =>
      AuthData(
        identityId: identityId ?? this.identityId,
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        userIdentificationRecord: userIdentificationRecord ?? this.userIdentificationRecord,
      );

  String get bearerToken => 'Bearer $accessToken';
}

abstract class AuthEventHandler {
  AuthEventHandler();

  FutureOr onData(AuthData data);

  FutureOr onSessionError(Object object);
}

/// The primary use is to notify the application router to rebuild when session expired
/// or when changing session data
class AuthSessionShockerEventHandler extends ValueNotifier<Object?> implements AuthEventHandler {
  AuthSessionShockerEventHandler() : super(null);

  @override
  FutureOr onSessionError(Object object) {
    value = object;
  }

  @override
  FutureOr onData(AuthData data) {
    value = data;
  }

  bool get shouldAuthenticate => value == null || value is Exception || value is Error;
}

abstract class AuthService {
  refreshToken();

  FutureOr<AuthData> getData();
}

class RestAuthServiceConfig {
  RestAuthServiceConfig({
    required this.authority,
    String? pathPrefix,
  }) : pathPrefix = pathPrefix ?? '';

  final String authority;

  final String? pathPrefix;
}

class RestAuthService implements AuthService {
  RestAuthService({required this.config, this.authData});

  RestAuthServiceConfig config;

  AuthData? authData;

  AuthEventHandler? eventHandler;

  setEventHandler(AuthEventHandler handler) {
    eventHandler = handler;
  }

  setData(AuthData data) {
    authData = data;
    eventHandler?.onData(data);
  }

  @override
  getData() async {
    if (authData == null) eventHandler?.onSessionError(Exception());

    final parts = authData!.accessToken.split('.');
    if (parts.length != 3) throw Exception();

    // Decode the payload (second part) of the JWT
    Map<String, dynamic> decodedToken = Jwt.parseJwt(authData!.accessToken);

    // Extract the expiration time (exp) from the decoded token
    final expiryTimestamp = decodedToken['exp'] ?? 0;

    // Check if the token has expired by comparing the expiration time with the current time
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000; // Convert milliseconds to seconds

    if (now >= expiryTimestamp) await refreshToken();

    return authData!;
  }

  @override
  refreshToken() async {
    try {
      if (authData?.refreshToken == null && authData?.userIdentificationRecord == null) {
        throw Exception('Data not found');
      }

      final response = await http.post(
        Uri.https(config.authority, "${config.pathPrefix}/identity/user/login/refresh"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "username": authData?.userIdentificationRecord,
          "refreshToken": authData?.refreshToken,
        }),
      );

      if (response.statusCode == HttpStatus.ok) {
        final decodedJson = json.decode(response.body);
        final tokenResponse = TokenResponse.fromJson(decodedJson);
        setData(
          authData!.copyWith(
            identityId: tokenResponse.identityId,
            accessToken: tokenResponse.token,
            refreshToken: tokenResponse.refreshToken,
            userIdentificationRecord: tokenResponse.user?.email,
          ),
        );
        return;
      } else if (response.statusCode == HttpStatus.unauthorized) {
        throw Exception('Unauthorized');
      }
    } catch (error) {
      eventHandler?.onSessionError(error);
      return;
    }
  }
}
