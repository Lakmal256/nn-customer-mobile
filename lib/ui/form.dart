import 'package:flutter/material.dart';

abstract class FormValue {
  Map<String, String> errors = {};
  Map<String, dynamic>? meta;

  FormValue({this.meta});

  String? getError(String key) => errors[key];
}

abstract class FormController<T> extends ValueNotifier<T> {
  FormController({required T initialValue, this.isValid = false}) : super(initialValue);

  bool isValid;

  void setValue(T value) {
    this.value = value;
    notifyListeners();
  }

  Future<bool> validate() async {
    throw UnimplementedError();
  }
}

abstract class StatefulFormWidget<T> extends StatefulWidget {
  const StatefulFormWidget({Key? key, required this.controller}) : super(key: key);

  final FormController<T> controller;
}

/// Mixin to handle ValueNotifier event listeners properly.
mixin FormMixin<T extends StatefulFormWidget> on State<T> {
  @override
  void initState() {
    init();
    widget.controller.addListener(handleFormControllerEvent);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(handleFormControllerEvent);
      widget.controller.addListener(handleFormControllerEvent);
    }
    super.didUpdateWidget(oldWidget);
  }

  @protected
  void init() {}

  @protected
  void handleFormControllerEvent() {}

  @override
  void dispose() {
    widget.controller.removeListener(handleFormControllerEvent);
    super.dispose();
  }
}
