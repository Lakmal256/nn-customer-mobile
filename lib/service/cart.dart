import 'dart:async';

import 'package:flutter/foundation.dart';

import 'service.dart';

enum CartStatus { idle, busy }

class DraftCartHandler extends ChangeNotifier {
  DraftCartHandler({required this.restService});

  final RestService restService;

  CartResponseDto? remoteCart;

  CartStatus status = CartStatus.idle;

  Object? error;

  Timer? _debounceTimer;
  Duration debounceDuration = const Duration(milliseconds: 500);

  _callDebounce(Function() action) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, action);
  }

  _call(Future Function() action) async {
    try {
      if (remoteCart == null) throw Exception();
      status = CartStatus.busy;
      notifyListeners();
      await action();
    } catch (error) {
      this.error = error;
    } finally {
      status = CartStatus.idle;
      notifyListeners();
    }
  }

  Future sync() async {
    remoteCart = await restService.getDraftedCart();
    notifyListeners();
  }

  Future addItem(ProductDto item, {int qty = 1}) async {
    _clearErrors();
    _call(() async {
      await restService.addOrderItem(remoteCart!.id!, item.id!, qty);
      await sync();
    });
  }

  /// Helper method to increase or decrease item quantity
  Future updateItemQuantity(ProductDto item, int Function(OrderItemDto) fn) async {
    _clearErrors();
    _call(() async {
      var orderItem = remoteCart!.products.firstWhere((element) => element.product == item);
      await setItemQuantity(orderItem, fn(orderItem));
    });
  }

  setItemQuantityDebounced(OrderItemDto item, int qty) {
    /// Buffer set first and then after the duration, cart sync with remote cart
    item.quantity = qty;
    notifyListeners();
    _callDebounce(() => setItemQuantity(item, qty));
  }

  Future setItemQuantity(OrderItemDto item, int qty) async {
    _clearErrors();
    _call(() async {
      await restService.updateOrderItem(item.id, item.product.id!, qty);
      await sync();
    });
  }

  Future removeItem(OrderItemDto item) async {
    _clearErrors();
    _call(() async {
      await restService.deleteOrderItem(item.id);
      await sync();
    });
  }

  Future clear() async {
    _clearErrors();
    _call(() async {
      for (var element in remoteCart!.products) {
        await restService.deleteOrderItem(element.id);
      }
      await sync();
    });
  }

  _clearErrors() => error = null;

  List<OrderItemDto> get items => remoteCart?.products ?? [];

  double get total => items.fold(0.0, (previousValue, element) => previousValue + element.totalPriceWithDiscount);

  bool get hasError => error != null;
}
