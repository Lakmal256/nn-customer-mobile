import 'dart:convert';

import 'package:intl/intl.dart';

class TokenResponse {
  String? token;
  String? refreshToken;
  String? identityId;
  UserResponseDto? user;
  bool authSuccess = false;
  bool passwordExpired = false;
  String? message;

  TokenResponse.fromJson(Map<String, dynamic> value)
      : identityId = value["loggedUser"]["identityId"],
        token = value["accessToken"],
        user = UserResponseDto.fromJson(value["loggedUser"]),
        refreshToken = value["refreshToken"],
        authSuccess = value["authSuccess"],
        passwordExpired = value["passwordExpired"],
        message = value["message"];
}

class UserResponseDto {
  int? id;
  String? identityId;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNo;
  bool? internal;
  bool? status;
  String? expiryDate;
  String? defaultLanguage;
  String? lastModifiedDate;
  String? sapEmployeeCode;
  String? geoLocation;
  String? profileImageUrl;
  String? profileImage;
  List<String> roles;

  UserResponseDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        identityId = value["identityId"],
        firstName = value["firstName"],
        lastName = value["lastName"],
        email = value["email"],
        mobileNo = value["mobileNo"],
        internal = value["internal"],
        status = value["status"],
        expiryDate = value["expiryDate"],
        defaultLanguage = value["defaultLanguage"],
        lastModifiedDate = value["lastModifiedDate"],
        sapEmployeeCode = value["sapEmployeeCode"],
        geoLocation = value["geoLocation"],
        profileImage = value["profileImage"],
        roles = List<String>.from(value["roles"].map((r0) => r0["roleType"])),
        profileImageUrl = value["displayProfileImageUrl"] ??

            /// Service currently not supporting any default image
            /// this is a public image service that provides a name based
            /// profile image
            "https://ui-avatars.com/api/?background=random&name=${value["firstName"]}+${value["lastName"]}";

  String get displayName => "$firstName $lastName".replaceAll(RegExp('\\s+'), ' ');
}

class BuilderDto {
  int id;
  String? firstName;
  String? secondName;
  String? lastName;
  String? nicNumber;
  String? contactNumber;
  String? availability;
  String? preferredLocation;
  String? jobType;
  String? jobDescription;
  String? officePhoneNo;
  String? businessRegNo;
  double? rating;
  String? profileImageUrl;
  double? currentLatitude;
  double? currentLongitude;
  String? distance;
  int? numberOfJobs;

  BuilderDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        rating = value["rating"],
        firstName = value["firstName"] ?? "",
        secondName = value["secondName"] ?? "",
        lastName = value["lastName"] ?? "",
        nicNumber = value["nicNumber"],
        contactNumber = value["contactNumber"],
        availability = value["availability"],
        preferredLocation = value["preferredLocation"],
        jobType = value["jobType"],
        jobDescription = value["jobDescription"],
        officePhoneNo = value["officePhoneNo"],
        businessRegNo = value["businessRegNo"],
        currentLatitude = value["currentLatitude"],
        currentLongitude = value["currentLongitude"],
        distance = value["distance"],
        numberOfJobs = value["noOfJobs"],
        // profileImageUrl = value["profileImageUrl"];
        profileImageUrl = value["displayProfileImageUrl"];

  String get displayName => "$firstName $lastName".replaceAll(RegExp('\\s+'), ' ');
  String get displayNameLong => "$firstName $secondName $lastName".replaceAll(RegExp('\\s+'), ' ');
}

class BoqConfigDto {
  String? name;
  String imageUrl;
  Map<String, dynamic>? data;

  BoqConfigDto.fromJson(Map<String, dynamic> value)
      : name = value['name'],
        // imageUrl = value["imageUrl"] ?? "",
        imageUrl = value["displayImageUrl"] ?? "",
        data = json.decode(value['data']);
}

class BoqDto {
  int? omsUserId;
  int? boqEstimationId;
  String? name;
  Map<String, dynamic>? data;
  String? createdDate;
  String? lastModifiedDate;

  BoqDto.fromJson(Map<String, dynamic> value)
      : omsUserId = value["omsUserId"],
        boqEstimationId = value["boqEstimationId"],
        name = value["name"],
        data = json.decode(value["data"]),
        createdDate = value["createdDate"],
        lastModifiedDate = value["lastModifiedDate"];
}

/// Complaint

