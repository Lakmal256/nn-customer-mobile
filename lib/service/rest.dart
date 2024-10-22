import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'auth.dart';
import 'dto.dart';

class UserNotFoundException implements Exception {}

class UnauthorizedException implements Exception {}

class BlockedUserException implements Exception {}

class ConflictedUserException implements Exception {}

class DuplicateBoqEstimateException implements Exception {}

class DraftedCardNotFoundException implements Exception {}

class PasswordResetException implements Exception {
  PasswordResetException(this.message);

  final String message;
}

class PasswordException implements Exception {
  PasswordException(this.message);

  final String message;
}

enum OtpMethod { email, mobile }

class RestServiceConfig {
  RestServiceConfig({
    required this.authority,
    required this.weatherApiKey,
    String? pathPrefix,
  }) : pathPrefix = pathPrefix ?? '';

  final String authority;

  final String? pathPrefix;

  final String weatherApiKey;
}

class RestService {
  RestService({required this.config, required this.authService});

  RestServiceConfig config;

  AuthService authService;

  /// Authentication related calls
  Future<String?> _getCsrfToken() async {
    final response = await http.post(Uri.https(config.authority, "${config.pathPrefix}/csrf"));
    if (response.statusCode == HttpStatus.ok) return response.body;

    throw Exception();
  }

  Future<bool> applyRegistration({
    String? firstName,
    String? lastName,
    String? email,
    String? mobileNo,
    String? geoLocation,
    String? language,
    bool socialUser = false,
    String? socialLogin = "",
    String? socialToken,
  }) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (socialToken != null) headers.addAll({'socialToken': socialToken});

