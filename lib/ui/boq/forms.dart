import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n.dart';
import '../../locator.dart';
import '../ui.dart';
import 'calculation.dart';

abstract class EstFormController<T> extends FormController<T> {
  String title;
  Map<String, dynamic> extra;

  EstFormController({
    required super.initialValue,
    required this.title,
    Map<String, dynamic>? extra,
  }) : extra = extra ?? {};

  @override
  Future<bool> validate() {
    /// EstFormController should not use an async validator
    throw UnimplementedError();
  }

  bool validateSync();

  @override
  bool get isValid => validateSync();
}

/// Concrete estimation form
Map<String, dynamic> concreteTypeOptions = {
  "grade15": {
    "code": ConcreteType.grade15,
    "displayName": "Grade 15",
  },
  "grade20": {
    "code": ConcreteType.grade20,
    "displayName": "Grade 20",
  },
  "grade25": {
    "code": ConcreteType.grade25,
    "displayName": "Grade 25",
  },
  "grade30": {
    "code": ConcreteType.grade30,
    "displayName": "Grade 30",
  },
};

const concreteEstDimensionUnits = {
  "meter": Unit.m,
  "foot": Unit.foot,
  "inch": Unit.inch,
};

class ConcreteEstValue {
  Map<String, dynamic>? type;
  UnitType? unitType;

  String length;
  String width;
  String depth;

  Unit lengthUnit;
  Unit widthUnit;
  Unit depthUnit;

  ConcreteEstValue.init()
      : length = "",
        width = "",
        depth = "",
        lengthUnit = Unit.m,
        widthUnit = Unit.m,
        depthUnit = Unit.m;

  ConcreteEstValue copyWith({
    Map<String, dynamic>? type,
    UnitType? unitType,
    String? length,
    String? width,
    String? depth,
    Unit? lengthUnit,
    Unit? widthUnit,
    Unit? depthUnit,
  }) {
    return ConcreteEstValue.init()
      ..length = length ?? this.length
      ..width = width ?? this.width
      ..depth = depth ?? this.depth
      ..type = type ?? this.type
      ..unitType = unitType ?? this.unitType
      ..lengthUnit = lengthUnit ?? this.lengthUnit
      ..widthUnit = widthUnit ?? this.widthUnit
      ..depthUnit = depthUnit ?? this.depthUnit;
  }

  double get dLength => double.tryParse(length) ?? 0.0;
  double get dWidth => double.tryParse(width) ?? 0.0;
  double get dDepth => double.tryParse(depth) ?? 0.0;
}

class ConcreteEstFormController extends EstFormController<ConcreteEstValue> {
  ConcreteEstFormController({ConcreteEstValue? initialValue, required super.title, super.extra})
      : super(initialValue: initialValue ?? ConcreteEstValue.init());

  reset() {
    value = ConcreteEstValue.init();
    notifyListeners();
  }

  @override
  bool validateSync() {
    return value.type != null &&
        value.unitType != null &&
        value.dLength != 0.0 &&
        value.dWidth != 0.0 &&
        value.dDepth != 0.0;
  }
}

class ConcreteEstForm extends StatefulFormWidget<ConcreteEstValue> {
  const ConcreteEstForm({
    super.key,
    required super.controller,
    required this.onBack,
    required this.onNext,
    required this.onReset,
  });

  final void Function() onNext;
  final void Function() onBack;
  final void Function() onReset;
  @override
  State<ConcreteEstForm> createState() => _ConcreteEstFormState();
}

class _ConcreteEstFormState extends State<ConcreteEstForm> with FormMixin {
  late TextEditingController lengthEditingController;
  late TextEditingController widthEditingController;
  late TextEditingController depthEditingController;

  @override
  void initState() {
    lengthEditingController = TextEditingController(text: widget.controller.value.length);
    widthEditingController = TextEditingController(text: widget.controller.value.width);
    depthEditingController = TextEditingController(text: widget.controller.value.depth);
    super.initState();
  }