class ComplaintDto {
  int? id;
  String? name;
  String? businessName;
  String? contactNumber;
  String? description;
  int? complaintTypeId;
  List<String>? complaintImageList;
  dynamic subCategory;
  int? assigneeId;
  String? complaintStatus;
  int? productId;
  int? productCategoryId;
  int? mainCategoryId;
  List<String>? emailList;
  String? createdDate;
  String? lastModifiedDate;
  String? location;

  ComplaintDto.fromJson(Map<String, dynamic> value)
      : id = value['id'],
        name = value['name'],
        businessName = value['businessName'],
        contactNumber = value['contactNumber'],
        description = value['description'],
        complaintTypeId = value['complaintTypeId'],
        // complaintImageList = List<String>.from(value['complaintImageList'] ?? []),
        complaintImageList = List<String>.from(value['displayComplaintImageUrlList'] ?? []),
        subCategory = value['subCategory'],
        assigneeId = value['assigneeId'],
        complaintStatus = value['complaintStatus'],
        productId = value['productId'],
        productCategoryId = value['productCategoryId'],
        mainCategoryId = value['mainCategoryId'],
        emailList = List<String>.from(value['emailList'] ?? []),
        createdDate = value['createdDate'],
        lastModifiedDate = value['lastModifiedDate'],
        location = value['location'];

  static final dateFormat = DateFormat("MMM d yyyy");
  String? get dateMMMdyyyy => createdDate != null ? (dateFormat.format(DateTime.parse(createdDate!))) : createdDate;
  String? get lastModifiedDateMMMdyyyy =>
      lastModifiedDate != null ? (dateFormat.format(DateTime.parse(lastModifiedDate!))) : lastModifiedDate;
}

class ComplaintTypeDto {
  int? id;
  String? name;

  @override
  ComplaintTypeDto.fromJson(Map<String, dynamic> value)
      : id = value['id'],
        name = value['name'];
}

class ComplaintProductCategoryDto {
  int? id;
  String? name;

  ComplaintProductCategoryDto.fromJson(Map<String, dynamic> value)
      : id = value['id'],
        name = value['name'];
}

class ComplaintProductDto {
  int? id;
  String? name;

  ComplaintProductDto.fromJson(Map<String, dynamic> value)
      : id = value['id'],
        name = value['name'];
}

/// End Complaint
/// Job

enum JobAccessibility {
  private,
  public,
}

enum JobStatus {
  open,
  pending,
  inProgress,
  rejected,
  completed,
  unknown,
}

class JobDto {
  int? id;
  String? title;
  String? jobType;
  String? location;
  String? jobDescription;
  String? image;
  String? jobTypeImage;
  String? customerEmail;
  String? sStatus;
  JobStatus status;
  String? lastModifiedDate;
  bool isPrivate;
  bool isDeleted;
  DateTime? dLastModifiedDate;
  BuilderDto? assignedBuilder;

  JobDto.fromJson(Map<String, dynamic> value)
      : id = value['id'],
        title = value['jobTitle'],
        jobType = value['jobType'],
        location = value['location'],
        assignedBuilder = value['assignedBuilder'] != null ? BuilderDto.fromJson(value['assignedBuilder']) : null,
        jobDescription = value['jobDescription'],
        image = value['image'],
        jobTypeImage = value['displayJobTypeImage'],
        customerEmail = value['customerEmail'],
        lastModifiedDate = value['lastModifiedDate'],
        dLastModifiedDate = DateTime.parse(value['lastModifiedDate']),
        isPrivate = value['isPrivate'],
        isDeleted = value['isDeleted'],
        status = _stringToJobStatus(value['status']),
        sStatus = value['status'];

  static JobStatus _stringToJobStatus(String? value) {
    switch (value) {
      case "OPEN":
        return JobStatus.open;
      case "PENDING":
        return JobStatus.pending;
      case "IN_PROGRESS":
        return JobStatus.inProgress;
      case "REJECTED":
        return JobStatus.rejected;
      case "COMPLETED":
        return JobStatus.completed;
      default:
        return JobStatus.unknown;
    }
  }

  String get justDate => DateFormat("d/MM/yyyy").format(dLastModifiedDate!);
  JobAccessibility get accessibility => isPrivate ? JobAccessibility.private : JobAccessibility.public;
}

class JobTypeDto {
  int? id;
  String? jobTypeName;
  String? description;
  String? jobTypeImage;
  String? jobTypeImageUrl;

  JobTypeDto.empty();

  JobTypeDto.fromJson(Map<String, dynamic> value)
      : id = value['id'],
        jobTypeName = value['jobTypeName'],
        description = value['description'],
        jobTypeImage = value['jobTypeImage'],
        // jobTypeImageUrl = value['jobTypeImageUrl'];
        jobTypeImageUrl = value['displayJobTypeImageUrl'];
}