    final body = json.encode({
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "mobileNo": mobileNo,
      "geoLocation": geoLocation,
      "language": language,
      "socialUser": socialUser,
      "socialLogin": socialLogin,
    });

    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/external/register/apply"),
      headers: headers,
      body: body,
    );

    if (response.statusCode == HttpStatus.accepted) {
      return true;
    } else if (response.statusCode == HttpStatus.conflict) {
      throw ConflictedUserException();
    }

    throw Exception();
  }

  Future<bool> completeRegistration({String? authorizationCode, String? password}) async {
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/external/register/complete"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"authorizationCode": authorizationCode, "password": password}),
    );
    if (response.statusCode == HttpStatus.created) {
      return true;
    }

    throw Exception();
  }

  Future<bool> sendOtp(String value, {OtpMethod method = OtpMethod.email, String type = "rp"}) async {
    switch (method) {
      case OtpMethod.email:
        {
          String email0 = value.toLowerCase();
          final response =
              await http.post(Uri.https(config.authority, "${config.pathPrefix}/utility/sendotp/$email0/$type"));
          return response.statusCode == HttpStatus.accepted;
        }
      case OtpMethod.mobile:
        {
          final response =
              await http.post(Uri.https(config.authority, "${config.pathPrefix}/utility/login/sendotp/$value"));
          return response.statusCode == HttpStatus.accepted;
        }
    }
  }

  Future<String> verifyOtp(String email, String otp) async {
    String email0 = email.toLowerCase();
    final response =
        await http.post(Uri.https(config.authority, "${config.pathPrefix}/utility/verifyotp/$email0/$otp"));
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      var result = decodedJson["result"];
      return result ?? (throw Exception());
    }

    throw Exception();
  }

  Future<TokenResponse?> login({required String uName, required String pwd}) async {
    final csrfToken = await _getCsrfToken();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/login"),
      headers: {
        'X-CSRF-Token': csrfToken!,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "username": uName.toLowerCase(),
        "password": pwd,
      }),
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      final tokenResponse = TokenResponse.fromJson(decodedJson);
      if (tokenResponse.authSuccess) return tokenResponse;
      throw PasswordException(tokenResponse.message ?? "Error");
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  Future<TokenResponse?> socialLogin({
    required String username,
    required String socialLoginType,
    required String socialToken,
  }) async {
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/social/login"),
      headers: {
        'Content-Type': 'application/json',
        'socialToken': socialToken,
      },
      body: json.encode({
        "username": username.toLowerCase(),
        "socialLoginType": socialLoginType,
      }),
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return TokenResponse.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  Future<bool> deactivateUser() async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/${authData.identityId}/deactivate"),
      headers: {
        'Authorization': authData.bearerToken,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      return true;
    }

    throw Exception();
  }

  Future<bool> resetPasswordWithAuthorizationCode(String code, {required String password}) async {
    // final authData = await authDataProvider.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/resetpassword/$code"),
      headers: {
        // 'Authorization': authData.bearerToken,
        'Content-Type': 'application/json',
      },
      body: json.encode({"password": password}),
    );

    if (response.statusCode == HttpStatus.ok) {
      return true;
    } else if (response.statusCode == HttpStatus.badRequest) {
      final decodedJson = json.decode(response.body);
      throw PasswordResetException(decodedJson['result'] ?? "");
    }

    throw Exception();
  }

  /// End of authentication related calls

  Future<UserResponseDto?> getUserByEmail(String value) async {
    String email0 = value.toLowerCase();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/email/$email0"),
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return UserResponseDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  Future<UserResponseDto?> getUserByMobile(String value) async {
    // final authData = await authDataProvider.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/mobile/$value"),
      // headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return UserResponseDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  Future<UserResponseDto?> getUserByIamId(String value) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/iam/$value"),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return UserResponseDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  Future<bool> updateUser({
    String? firstName,
    String? lastName,
    String? email,
    String? mobileNo,
    String? profileImage,
    String? geoLocation,
  }) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
      body: json.encode({
        "identityId": authData.identityId,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "mobileNo": mobileNo,
        "profileImage": profileImage,
        "geoLocation": geoLocation,
        "authData.identityId": authData.identityId
      }),
    );
    return response.statusCode == HttpStatus.accepted;
  }

  Future<bool> updateDeviceToken(String token) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/device-token/$token"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
    );

    return response.statusCode == HttpStatus.ok;
  }

  Future<bool> updateDeviceLocation({required double latitude, required double longitude}) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(config.authority, "${config.pathPrefix}/identity/customer/location"),
      body: json.encode({"latitude": latitude, "longitude": longitude}),
      headers: {
        'Content-Type': 'application/json',
        'user-iam-id': authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );

    return response.statusCode == HttpStatus.accepted;
  }

  Future<bool> initUpdateMobile(String mobileNumber) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/mobile/init/$mobileNumber"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
    );

    if (response.statusCode == HttpStatus.conflict) {
      throw ConflictedUserException();
    }

    return response.statusCode == HttpStatus.accepted;
  }

  Future<bool> completeUpdateMobile(String mobileNumber, String authorizationCode) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(
        config.authority,
        "${config.pathPrefix}/identity/user/mobile/complete/$mobileNumber",
        {"authorizationCode": authorizationCode},
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
    );
    return response.statusCode == HttpStatus.accepted;
  }

  /// Builder

  Future<List<BuilderDto>> getAllBuilders() async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/builder/all"),
      headers: {
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((data) => BuilderDto.fromJson(data)).toList();
    }

    throw Exception();
  }

  Future<List<BuilderDto>> getBuildersByCurrentLocation({int pageNo = 0, int pageSize = 1000}) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/builder/all/paginated", {
        "pageNo": pageNo.toString(),
        "pageSize": pageSize.toString()
        // "search": "",
        // "jobType": "",
      }),
      headers: {
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson['builders'] ?? []).map<BuilderDto>((data) => BuilderDto.fromJson(data)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return <BuilderDto>[];
    }

    throw Exception();
  }

  Future<BuilderDto> getBuilderByMobile(String mobile) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/builder/mobile/$mobile"),
      headers: {'Authorization': authData.bearerToken},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return BuilderDto.fromJson(decodedJson);
    }

    throw Exception();
  }

  Future<BuilderDto> getBuilderByNic(String nic) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/builder/nic/$nic"),
      headers: {'Authorization': authData.bearerToken},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return BuilderDto.fromJson(decodedJson);
    }

    throw Exception();
  }

  /// BOQ

  Future<List<BoqConfigDto>> getBoqConfig({int pageNo = 0, int pageSize = 100}) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/boqs/", {
        "pageNo": pageNo.toString(),
        "pageSize": pageSize.toString(),
      }),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson["boqList"] as List).map((data) => BoqConfigDto.fromJson(data)).toList();
    }

    throw Exception();
  }

  Future<BoqDto?> saveBoq({
    required String boqName,
    required Map<String, dynamic> data,
    bool shouldSendEmail = false,
  }) async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/boqs/users/estimations/", {
        "emailNotificationEnabled": shouldSendEmail.toString(),
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
      body: json.encode({
        "data": json.encode(data),
        "name": boqName,
      }),
    );

    if (response.statusCode == HttpStatus.accepted) {
      return BoqDto.fromJson(json.decode(utf8.decode(response.bodyBytes, allowMalformed: true)));
    } else if (response.statusCode == HttpStatus.conflict) {
      throw DuplicateBoqEstimateException();
    }

    throw Exception();
  }

  /// Generate estimate PDF
  /// [id] BOQ id
  Future<String?> generateBoqEstimationDocument({required int id, bool shouldSendEmail = false}) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/boqs/estimation/export/$id", {
        "emailNotificationEnabled": shouldSendEmail.toString(),
      }),
      headers: {
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
      return decodedJson['result'];
    }

    return null;
  }

  Future deleteBoq(int id) async {
    final authData = await authService.getData();
    final response = await http.delete(
      Uri.https(config.authority, "${config.pathPrefix}/boqs/users/estimations/$id"),
      headers: {
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
    );

    return (response.statusCode == HttpStatus.ok);
  }

  Future<List<BoqDto>> getAllEstimations({int pageNo = 0, int pageSize = 100}) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/boqs/users/estimations/", {
        "pageNo": pageNo.toString(),
        "pageSize": pageSize.toString(),
      }),
      headers: {
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
      return (decodedJson['boqEstimationList'] as List).map((data) => BoqDto.fromJson(data)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception();
  }

  Future<WeatherInfoDto?> getWeatherInfo(double lat, double lon) async {
    final response = await http.get(
      Uri.parse("https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=${config.weatherApiKey}"),
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return WeatherInfoDto.fromJson(decodedJson);
    }

    return null;
  }

  /// Notification

  Future<List<NotificationDto>> getAllNotifications({int pageNo = 0, int pageSize = 100}) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/notification/push", {
        "pageNo": pageNo.toString(),
        "pageSize": pageSize.toString(),
      }),
      headers: {
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
      return (decodedJson as List).map((data) => NotificationDto.fromJson(data)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception();
  }

  Future<bool> markNotificationAsRead({required int id}) async {
    final authData = await authService.getData();
    final response = await http.patch(
      Uri.https(config.authority, ""),
      headers: {
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
    );
    return response.statusCode == HttpStatus.ok;
  }

  /// Main Banner

  Future<List<BannerItemDto>> getAllBannerItems({int pageNo = 0, int pageSize = 100}) async {
    // permits: ['toGetAllBannerItems']
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/mdm/content"),
      headers: {
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
      return (decodedJson as List)
          .map((data) => BannerItemDto.fromJson(data))
          .where((data) => data.contentType == "BANNER")
          .toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception();
  }

  /// Complaint

  Future createComplaint({
    required String name,
    required String businessName,
    required String contactNumber,
    required String location,
    required String description,
    required List<String> imageUrls,
    required int? productId,
    required int? productCategoryId,
    required int? complaintTypeId,
  }) async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/complaint"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
      body: json.encode({
        "name": name,
        "businessName": businessName,
        "contactNumber": contactNumber,
        "location": location,
        "description": description,
        "imageUrls": imageUrls,
        "productId": productId,
        "productCategoryId": productCategoryId,
        "complaintTypeId": complaintTypeId,
      }),
    );

    /// TODO: handle remaining exceptions
    if (response.statusCode == HttpStatus.accepted) {
      return true;
    }

    throw Exception();
  }

  Future<List<ComplaintDto>> getAllComplaints({int pageNo = 0, int pageSize = 100}) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/complaint/customer-complaints", {
        "pageNo": pageNo.toString(),
        "pageSize": pageSize.toString(),
      }),
      headers: {
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson['complaintList'] as List).map((data) => ComplaintDto.fromJson(data)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception();
  }

  Future<List<ComplaintTypeDto>?> getAllComplaintTypes({int pageNo = 0, int pageSize = 100}) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/complaint/type", {
        "pageNo": pageNo.toString(),
        "pageSize": pageSize.toString(),
      }),
      headers: {'Authorization': authData.bearerToken},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson['complaintTypeList'] as List).map((data) => ComplaintTypeDto.fromJson(data)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception();
  }

  Future<List<ComplaintProductCategoryDto>?> getAllComplaintProductCategories(
      {int pageNo = 0, int pageSize = 100}) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/product/category", {
        "pageNo": pageNo.toString(),
        "pageSize": pageSize.toString(),
      }),
      headers: {'Authorization': authData.bearerToken},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson['productCategoryList'] as List)
          .map((data) => ComplaintProductCategoryDto.fromJson(data))
          .toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception();
  }

  Future<List<ComplaintProductDto>?> getAllProductsByCategory({
    required int id,
    int pageNo = 0,
    int pageSize = 100,
  }) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/complaint/product/category", {
        "categoryId": "$id",
        "pageNo": pageNo.toString(),
        "pageSize": pageSize.toString(),
      }),
      headers: {'Authorization': authData.bearerToken},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson['complaintProductList'] as List).map((data) => ComplaintProductDto.fromJson(data)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception();
  }

  /// Job

  Future<bool> createJob({
    required String title,
    required String jobType,
    required String location,
    required String jobDescription,
    required String customerEmail,
    bool? isPrivate = false,
    String? image,
  }) async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/jobs"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
      body: json.encode({
        "jobTitle": title,
        "jobType": jobType,
        "location": location,
        "isPrivate": isPrivate,
        "jobDescription": jobDescription,
        "customerEmail": customerEmail,
        "image": image,
      }),
    );

    return response.statusCode == HttpStatus.accepted;
  }

  Future<List<JobDto>?> getAllMyJobs(String email, {int pageNo = 0, int pageSize = 100}) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/jobs/$email", {
        "pageNo": pageNo.toString(),
        "pageSize": pageSize.toString(),
      }),
      headers: {
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((data) => JobDto.fromJson(data)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception();
  }

  Future<List<JobTypeDto>> getAllJobTypes() async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/mdm/jobtype"),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((data) => JobTypeDto.fromJson(data)).toList();
    }

    throw Exception();
  }

  Future markJobAsCompleted(int id) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(config.authority, "${config.pathPrefix}/jobs/customer/markCompleted/$id"),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) return;
    throw Exception();
  }

  Future deleteJob(int id) async {
    final authData = await authService.getData();
    final response = await http.delete(
      Uri.https(config.authority, "${config.pathPrefix}/jobs/customer/$id"),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) return;
    throw Exception();
  }

  Future rateJob(int id, double rating) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(
        config.authority,
        "${config.pathPrefix}/jobs/rate",
        {"jobId": id.toString(), "rating": rating.toInt().toString()},
      ),
      headers: {'Authorization': authData.bearerToken},
    );

    if (response.statusCode == HttpStatus.ok) return;
    throw Exception();
  }

  Future acceptJobRequest(int id) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(
        config.authority,
        "${config.pathPrefix}/jobs/customer/decide",
        {"requestId": id.toString(), "isAccepted": "true"},
      ),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) return;
    throw Exception();
  }

  Future rejectJobRequest(int id) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(
        config.authority,
        "${config.pathPrefix}/jobs/customer/decide",
        {"requestId": id.toString(), "isAccepted": "false"},
      ),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) return;
    throw Exception();
  }

  Future<List<JobRequestDto>> getAllJobRequests(int id) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(
        config.authority,
        "${config.pathPrefix}/jobs/customer/requests",
        {"jobId": id.toString()},
      ),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((data) => JobRequestDto.fromJson(data)).toList();
    }
    return [];
  }

  Future assignJob({
    required int builderId,
    required String title,
    required String jobType,
    required String location,
    required String jobDescription,
    required String customerEmail,
    String? image,
  }) async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/jobs"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
      body: json.encode({
        "assignedBuilderId": builderId,
        "jobTitle": title,
        "jobType": jobType,
        "location": location,
        "isPrivate": true,
        "jobDescription": jobDescription,
        "customerEmail": customerEmail,
        "image": image,
        "status": "PENDING",
      }),
    );

    return response.statusCode == HttpStatus.ok;
  }

  /// Technical Assistance

  Future<List<TechnicalAssistanceDto>> getAllTechnicalAssistanceAssets() async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/technical-assistance"),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((data) => TechnicalAssistanceDto.fromJson(data)).toList();
    }

    throw Exception();
  }

  /// E-commerce

  /// [id] Product id
  Future updateTimeStamp(int id) async {
    final authData = await authService.getData();
    final response = await http.patch(
      Uri.https(config.authority, "${config.pathPrefix}/product/update-timestamp", {"id": id.toString()}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
    );

    return response.statusCode == HttpStatus.ok;
  }

  Future<List<ProductCategoryDto>> getAllProductCategories({int pageNo = 0, int pageSize = 100}) async {
    // permits: ['toGetAllProductCategories']
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/product/category", {
        "pageNo": pageNo.toString(),
        "pageSize": pageSize.toString(),
      }),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson["productCategoryList"] as List).map((data) => ProductCategoryDto.fromJson(data)).toList();
    }

    return [];
  }

  Future<List<ProductDto>> getProductsByCategory(int id) async {
    // permits: ['toGetProductsByCategory']
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/product/filter", {"categoryId": id.toString()}),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson["productList"] as List).map((data) => ProductDto.fromJson(data)).toList();
    }

    return [];
  }

  Future<List<ProductDto>> getAllRecentlyViewedProducts() async {
    // permits: ['toGetAllRecentlyViewedProducts']
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/product/recently-viewed"),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((data) => ProductDto.fromJson(data)).toList();
    }

    return [];
  }

  Future<List<ProductDto>> getAllMostSellingProducts() async {
    // permits: ['toGetAllMostSellingProducts']
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/product/most-selling"),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((data) => ProductDto.fromJson(data)).toList();
    }

    return [];
  }

  Future<List<ProductDto>> getSuggestedProducts() async {
    // permits: ['toGetSuggestedProducts']
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/suggestions", {"type": "PRODUCT"}),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((data) => ProductDto.fromJson(data["product"])).toList();
    }

    return [];
  }

  Future<List<ProductDto>> filterProducts() async {
    // permits: ['toFilterProducts']
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/product/filter"),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson["productList"] as List).map((data) => ProductDto.fromJson(data)).toList();
    }

    return [];
  }

  Future<FlashSaleResponseDto> getFlashSales() async {
    // permits: ['toGetFlashSales']
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/promotion/flashSale"),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body) as List;
      return FlashSaleResponseDto.fromJson(decodedJson.first);
    }

    throw Exception();
  }

  Future<bool> createOrder() async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/product/order"),
      headers: {
        'Authorization': authData.bearerToken,
        "user-iam-id": authData.identityId,
      },
    );
    return response.statusCode == HttpStatus.ok;
  }

  Future<CartResponseDto> getDraftedCart() async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/product/order/draft"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authData.bearerToken,
        "user-iam-id": authData.identityId,
      },
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return CartResponseDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.notFound) {
      throw DraftedCardNotFoundException();
    }

    throw Exception();
  }

  /// [orderItemId] Order id
  /// [productId] Product id
  /// [qty] Product quantity
  Future<OrderItemCreateResponseDto> addOrderItem(int orderItemId, int productId, int qty) async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/product/order-item", {"orderId": orderItemId.toString()}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authData.bearerToken,
        "user-iam-id": authData.identityId,
      },
      body: json.encode({
        "product": {
          "id": productId,
        },
        "quantity": qty,
      }),
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return OrderItemCreateResponseDto.fromJson(decodedJson);
    }

    throw Exception();
  }

  /// [orderItemId] Order item id
  /// [productId] Product id
  /// [qty] Product quantity
  Future<bool> updateOrderItem(int orderItemId, int productId, int qty) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(config.authority, "${config.pathPrefix}/product/order-item"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authData.bearerToken,
        "user-iam-id": authData.identityId,
      },
      body: json.encode({
        "id": orderItemId,
        "product": {
          "id": productId,
        },
        "quantity": qty,
      }),
    );

    return response.statusCode == HttpStatus.ok;
  }

  /// [id] Order item id
  Future<bool> deleteOrderItem(int id) async {
    final authData = await authService.getData();
    final response = await http.delete(
      Uri.https(config.authority, "${config.pathPrefix}/product/order-item", {"orderItemId": id.toString()}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authData.bearerToken,
        "user-iam-id": authData.identityId,
      },
    );

    return response.statusCode == HttpStatus.ok;
  }

  /// [id] Order id
  Future<CartResponseDto> getOrderSummary(int id, {String? address, String? latitude, String? longitude}) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/product/order-summary", {"orderId": id.toString()}),
      headers: {
        'Authorization': authData.bearerToken,
        "user-iam-id": authData.identityId,
        if (address != null) "Address": address,
        if (latitude != null) "Latitude": latitude,
        if (longitude != null) "Longitude": longitude,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return CartResponseDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.notFound) {
      throw DraftedCardNotFoundException();
    }

    throw Exception();
  }

  /// [id] order id
  Future<String> getPaymentSession(int id) async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/payments/init", {
        "userIamId": authData.identityId.toString(),
        "orderId": id.toString(),
      }),
      headers: {
        'Content-Type': ContentType.html.mimeType,
        'Authorization': authData.bearerToken,
        "user-iam-id": authData.identityId,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      return utf8.decode(response.bodyBytes);
    }

    throw Exception();
  }

  /// [ref] Reference number
  Future<bool> closePaymentSession(String ref) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(config.authority, "${config.pathPrefix}/payments/complete", {
        "referenceId": ref.toString(),
      }),
      headers: {
        'Content-Type': ContentType.html.mimeType,
        'Authorization': authData.bearerToken,
        "user-iam-id": authData.identityId,
      },
    );

    return response.statusCode == HttpStatus.ok;
  }

  Future<List<PromoCodeDto>> getAllPromoCodes() async {
    final authData = await authService.getData();
    Future<List> fetchAllDiscountRecords() async {
      final response = await http.get(
        Uri.https(config.authority, "${config.pathPrefix}/promotion/discount"),
        headers: {
          'Content-Type': "application/json",
          'Authorization': authData.bearerToken,
          "user-iam-id": authData.identityId,
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        var obj = json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
        return (obj as List);
      }

      throw Exception();
    }

    Future<List> fetchAllPromoCodeRecords() async {
      final response = await http.get(
        Uri.https(config.authority, "${config.pathPrefix}/promotion/promoCode"),
        headers: {
          'Content-Type': "application/json",
          'Authorization': authData.bearerToken,
          "user-iam-id": authData.identityId,
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        var obj = json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
        return (obj as List)
            .map((data) => {
                  "code": data["promoCode"],
                  "startDate": data["startDate"] != null ? DateTime.tryParse(data["startDate"]) : null,
                  "endDate": DateTime.tryParse(data["expiryDate"]),
                })
            .toList();
      }

      throw Exception();
    }

    late List<PromoCodeDto> codes;

    /// fetch all discount records, it contains products
    /// that assign to the promoCode.
    var discountRecords = await fetchAllDiscountRecords();
    codes = discountRecords.map((e) => PromoCodeDto.fromJson(e)).toList();

    /// fetch all promo code records, it contains startDate and expiryDate
    /// of the promoCode.
    var promoCodeRecords = await fetchAllPromoCodeRecords();

    /// Merge two list together by promoCode.
    for (var e0 in codes) {
      var sc = promoCodeRecords.where((e1) => e1["code"] == e0.promoCode);
      if (sc.isNotEmpty) {
        var fc = sc.first;
        e0 = e0
          ..startDate = fc["startDate"]
          ..endDate = fc["endDate"];
      }
    }

    return codes;
  }

  /// get all user applicable promotions
  Future<List<PromotionDto>> getAllApplicablePromotions() async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/product/applicable-promotion"),
      headers: {
        'Content-Type': "application/json",
        'Authorization': authData.bearerToken,
        "user-iam-id": authData.identityId,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((data) => PromotionDto.fromJson(data)).toList();
    }

    return [];
  }

  /// [id] order id
  /// [code] promo code
  Future<bool> applyPromoCode(int id, String code) async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/product/order/apply-promotion", {
        "orderId": id.toString(),
        "promoCode": code,
      }),
      headers: {
        'Content-Type': "application/json",
        'Authorization': authData.bearerToken,
        "user-iam-id": authData.identityId,
      },
    );

    return response.statusCode == HttpStatus.ok;
  }

  /// [id] order id
  /// [promoId] promotion id
  Future<bool> applyPromotion(int id, int promoId) async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/product/order/apply-promotion", {
        "orderId": id.toString(),
        "promotionId": promoId.toString(),
      }),
      headers: {
        'Content-Type': "application/json",
        'Authorization': authData.bearerToken,
        "user-iam-id": authData.identityId,
      },
    );

    return response.statusCode == HttpStatus.ok;
  }

  Future<String?> getReferral() async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/identity/users/referral-link"),
      headers: {
        'Content-Type': "application/json",
        'Authorization': authData.bearerToken,
        "user-iam-id": authData.identityId,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      print(response.body);
      return response.body;
    }

    return null;
  }

  /// DM

  Future<List<ConversationDto>> getConversations() async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/message/customer"),
      headers: {
        'Content-Type': "application/json",
        'Authorization': authData.bearerToken,
        "user-iam-id": authData.identityId,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((message) => ConversationDto.fromJson(message)).toList();
    }

    return [];
  }

  /// [id] Builder id
  Future<List<MessageDto>> getChatMessages(int id) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/message/customer/builder/$id"),
      headers: {
        'Content-Type': "application/json",
        'Authorization': authData.bearerToken,
        "user-iam-id": authData.identityId,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((message) => MessageDto.fromJson(message)).toList();
    }

    return [];
  }

  /// [id] Builder id
  /// [message] Message body
  Future<bool> sendMessage(int id, String message) async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/message/customer/send/$id"),
      headers: {
        'Content-Type': ContentType.json.mimeType,
        'Authorization': authData.bearerToken,
        "user-iam-id": authData.identityId,
      },
      body: json.encode({"message": message}),
    );
    return response.statusCode == HttpStatus.accepted;
  }

  /// [id] Builder id
  Future<bool> markAllAsRead(int id) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(config.authority, "${config.pathPrefix}/message/customer/read/$id"),
      headers: {
        'Authorization': authData.bearerToken,
        "user-iam-id": authData.identityId,
      },
    );
    return response.statusCode == HttpStatus.ok;
  }

  /// Util

  Future<String> getFullFilePath(String fileName) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/utility/files/$fileName"),
      headers: {
        'Authorization': authData.bearerToken,
        'user-iam-id': authData.identityId,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return decodedJson['result'];
    }

    throw Exception();
  }

  @Deprecated("No longer using the public bucket")
  Future<String?> uploadBase64EncodeAsyncPublic(String value) async {
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/utility/files/upload/public"),
      headers: {'Content-Type': "text/plain"},
      body: value,
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return decodedJson["result"];
    }

    throw Exception();
  }

  Future<String?> uploadBase64EncodeAsync(String value) async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/utility/files/upload"),
      headers: {
        'Authorization': authData.bearerToken,
        'Content-Type': "text/plain",
      },
      body: value,
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return decodedJson["result"];
    }

    throw Exception();
  }
}
