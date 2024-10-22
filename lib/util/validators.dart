class StringValidators {
  StringValidators._();

  static email(String value) {
    String pattern = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    if(!RegExp(pattern).hasMatch(value)) throw ArgumentError("Invalid email address");
  }

  static mobile(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
    if(!RegExp(pattern).hasMatch(value)) throw ArgumentError("Invalid mobile number");
  }

  static isPure(String value) {
    String pattern = r'([^A-Za-z])';
    if(RegExp(pattern).hasMatch(value)) throw ArgumentError("Numbers, Spaces and special characters are not allowed");
  }

  /// Allow letters and single spaces
  static isPureWithSingleWhiteSpace(String value) {
    String pattern = r'([^a-zA-Z ]|\s{2})';
    if(RegExp(pattern).hasMatch(value)) throw ArgumentError("Numbers and special characters are not allowed");
  }

  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// User should follow below standards to create new password
  ///
  /// Password policy: the following password policy is enforced when creating users in ODMS.
  /// At least 8 characters long but 12 or more is better.
  /// A combination of at least 1 character from uppercase letters, lowercase letters, numbers, and symbols each.
  /// Not a word that could be found in a dictionary or the name of a person, character, product, or organization.
  /// Significantly different from their previous password in case of reset of expiry password.
  ///
  /// String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  ///
  static password(String value) {
    if (value.length < 8) throw ArgumentError("Password must be at least 8 characters long");
    if(!RegExp(r'[A-Z]').hasMatch(value)) throw ArgumentError("Required least one uppercase letter");
    if(!RegExp(r'[a-z]').hasMatch(value)) throw ArgumentError("Required least one lowercase letter");
    if(!RegExp(r'[0-9]').hasMatch(value)) throw ArgumentError("Required least one number");
    if(!RegExp(r'[!@#\$&*~]').hasMatch(value)) throw ArgumentError("Required least one special character");
  }
}