class JobRequestDto {
  int? id;
  BuilderDto? builder;

  JobRequestDto.empty();

  JobRequestDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        builder = BuilderDto.fromJson(value["builder"]);
}

/// End Job
/// TechnicalAssistance

enum TechnicalAssistanceType { media, article }

class TechnicalAssistanceDto {
  int? id;
  String? title;
  String? text;
  String mediaUrl;
  String imageUrl;
  final String _type;

  TechnicalAssistanceDto.fromJson(Map<String, dynamic> value)
      : id = value['id'],
        _type = value['type'],
        title = value['title'],
        text = value['text'],
        // mediaUrl = value['mediaUrl'] ?? "",
        mediaUrl = value['displayMediaUrl'] ?? "",
        // imageUrl = value['imageUrl'] ?? "";
        imageUrl = value['displayImageUrl'] ?? "";

  static _stringTypeToType(String value) {
    switch (value) {
      case "MEDIA":
        return TechnicalAssistanceType.media;
      case "ARTICLE":
        return TechnicalAssistanceType.article;
    }
  }

  TechnicalAssistanceType get type => _stringTypeToType(_type);
}

/// e-commerce

class ProductDto {
  int? id;
  double? price;
  String? applications;
  String? compatibility;
  String? createdDate;
  String? description;
  String? detailsFile;
  String? factFile;
  String? lastModifiedDate;
  String? mobileImage;
  String? name;
  String? productDescription;
  String? properties;
  String? status;
  String? webImage;
  String? detailsFilePath;
  ProductCategoryDto? productCategory;
  ProductCategoryDto? productSubCategory;

  ProductDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        name = value["name"],
        price = value["price"],
        applications = value["applications"],
        compatibility = value["compatibility"],
        createdDate = value["createdDate"],
        description = value["description"],
        detailsFile = value["detailsFile"],
        factFile = value["factFile"],
        lastModifiedDate = value["lastModifiedDate"],
        detailsFilePath = value["displayDetailsFileUrl"],
        mobileImage = value["displayMobileImageUrl"],
        productDescription = value["productDescription"],
        properties = value["properties"],
        status = value["status"],
        webImage = value["displayWebImageUrl"],
        productCategory = _tryJsonToProductCategory(value['productCategory']),
        productSubCategory = _tryJsonToProductCategory(value["productSubCategory"]);

  static ProductCategoryDto? _tryJsonToProductCategory(Map<String, dynamic>? value) =>
      value != null ? ProductCategoryDto.fromJson(value) : null;

  @override
  bool operator ==(Object other) => other is ProductDto && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ProductCategoryDto {
  int id;
  String? createdDate;
  String? imageUrl;
  String? lastModifiedDate;
  String? name;

  ProductCategoryDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        createdDate = value["createdDate"],
        // imageUrl = value["imageUrl"] ?? "",
        imageUrl = value["displayImageUrl"] ?? "",
        lastModifiedDate = value["lastModifiedDate"],
        name = value["name"];
}

class RegionalPricesDto {
  double? price;
  String? region;

  RegionalPricesDto.fromJson(Map<String, dynamic> value)
      : price = value["price"],
        region = value["region"];
}

class OrderItemDto {
  int id;
  int quantity;
  double flashSaleAmount;
  int freeQuantity;
  ProductDto product;

  OrderItemDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        quantity = value["quantity"],
        flashSaleAmount = value["flashSaleAmount"].toDouble() ?? 0.0,
        freeQuantity = value["freeQuantity"] ?? 0,
        product = ProductDto.fromJson(value["product"]);

  double get itemPriceWithDiscount => (product.price ?? 0) - flashSaleAmount;
  double get totalPriceWithDiscount => itemPriceWithDiscount * quantity;
  double get totalPrice => (product.price ?? 0) * quantity;
}

class HandlingChargeDto {
  int id;
  double price;
  HandlingChargeDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        price = value["price"] ?? 0.0;
}

class HardwareOwnerDto {
  int id;
  HardwareOwnerDto.fromJson(Map<String, dynamic> value) : id = value["id"];
}

enum PromotionType {
  code,
  generalDiscount,
  flashSale,
  freeShipping,
  bundles,
  limitedTime,
}

class CartResponseDto {
  int? id;
  double itemTotal;
  double totalPayment;
  double promotionTotal;
  double bundleProductTotal;
  double generalPromotionTotal;
  double discountTotal;
  double limitedTimeOfferTotal;
  double deliveryCharge;
  HandlingChargeDto? handlingCharge;
  bool isAcceptedByHardwareOwner;
  bool isFreeShippingEligible;
  HardwareOwnerDto? hardwareOwner;
  List<OrderItemDto> products;

  CartResponseDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        itemTotal = value["itemTotal"]?.toDouble() ?? 0.0,
        totalPayment = value["totalPayment"]?.toDouble() ?? 0.0,
        promotionTotal = value["promotionTotal"]?.toDouble() ?? 0.0,
        bundleProductTotal = value["bundleProductTotal"]?.toDouble() ?? 0.0,
        generalPromotionTotal = value["generalPromotionTotal"]?.toDouble() ?? 0.0,
        discountTotal = value["discountTotal"]?.toDouble() ?? 0.0,
        limitedTimeOfferTotal = value["limitedTimeOfferTotal"]?.toDouble() ?? 0.0,
        deliveryCharge = value["deliveryCharge"]?.toDouble() ?? 0.0,
        isAcceptedByHardwareOwner = value["isAcceptedByHardwareOwner"] ?? false,
        isFreeShippingEligible = value["isFreeShippingEligible"] ?? false,
        hardwareOwner = tryJsonToHardwareOwnerDto(value["hardwareOwner"]),
        handlingCharge = tryJsonToHandlingChargeDto(value["handlingCharge"]),
        products = (value["orderItems"] ?? []).map<OrderItemDto>((item) => OrderItemDto.fromJson(item)).toList();

  double get dHandlingCharge => (itemTotal / 100.0) * handlingCharge!.price;
  double get dDeliveryCharge => deliveryCharge;
  List<PromotionType> get appliedPromotionTypes => [
        if (discountTotal > 0.0) PromotionType.code,
        if (generalPromotionTotal > 0.0) PromotionType.generalDiscount,
        if (limitedTimeOfferTotal > 0.0) PromotionType.limitedTime,
        if (bundleProductTotal > 0.0) PromotionType.bundles
      ];

  static HardwareOwnerDto? tryJsonToHardwareOwnerDto(Map<String, dynamic>? value) =>
      value != null ? HardwareOwnerDto.fromJson(value) : null;

  static HandlingChargeDto? tryJsonToHandlingChargeDto(Map<String, dynamic>? value) =>
      value != null ? HandlingChargeDto.fromJson(value) : null;
}

class OrderItemCreateResponseDto {
  int? id;

  OrderItemCreateResponseDto.fromJson(Map<String, dynamic> value) : id = value["id"];
}

class FlashSaleResponseDto {
  int? id;
  String? title;
  double percentageValue;
  DateTime? expiryDate;
  List<ProductDto> products;

  FlashSaleResponseDto.empty()
      : percentageValue = 0.0,
        products = [];

  FlashSaleResponseDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        title = value["title"],
        expiryDate = DateTime.tryParse(value["expiryDate"] ?? ""),
        percentageValue = value["percentageValue"],
        products = (value["products"] ?? []).map<ProductDto>((item) => ProductDto.fromJson(item)).toList();
}

class PromoCodeDto {
  int? id;
  String? promoCode;
  DateTime? startDate;
  DateTime? endDate;
  String? status;
  List<ProductDto> products;

  PromoCodeDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        promoCode = value["promoCode"],
        startDate = DateTime.tryParse(value["startDate"] ?? ""),
        endDate = DateTime.tryParse(value["expiryDate"] ?? ""),
        status = value["status"],
        products = (value["products"] ?? []).map<ProductDto>((data) => ProductDto.fromJson(data)).toList();

  bool get isActive => status == "ACTIVE";
}

class PromotionDto {
  int? id;
  DateTime? startDate;
  DateTime? endDate;
  String? status;
  double? percentageValue;
  double? threshold;
  PromotionType type;

  PromotionDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        startDate = DateTime.tryParse(value["startDate"] ?? ""),
        endDate = DateTime.tryParse(value["expiryDate"] ?? ""),
        percentageValue = value["percentageValue"],
        threshold = value["threshold"],
        status = value["status"],
        type = switch (value["mainPromotionType"]) {
          "FREE_SHIPPING" => PromotionType.freeShipping,
          "LIMITED_TIME_OFFER" => PromotionType.limitedTime,
          "PRODUCT_BUNDLE" => PromotionType.bundles,
          "PROMOTION" => PromotionType.generalDiscount,
          _ => PromotionType.code
        };

