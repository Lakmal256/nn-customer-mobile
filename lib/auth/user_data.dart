class UserData {
  String? email;
  String? name;

  UserData({this.email, this.name});

  static List<String> splitName(String value) {
    return ["", ""]..replaceRange(0, 1, value.split(" "));
  }
}

class Tokens {
  String? accessToken;
  String? idToken;

  Tokens({this.accessToken, this.idToken});
}

class SocialAuthResult{
  Tokens tokens;
  UserData data;

  SocialAuthResult({required this.tokens, required this.data});
}