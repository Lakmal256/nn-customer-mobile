import 'package:nawa_niwasa/auth/user_data.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleLoginError implements Exception {}

class AppleAuthService {
  AppleAuthService._();
  static AuthorizationCredentialAppleID? appleID;

  static Future login() async {
    try {
      appleID = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
    } catch (_) {
      throw AppleLoginError();
    }
  }

  static Future<SocialAuthResult?> getUserData() async {
    Future<SocialAuthResult?> getData() async {
      return SocialAuthResult(
        tokens: Tokens(
          accessToken: '',
          idToken: idToken,
        ),
        data: UserData(email: appleID?.email ?? "", name: appleID?.givenName ?? ""),
      );
    }

    if (idToken != null) {
      return await getData();
    } else {
      await login();
      return await getData();
    }
  }

  static logout() async {}

  static String? get idToken => appleID?.identityToken;
}