  bool get isActive => status == "ACTIVE";
}

class MessageAuthor {
  int? id;
  String? identityId;
  String? firstName;
  String? lastName;
  String? profileImageUrl;

  MessageAuthor.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        identityId = value["identityId"],
        firstName = value["firstName"],
        lastName = value["lastName"],
        // profileImageUrl = value["profileImageUrl"];
        profileImageUrl = value["displayProfileImageUrl"];

  String get fullName => "$firstName $lastName";
}

class MessageDto {
  int? id;
  String? message;
  DateTime? dateTime;
  bool isSeen;
  bool isFromACustomer;

  /// Other end of the conversation
  MessageAuthor? interlocutor;

  MessageDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        message = value["message"],
        dateTime = DateTime.tryParse(value["dataTime"]),
        isSeen = value["seenMessage"] ?? false,
        interlocutor = value['builder'] != null ? MessageAuthor.fromJson(value['builder']) : null,
        isFromACustomer = value["fromCustomer"];

  static final dateFormat = DateFormat("d/MM/yyyy");
  String get sDate => dateFormat.format(dateTime!);
  Duration get timeDifference => DateTime.now().difference(dateTime!);
  String? get relativeTime => DateFormat.Hm().format(DateTime.now().subtract(timeDifference));
}

/// Not related to [MessageDto]
class ConversationMessageDto {
  int? id;
  String? message;
  DateTime? dateTime;
  int? interlocutorId;
  String? interlocutorName;
  String? interlocutorImageUrl;

  ConversationMessageDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        message = value["message"],
        dateTime = DateTime.tryParse(value["lastModifiedDate"]),
        interlocutorId = value["builder"]["id"],
        interlocutorName = "${value["builder"]["firstName"]} ${value["builder"]["lastName"]}",
        // interlocutorImageUrl = value["builder"]["profileImageUrl"];
        interlocutorImageUrl = value["builder"]["displayProfileImageUrl"];

  static final dateFormat = DateFormat("d/MM/yyyy");
  String get sDate => dateFormat.format(dateTime!);
  Duration get timeDifference => DateTime.now().difference(dateTime!);
  String? get relativeTime => DateFormat.Hm().format(DateTime.now().subtract(timeDifference));
}

class ConversationDto {
  int? id;
  ConversationMessageDto? lastMessage;
  int unseenMessageCount;

  ConversationDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        lastMessage = ConversationMessageDto.fromJson(value["latestMessage"]),
        unseenMessageCount = value["noOfUnreadMessages"] ?? 0;
}

class WeatherInfoDto {
  double? ambientTemperature;
  double? relativeHumidity;
  double? windVelocity;

  WeatherInfoDto.fromJson(Map<String, dynamic> value)
      : ambientTemperature = value["main"]["temp"] ?? 0.0,
        relativeHumidity = (value["main"]["humidity"].toDouble()) ?? 0.0,
        windVelocity = value["wind"]["speed"] ?? 0.0;
}

class NotificationDto {
  int id;
  String? status;
  String? topic;
  String? title;
  String? body;
  bool read;

  NotificationDto.fromJson(Map<String, dynamic> value)
      : id = 0,
        status = value["main"],
        topic = value["topic"],
        title = value["title"],
        body = value["body"],
        read = value["read"];
}

class BannerItemDto {
  int id;
  String? contentGuid;
  String? contentName;
  String? contentType;
  String? createdDate;
  String? lastModifiedDate;
  String? status;
  bool? featured;
  List<BannerMediaItemDto> mediaItems;

  BannerItemDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        contentGuid = value["contentGuid"],
        contentName = value["contentName"],
        contentType = value["contentType"],
        createdDate = value["createdDate"],
        lastModifiedDate = value["lastModifiedDate"],
        featured = value["featured"],
        status = value["status"],
        mediaItems =
            (value["mediaList"] ?? []).map<BannerMediaItemDto>((data) => BannerMediaItemDto.fromJson(data)).toList();

  List<BannerMediaItemDto> get mobileMedia => mediaItems.where((item) => item.mediaType == "IMAGE_MOBILE").toList();
}

class BannerMediaItemDto {
  String? mId;
  String? mediaType;
  String? mediaUrl;

  BannerMediaItemDto.fromJson(Map<String, dynamic> value)
      : mId = value["mediaId"],
        mediaType = value["mediaType"],
        // mediaUrl = value["mediaUrl"];
        mediaUrl = value["displayMediaUrl"];
}
