import 'package:google_sign_in/google_sign_in.dart';
import 'package:nawa_niwasa/locator.dart';

import 'user_data.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static GoogleSignInAccount? account;

  static Future login() async {
    account = await GoogleSignIn(
      scopes: ['email', 'openid'],
    ).signIn();
  }

  static Future<SocialAuthResult?> getUserData() async {
    Future<SocialAuthResult?> getData() async {
      final GoogleSignInAuthentication? googleAuth = await account?.authentication;

      return SocialAuthResult(
        tokens: Tokens(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        ),
        data: UserData(email: account?.email, name: account?.displayName),
      );
    }

    if (account != null) {
      return await getData();
    } else {
      await login();
      return await getData();
    }
  }

  logout() async {
    await GoogleSignIn().signOut();
    account = null;
  }

  static Future<String?> get accessToken async => (await account!.authentication).accessToken;
}
