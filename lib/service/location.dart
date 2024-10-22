import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class UserLocationData {
  String? address;
  final double latitude;
  final double longitude;

  UserLocationData({required this.latitude, required this.longitude});
}

class UserLocationService extends ValueNotifier<UserLocationData?>{
  UserLocationService(UserLocationData? initialData): super(initialData);
}

class ReverseGeocodeAddressResponse {
  ReverseGeocodeAddressResponse(this.result);

  final Map<String, dynamic> result;

  String get formattedAddress => (result["results"] as List).first["formatted_address"];
}

class ReverseGeocodingService {
  final String apiKey;

  ReverseGeocodingService({required this.apiKey});

  /// [coordinates] Ex: 40.714224,-73.961452
  Future<ReverseGeocodeAddressResponse> getAddress(String coordinates) async {
    var response = await http.get(Uri.https("maps.googleapis.com", "/maps/api/geocode/json", {
      "latlng": coordinates,
      "key": apiKey,
    }));
    if (response.statusCode == HttpStatus.ok) {
      return ReverseGeocodeAddressResponse(json.decode(response.body));
    }

    throw Exception();
  }
}

class DeviceLocationService {
  final Location _location = Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  DeviceLocationService.init()
      : _serviceEnabled = false,
        _permissionGranted = PermissionStatus.denied;

  Future<bool> requestServicePermission() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
    }

    return _serviceEnabled;
  }

  Future<bool> requestLocationPermission() async {
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
    }

    return _permissionGranted == PermissionStatus.granted;
  }

  bool get permitted => _serviceEnabled && _permissionGranted == PermissionStatus.granted;
  Future<LocationData> get location => _location.getLocation();
}
