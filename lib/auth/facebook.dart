import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'user_data.dart';

class NotLoggedIn implements Exception {}

class FacebookLoginError implements Exception {}

class FacebookAuthService {
  FacebookAuthService._();

  static Future login() async {
    final LoginResult loginResult = await FacebookAuth.instance.login(
      loginBehavior: LoginBehavior.nativeWithFallback,
      permissions: const ['email', 'public_profile', 'user_location']
    );
    if (loginResult.status != LoginStatus.success) {
      throw FacebookLoginError();
    }
  }

  static Future<SocialAuthResult?> getUserData() async {
    Future<SocialAuthResult?> getData() async {
      final token = await accessToken;
      final data = await FacebookAuth.instance.getUserData();
      return SocialAuthResult(
        tokens: Tokens(
          accessToken: token?.token,
        ),
        data: UserData(
          email: data["email"] ?? "",
          name: data["name"] ?? ""
        ),
      );
    }

    if (await accessToken != null) {
      return await getData();
    } else {
      await login();
      return await getData();
    }
  }

  static logout() async {
    await FacebookAuth.instance.logOut();
  }

  static Future<AccessToken?> get accessToken => FacebookAuth.instance.accessToken;
}