  @override
  handleFormControllerEvent() {
    final value = widget.controller.value;

    try {
      lengthEditingController.value = TextEditingValue(
        text: value.length,
        selection: TextSelection.collapsed(offset: value.length.length),
      );

      widthEditingController.value = widthEditingController.value.copyWith(
        text: value.width,
        selection: TextSelection.collapsed(offset: value.width.length),
      );

      depthEditingController.value = depthEditingController.value.copyWith(
        text: value.depth,
        selection: TextSelection.collapsed(offset: value.depth.length),
      );
    } catch (_) {}
  }

  handleChange(ConcreteEstValue value) {
    widget.controller.setValue(value);
  }

  Widget buildDimensionUnitSelector(BuildContext context, Unit value, Function(Unit?) onChange) {
    return DropdownButton<Unit>(
      value: value,
      isExpanded: true,
      onChanged: onChange,
      underline: const SizedBox.shrink(),
      hint: const Text("Unit"),
      padding: const EdgeInsets.only(left: 10),
      items: concreteEstDimensionUnits.keys
          .map(
            (key) => DropdownMenuItem<Unit>(
              value: concreteEstDimensionUnits[key],
              child: Text(key),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller as ConcreteEstFormController;
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25, left: 15, right: 15),
              child: BoqPageHeader(
                title: "Concrete Calculation".toUpperCase(),
                onBack: widget.onBack,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      BoqFieldDecoration(
                        helper: HelperText.normal(
                          "Unit",
                          onTap: () => showFieldInfo(
                            "Unit",
                            "Select unit type",
                          ),
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          onChanged: (p0) => handleChange(value.copyWith(unitType: p0)),
                          // hint: const Text("m³/Cube"),
                          value: value.unitType,
                          items: UnitType.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(unitTypeToString(type)),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      BoqFieldDecoration(
                        helper: HelperText.normal(
                          "Grade of Concrete",
                          onTap: () => showFieldInfo(
                            "Grade of Concrete",
                            "Select grade of concrete",
                          ),
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          onChanged: (p0) => handleChange(value.copyWith(type: p0)),
                          value: value.type,
                          items: concreteTypeOptions.keys
                              .map(
                                (key) => DropdownMenuItem<Map<String, dynamic>>(
                                  value: concreteTypeOptions[key],
                                  child: Text(concreteTypeOptions[key]['displayName']),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(),
                          1: FlexColumnWidth(),
                          3: FlexColumnWidth(),
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            children: [
                              SizedBox(
                                height: 75,
                                child: HelperText.normal(
                                  "Length",
                                  onTap: () => showFieldInfo(
                                    "Length",
                                    controller.extra['measurementMetrics'][1]['description'],
                                  ),
                                ),
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: lengthEditingController,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp("[.0-9]")),
                                ],
                                onChanged: (p0) => handleChange(value.copyWith(length: p0)),
                              ),
                              buildDimensionUnitSelector(
                                context,
                                value.lengthUnit,
                                (p0) => handleChange(value.copyWith(lengthUnit: p0)),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              SizedBox(
                                height: 75,
                                child: HelperText.normal(
                                  "Width",
                                  onTap: () => showFieldInfo(
                                    "Width",
                                    controller.extra['measurementMetrics'][0]['description'],
                                  ),
                                ),
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: widthEditingController,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp("[.0-9]")),
                                ],
                                onChanged: (p0) => handleChange(value.copyWith(width: p0)),
                              ),
                              buildDimensionUnitSelector(
                                context,
                                value.widthUnit,
                                (p0) => handleChange(value.copyWith(widthUnit: p0)),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              SizedBox(
                                height: 75,
                                child: HelperText.normal(
                                  "Depth",
                                  onTap: () => showFieldInfo(
                                    "Depth",
                                    controller.extra['measurementMetrics'][2]['description'],
                                  ),
                                ),
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: depthEditingController,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp("[.0-9]")),
                                ],
                                onChanged: (p0) => handleChange(value.copyWith(depth: p0)),
                              ),
                              buildDimensionUnitSelector(
                                context,
                                value.depthUnit,
                                (p0) => handleChange(value.copyWith(depthUnit: p0)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: BoqPageBottomNavigationBar(
                isNextDisabled: !controller.isValid,
                onReset: widget.onReset,
                onNext: widget.onNext,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Plaster estimation form

Map<String, dynamic> plasterTypeOptions = {
  "1:03": {"code": PlasterType.plaster1t03, "displayName": "1:03"},
  "1:05": {"code": PlasterType.plaster1t05, "displayName": "1:05"},
};

const plasterEstDimensionUnits = {
  "meter": Unit.m,
  "foot": Unit.foot,
  "inch": Unit.inch,
};

class PlasterEstValue {
  Map<String, dynamic>? type;
  UnitType? unitType;

  String length;
  String width;

  Unit lengthUnit;
  Unit widthUnit;

  PlasterEstValue.init()
      : length = "",
        width = "",
        lengthUnit = Unit.m,
        widthUnit = Unit.m;

  PlasterEstValue copyWith({
    Map<String, dynamic>? type,
    UnitType? unitType,
    String? length,
    String? width,
    Unit? lengthUnit,
    Unit? widthUnit,
  }) {
    return PlasterEstValue.init()
      ..length = length ?? this.length
      ..width = width ?? this.width
      ..type = type ?? this.type
      ..unitType = unitType ?? this.unitType
      ..lengthUnit = lengthUnit ?? this.lengthUnit
      ..widthUnit = widthUnit ?? this.widthUnit;
  }

  double get dLength => double.tryParse(length) ?? 0.0;
  double get dWidth => double.tryParse(width) ?? 0.0;
}

class PlasterEstFormController extends EstFormController<PlasterEstValue> {
  PlasterEstFormController({PlasterEstValue? initialValue, required super.title, super.extra})
      : super(initialValue: initialValue ?? PlasterEstValue.init());

  reset() {
    value = PlasterEstValue.init();
    notifyListeners();
  }

  @override
  bool validateSync() {
    return value.type != null && value.unitType != null && value.dLength != 0.0 && value.dWidth != 0.0;
  }
}

class PlasterEstForm extends StatefulFormWidget<PlasterEstValue> {
  const PlasterEstForm({
    super.key,
    required super.controller,
    required this.onBack,
    required this.onNext,
    required this.onReset,
  });

  final void Function() onNext;
  final void Function() onBack;
  final void Function() onReset;

  @override
  State<PlasterEstForm> createState() => _PlasterEstFormState();
}

class _PlasterEstFormState extends State<PlasterEstForm> with FormMixin {
  late TextEditingController lengthEditingController;
  late TextEditingController widthEditingController;

  @override
  void initState() {
    lengthEditingController = TextEditingController(text: widget.controller.value.length);
    widthEditingController = TextEditingController(text: widget.controller.value.width);
    super.initState();
  }

  @override
  handleFormControllerEvent() {
    final value = widget.controller.value;

    try {
      lengthEditingController.value = TextEditingValue(
        text: value.length,
        selection: TextSelection.collapsed(offset: value.length.length),
      );

      widthEditingController.value = widthEditingController.value.copyWith(
        text: value.width,
        selection: TextSelection.collapsed(offset: value.width.length),
      );
    } catch (_) {}
  }

  handleChange(PlasterEstValue value) {
    widget.controller.setValue(value);
  }

  Widget buildDimensionUnitSelector(BuildContext context, Unit value, Function(Unit?) onChange) {
    return DropdownButton<Unit>(
      value: value,
      isExpanded: true,
      onChanged: onChange,
      underline: const SizedBox.shrink(),
      hint: const Text("Unit"),
      padding: const EdgeInsets.only(left: 10),
      items: plasterEstDimensionUnits.keys
          .map(
            (key) => DropdownMenuItem<Unit>(
              value: plasterEstDimensionUnits[key],
              child: Text(key),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller as PlasterEstFormController;
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25, left: 15, right: 15),
              child: BoqPageHeader(
                title: "Plaster Calculation".toUpperCase(),
                onBack: widget.onBack,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      BoqFieldDecoration(
                        helper: HelperText.normal(
                          "Unit",
                          onTap: () => showFieldInfo(
                            "Unit",
                            "Select unit type",
                          ),
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          onChanged: (p0) => handleChange(value.copyWith(unitType: p0)),
                          // hint: const Text("m³/Cube"),
                          value: value.unitType,
                          items: UnitType.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(unitTypeToString(type)),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      BoqFieldDecoration(
                        helper: HelperText.normal(
                          "Plaster Type",
                          onTap: () => showFieldInfo(
                            "Plaster Type",
                            "Select plaster type",
                          ),
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          onChanged: (p0) => handleChange(value.copyWith(type: p0)),
                          value: value.type,
                          items: plasterTypeOptions.keys
                              .map(
                                (key) => DropdownMenuItem<Map<String, dynamic>>(
                                  value: plasterTypeOptions[key],
                                  child: Text(plasterTypeOptions[key]['displayName']),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(),
                          1: FlexColumnWidth(),
                          3: FlexColumnWidth(),
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            children: [
                              SizedBox(
                                height: 75,
                                child: HelperText.normal(
                                  "Length",
                                  onTap: () => showFieldInfo(
                                    "Length",
                                    controller.extra['measurementMetrics'][1]['description'],
                                  ),
                                ),
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: lengthEditingController,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp("[.0-9]")),
                                ],
                                onChanged: (p0) => handleChange(value.copyWith(length: p0)),
                              ),
                              buildDimensionUnitSelector(
                                context,
                                value.lengthUnit,
                                (p0) => handleChange(value.copyWith(lengthUnit: p0)),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              SizedBox(
                                height: 75,
                                child: HelperText.normal(
                                  "Width",
                                  onTap: () => showFieldInfo(
                                    "Width",
                                    controller.extra['measurementMetrics'][0]['description'],
                                  ),
                                ),
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: widthEditingController,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp("[.0-9]")),
                                ],
                                onChanged: (p0) => handleChange(value.copyWith(width: p0)),
                              ),
                              buildDimensionUnitSelector(
                                context,
                                value.widthUnit,
                                (p0) => handleChange(value.copyWith(widthUnit: p0)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: BoqPageBottomNavigationBar(
                isNextDisabled: !controller.isValid,
                onReset: widget.onReset,
                onNext: widget.onNext,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Brick work estimation form

Map<String, dynamic> brickTypeOptions = {
  "type112.50": {
    "code": BrickType.brick112P5,
    "displayName": "Type 112.50",
  },
  "type225.00": {
    "code": BrickType.brick225,
    "displayName": "Type 225.00",
  },
};

const brickEstDimensionUnits = {
  "meter": Unit.m,
  "foot": Unit.foot,
  "inch": Unit.inch,
};

class BrickEstValue {
  Map<String, dynamic>? type;
  UnitType? unitType;

  String length;
  String width;

  Unit lengthUnit;
  Unit widthUnit;

  BrickEstValue.init()
      : length = "",
        width = "",
        lengthUnit = Unit.m,
        widthUnit = Unit.m;

  BrickEstValue copyWith({
    Map<String, dynamic>? type,
    UnitType? unitType,
    String? length,
    String? width,
    Unit? lengthUnit,
    Unit? widthUnit,
  }) {
    return BrickEstValue.init()
      ..length = length ?? this.length
      ..width = width ?? this.width
      ..type = type ?? this.type
      ..unitType = unitType ?? this.unitType
      ..lengthUnit = lengthUnit ?? this.lengthUnit
      ..widthUnit = widthUnit ?? this.widthUnit;
  }

  double get dLength => double.tryParse(length) ?? 0.0;
  double get dWidth => double.tryParse(width) ?? 0.0;
}

class BrickEstFormController extends EstFormController<BrickEstValue> {
  BrickEstFormController({BrickEstValue? initialValue, required super.title, super.extra})
      : super(initialValue: initialValue ?? BrickEstValue.init());

  reset() {
    value = BrickEstValue.init();
    notifyListeners();
  }

  @override
  bool validateSync() {
    return value.type != null && value.unitType != null && value.dLength != 0.0 && value.dWidth != 0.0;
  }
}

class BrickEstForm extends StatefulFormWidget<BrickEstValue> {
  const BrickEstForm({
    super.key,
    required super.controller,
    required this.onBack,
    required this.onNext,
    required this.onReset,
  });

  final void Function() onNext;
  final void Function() onBack;
  final void Function() onReset;

  @override
  State<BrickEstForm> createState() => _BrickEstFormState();
}

class _BrickEstFormState extends State<BrickEstForm> with FormMixin {
  late TextEditingController lengthEditingController;
  late TextEditingController widthEditingController;

  @override
  void initState() {
    lengthEditingController = TextEditingController(text: widget.controller.value.length);
    widthEditingController = TextEditingController(text: widget.controller.value.width);
    super.initState();
  }

  @override
  handleFormControllerEvent() {
    final value = widget.controller.value;

    try {
      lengthEditingController.value = TextEditingValue(
        text: value.length,
        selection: TextSelection.collapsed(offset: value.length.length),
      );

      widthEditingController.value = widthEditingController.value.copyWith(
        text: value.width,
        selection: TextSelection.collapsed(offset: value.width.length),
      );
    } catch (_) {}
  }

  handleChange(BrickEstValue value) {
    widget.controller.setValue(value);
  }

  Widget buildDimensionUnitSelector(BuildContext context, Unit value, Function(Unit?) onChange) {
    return DropdownButton<Unit>(
      value: value,
      isExpanded: true,
      onChanged: onChange,
      underline: const SizedBox.shrink(),
      hint: const Text("Unit"),
      padding: const EdgeInsets.only(left: 10),
      items: brickEstDimensionUnits.keys
          .map(
            (key) => DropdownMenuItem<Unit>(
              value: brickEstDimensionUnits[key],
              child: Text(key),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller as BrickEstFormController;
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25, left: 15, right: 15),
              child: BoqPageHeader(
                title: "Brick Work Calculation".toUpperCase(),
                onBack: widget.onBack,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      BoqFieldDecoration(
                        helper: HelperText.normal(
                          "Unit",
                          onTap: () => showFieldInfo(
                            "Unit",
                            "Select unit type",
                          ),
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          onChanged: (p0) => handleChange(value.copyWith(unitType: p0)),
                          // hint: const Text("m³/Cube"),
                          value: value.unitType,
                          items: UnitType.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(unitTypeToString(type)),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      BoqFieldDecoration(
                        helper: HelperText.normal(
                          "Type",
                          onTap: () => showFieldInfo(
                            "Type",
                            "Select type",
                          ),
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          onChanged: (p0) => handleChange(value.copyWith(type: p0)),
                          value: value.type,
                          // hint: const Text("1:03"),
                          items: brickTypeOptions.keys
                              .map(
                                (key) => DropdownMenuItem<Map<String, dynamic>>(
                                  value: brickTypeOptions[key],
                                  child: Text(brickTypeOptions[key]['displayName']),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(),
                          1: FlexColumnWidth(),
                          3: FlexColumnWidth(),
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            children: [
                              SizedBox(
                                height: 75,
                                child: HelperText.normal(
                                  "Height",
                                  onTap: () => showFieldInfo(
                                    "Height",
                                    controller.extra['measurementMetrics'][1]['description'],
                                  ),
                                ),
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: lengthEditingController,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp("[.0-9]")),
                                ],
                                onChanged: (p0) => handleChange(value.copyWith(length: p0)),
                              ),
                              buildDimensionUnitSelector(
                                context,
                                value.lengthUnit,
                                (p0) => handleChange(value.copyWith(lengthUnit: p0)),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              SizedBox(
                                height: 75,
                                child: HelperText.normal(
                                  "Width",
                                  onTap: () => showFieldInfo(
                                    "Width",
                                    controller.extra['measurementMetrics'][0]['description'],
                                  ),
                                ),
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: widthEditingController,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp("[.0-9]")),
                                ],
                                onChanged: (p0) => handleChange(value.copyWith(width: p0)),
                              ),
                              buildDimensionUnitSelector(
                                context,
                                value.widthUnit,
                                (p0) => handleChange(value.copyWith(widthUnit: p0)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: BoqPageBottomNavigationBar(
                isNextDisabled: !controller.isValid,
                onReset: widget.onReset,
                onNext: widget.onNext,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Flooring estimation form

const flooringEstDimensionUnits = {
  "meter": Unit.m,
  "foot": Unit.foot,
  "inch": Unit.inch,
};

class FlooringEstValue {
  UnitType? unitType;

  String length;
  String width;

  Unit lengthUnit;
  Unit widthUnit;

  FlooringEstValue.init()
      : length = "",
        width = "",
        lengthUnit = Unit.m,
        widthUnit = Unit.m;

  FlooringEstValue copyWith({
    UnitType? unitType,
    String? length,
    String? width,
    Unit? lengthUnit,
    Unit? widthUnit,
  }) {
    return FlooringEstValue.init()
      ..length = length ?? this.length
      ..width = width ?? this.width
      ..unitType = unitType ?? this.unitType
      ..lengthUnit = lengthUnit ?? this.lengthUnit
      ..widthUnit = widthUnit ?? this.widthUnit;
  }

  double get dLength => double.tryParse(length) ?? 0.0;
  double get dWidth => double.tryParse(width) ?? 0.0;
}

class FlooringEstFormController extends EstFormController<FlooringEstValue> {
  FlooringEstFormController({FlooringEstValue? initialValue, required super.title, super.extra})
      : super(initialValue: initialValue ?? FlooringEstValue.init());

  reset() {
    value = FlooringEstValue.init();
    notifyListeners();
  }

  @override
  bool validateSync() {
    return value.unitType != null && value.dLength != 0.0 && value.dWidth != 0.0;
  }
}

class FlooringEstForm extends StatefulFormWidget<FlooringEstValue> {
  const FlooringEstForm({
    super.key,
    required super.controller,
    required this.onBack,
    required this.onNext,
    required this.onReset,
  });

  final void Function() onNext;
  final void Function() onBack;
  final void Function() onReset;

  @override
  State<FlooringEstForm> createState() => _FlooringEstFormState();
}

class _FlooringEstFormState extends State<FlooringEstForm> with FormMixin {
  late TextEditingController lengthEditingController;
  late TextEditingController widthEditingController;

  @override
  void initState() {
    lengthEditingController = TextEditingController(text: widget.controller.value.length);
    widthEditingController = TextEditingController(text: widget.controller.value.width);
    super.initState();
  }

  @override
  handleFormControllerEvent() {
    final value = widget.controller.value;

    try {
      lengthEditingController.value = TextEditingValue(
        text: value.length,
        selection: TextSelection.collapsed(offset: value.length.length),
      );

      widthEditingController.value = widthEditingController.value.copyWith(
        text: value.width,
        selection: TextSelection.collapsed(offset: value.width.length),
      );
    } catch (_) {}
  }

  handleChange(FlooringEstValue value) {
    widget.controller.setValue(value);
  }

  Widget buildDimensionUnitSelector(BuildContext context, Unit value, Function(Unit?) onChange) {
    return DropdownButton<Unit>(
      value: value,
      isExpanded: true,
      onChanged: onChange,
      underline: const SizedBox.shrink(),
      hint: const Text("Unit"),
      padding: const EdgeInsets.only(left: 10),
      items: flooringEstDimensionUnits.keys
          .map(
            (key) => DropdownMenuItem<Unit>(
              value: flooringEstDimensionUnits[key],
              child: Text(key),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller as FlooringEstFormController;
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25, left: 15, right: 15),
              child: BoqPageHeader(
                title: "Flooring Calculation".toUpperCase(),
                onBack: widget.onBack,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      BoqFieldDecoration(
                        helper: HelperText.normal(
                          "Unit",
                          onTap: () => showFieldInfo(
                            "Unit",
                            "Select unit type",
                          ),
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          onChanged: (p0) => handleChange(value.copyWith(unitType: p0)),
                          // hint: const Text("m³/Cube"),
                          value: value.unitType,
                          items: UnitType.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(unitTypeToString(type)),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(),
                          1: FlexColumnWidth(),
                          3: FlexColumnWidth(),
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            children: [
                              SizedBox(
                                height: 75,
                                child: HelperText.normal(
                                  "Length",
                                  onTap: () => showFieldInfo(
                                    "Length",
                                    controller.extra['measurementMetrics'][1]['description'],
                                  ),
                                ),
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: lengthEditingController,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp("[.0-9]")),
                                ],
                                onChanged: (p0) => handleChange(value.copyWith(length: p0)),
                              ),
                              buildDimensionUnitSelector(
                                context,
                                value.lengthUnit,
                                (p0) => handleChange(value.copyWith(lengthUnit: p0)),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              SizedBox(
                                height: 75,
                                child: HelperText.normal(
                                  "Width",
                                  onTap: () => showFieldInfo(
                                    "Width",
                                    controller.extra['measurementMetrics'][0]['description'],
                                  ),
                                ),
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: widthEditingController,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp("[.0-9]")),
                                ],
                                onChanged: (p0) => handleChange(value.copyWith(width: p0)),
                              ),
                              buildDimensionUnitSelector(
                                context,
                                value.widthUnit,
                                (p0) => handleChange(value.copyWith(widthUnit: p0)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: BoqPageBottomNavigationBar(
                isNextDisabled: !controller.isValid,
                onReset: widget.onReset,
                onNext: widget.onNext,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Painting estimation form

const paintEstDimensionUnits = {
  "meter": Unit.m,
  "foot": Unit.foot,
  "inch": Unit.inch,
};

class PaintEstValue {
  UnitType? unitType;

  String length;
  String width;

  Unit lengthUnit;
  Unit widthUnit;

  PaintEstValue.init()
      : length = "",
        width = "",
        lengthUnit = Unit.m,
        widthUnit = Unit.m;

  PaintEstValue copyWith({
    UnitType? unitType,
    String? length,
    String? width,
    Unit? lengthUnit,
    Unit? widthUnit,
  }) {
    return PaintEstValue.init()
      ..length = length ?? this.length
      ..width = width ?? this.width
      ..unitType = unitType ?? this.unitType
      ..lengthUnit = lengthUnit ?? this.lengthUnit
      ..widthUnit = widthUnit ?? this.widthUnit;
  }

  double get dLength => double.tryParse(length) ?? 0.0;
  double get dWidth => double.tryParse(width) ?? 0.0;
}

class PaintEstFormController extends EstFormController<PaintEstValue> {
  PaintEstFormController({PaintEstValue? initialValue, required super.title, super.extra})
      : super(initialValue: initialValue ?? PaintEstValue.init());

  reset() {
    value = PaintEstValue.init();
    notifyListeners();
  }

  @override
  bool validateSync() {
    return value.dLength != 0.0 && value.dWidth != 0.0;
  }
}

class PaintEstForm extends StatefulFormWidget<PaintEstValue> {
  const PaintEstForm({
    super.key,
    required super.controller,
    required this.onBack,
    required this.onNext,
    required this.onReset,
  });

  final void Function() onNext;
  final void Function() onBack;
  final void Function() onReset;

  @override
  State<PaintEstForm> createState() => _PaintEstFormState();
}

class _PaintEstFormState extends State<PaintEstForm> with FormMixin {
  late TextEditingController lengthEditingController;
  late TextEditingController widthEditingController;

  @override
  void initState() {
    lengthEditingController = TextEditingController(text: widget.controller.value.length);
    widthEditingController = TextEditingController(text: widget.controller.value.width);
    super.initState();
  }

  @override
  handleFormControllerEvent() {
    final value = widget.controller.value;

    try {
      lengthEditingController.value = TextEditingValue(
        text: value.length,
        selection: TextSelection.collapsed(offset: value.length.length),
      );

      widthEditingController.value = widthEditingController.value.copyWith(
        text: value.width,
        selection: TextSelection.collapsed(offset: value.width.length),
      );
    } catch (_) {}
  }

  handleChange(PaintEstValue value) {
    widget.controller.setValue(value);
  }

  Widget buildDimensionUnitSelector(BuildContext context, Unit value, Function(Unit?) onChange) {
    return DropdownButton<Unit>(
      value: value,
      isExpanded: true,
      onChanged: onChange,
      underline: const SizedBox.shrink(),
      hint: const Text("Unit"),
      padding: const EdgeInsets.only(left: 10),
      items: paintEstDimensionUnits.keys
          .map(
            (key) => DropdownMenuItem<Unit>(
              value: paintEstDimensionUnits[key],
              child: Text(key),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller as PaintEstFormController;
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25, left: 15, right: 15),
              child: BoqPageHeader(
                title: "Paint Calculation".toUpperCase(),
                onBack: widget.onBack,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      // BoqFieldDecoration(
                      //   helper: HelperText.normal(
                      //     "Unit",
                      //     onTap: () => showFieldInfo(
                      //       "Unit",
                      //       "Select unit type",
                      //     ),
                      //   ),
                      //   child: DropdownButton(
                      //     isExpanded: true,
                      //     onChanged: (p0) => handleChange(value.copyWith(unitType: p0)),
                      //     // hint: const Text("m³/Cube"),
                      //     value: value.unitType,
                      //     items: UnitType.values
                      //         .map(
                      //           (type) => DropdownMenuItem(
                      //             value: type,
                      //             child: Text(unitTypeToString(type)),
                      //           ),
                      //         )
                      //         .toList(),
                      //   ),
                      // ),
                      // const SizedBox(height: 20),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(),
                          1: FlexColumnWidth(),
                          3: FlexColumnWidth(),
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            children: [
                              SizedBox(
                                height: 75,
                                child: HelperText.normal(
                                  "Height",
                                  onTap: () => showFieldInfo(
                                    "Height",
                                    controller.extra['measurementMetrics'][1]['description'],
                                  ),
                                ),
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: lengthEditingController,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp("[.0-9]")),
                                ],
                                onChanged: (p0) => handleChange(value.copyWith(length: p0)),
                              ),
                              buildDimensionUnitSelector(
                                context,
                                value.lengthUnit,
                                (p0) => handleChange(value.copyWith(lengthUnit: p0)),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              SizedBox(
                                height: 75,
                                child: HelperText.normal(
                                  "Width",
                                  onTap: () => showFieldInfo(
                                    "Width",
                                    controller.extra['measurementMetrics'][0]['description'],
                                  ),
                                ),
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: widthEditingController,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp("[.0-9]")),
                                ],
                                onChanged: (p0) => handleChange(value.copyWith(width: p0)),
                              ),
                              buildDimensionUnitSelector(
                                context,
                                value.widthUnit,
                                (p0) => handleChange(value.copyWith(widthUnit: p0)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: BoqPageBottomNavigationBar(
                isNextDisabled: !controller.isValid,
                onReset: widget.onReset,
                onNext: widget.onNext,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widgets

class HelperText extends StatelessWidget {
  const HelperText({super.key, required this.text, required this.icon, this.onTap});

  const HelperText.normal(this.text, {super.key, this.onTap})
      : icon = const Icon(
          Icons.help,
          size: 20,
        );

  final String text;
  final Widget icon;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    Widget child = icon;

    if (onTap != null) {
      child = GestureDetector(onTap: onTap, child: child);
    }

    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 5),
        child,
      ],
    );
  }
}

class BoqFieldDecoration extends StatelessWidget {
  const BoqFieldDecoration({
    super.key,
    required this.helper,
    required this.child,
  });

  final Widget child;
  final Widget helper;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        child,
        helper,
      ],
    );
  }
}

class BoqPageHeader extends StatelessWidget {
  const BoqPageHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final void Function()? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (onBack != null)
              IconButton(
                onPressed: onBack,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const Divider(thickness: 1),
      ],
    );
  }
}

class BoqPageBottomNavigationBar extends StatelessWidget {
  const BoqPageBottomNavigationBar({
    super.key,
    required this.onReset,
    required this.onNext,
    this.isNextDisabled = false,
  });

  final bool isNextDisabled;
  final void Function() onReset;
  final void Function() onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: onReset,
            style: ButtonStyle(
              visualDensity: VisualDensity.standard,
              textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.w500)),
              minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
              backgroundColor: MaterialStateProperty.all(AppColors.red),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            // child: const Text("Reset"),
            child: Text(AppLocalizations.of(context)!.nN_1011),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton(
            onPressed: !isNextDisabled ? onNext : null,
            style: ButtonStyle(
              visualDensity: VisualDensity.standard,
              textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.w500)),
              minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
              backgroundColor: MaterialStateProperty.all(AppColors.red),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            // child: const Text("Next"),
            child: Text(AppLocalizations.of(context)!.nN_1010),
          ),
        )
      ],
    );
  }
}

showFieldInfo(String title, String subtitle) => locate<PopupController>().addItemFor(
      DismissiblePopup(
        title: "ℹ $title",
        subtitle: subtitle,
        color: Colors.black54,
        onDismiss: (self) => locate<PopupController>().removeItem(self),
      ),
      const Duration(seconds: 5),
    );
