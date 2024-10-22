import 'package:flutter/material.dart';
import 'package:nawa_niwasa/service/service.dart';

class BannerItemHandler extends ChangeNotifier {
  BannerItemHandler({required this.restService}) : items = List.empty(growable: true);

  final RestService restService;

  List<BannerItemDto> items;

  Future sync() async {
    items = await restService.getAllBannerItems();
    notifyListeners();
  }

  int get count => items.length;
}
