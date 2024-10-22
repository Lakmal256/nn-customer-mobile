import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:nawa_niwasa/locator.dart';
import 'package:nawa_niwasa/service/service.dart';

import '../../l10n.dart';
import '../ui.dart';
import 'calculation.dart';

class ConcreteCrackingProbabilityWizardStateValue {
  ConcreteCrackingProbabilityWizardStateValue.empty()
      : concreteTemperatureUnit = Unit.celsius,
        ambientTemperatureUnit = Unit.celsius,
        humidityUnit = Unit.percent,
        windVelocityUnit = Unit.ms,
        concreteTemperature = "",
        ambientTemperature = "",
        humidity = "",
        windVelocity = "";

  Unit concreteTemperatureUnit;
  String concreteTemperature;

  Unit ambientTemperatureUnit;
  String ambientTemperature;

  Unit humidityUnit;
  String humidity;

  Unit windVelocityUnit;
  String windVelocity;

  ConcreteCrackingProbabilityWizardStateValue copyWith({
    Unit? concreteTemperatureUnit,
    Unit? ambientTemperatureUnit,
    Unit? humidityUnit,
    Unit? windVelocityUnit,
    String? concreteTemperature,
    String? ambientTemperature,
    String? humidity,
    String? windVelocity,
  }) {
    return ConcreteCrackingProbabilityWizardStateValue.empty()
      ..concreteTemperatureUnit = concreteTemperatureUnit ?? this.concreteTemperatureUnit
      ..ambientTemperatureUnit = ambientTemperatureUnit ?? this.ambientTemperatureUnit
      ..humidityUnit = humidityUnit ?? this.humidityUnit
      ..windVelocityUnit = windVelocityUnit ?? this.windVelocityUnit
      ..concreteTemperature = concreteTemperature ?? this.concreteTemperature
      ..ambientTemperature = ambientTemperature ?? this.ambientTemperature
      ..humidity = humidity ?? this.humidity
      ..windVelocity = windVelocity ?? this.windVelocity;
  }

  double get dConcreteTemperature => double.tryParse(concreteTemperature) ?? 0.0;
  double get dAmbientTemperature => double.tryParse(ambientTemperature) ?? 0.0;
  double get dWindVelocity => double.tryParse(windVelocity) ?? 0.0;
  double get dHumidity => double.tryParse(humidity) ?? 0.0;
}

class ConcreteCrackingProbabilityWizardController extends FormController<ConcreteCrackingProbabilityWizardStateValue> {
  ConcreteCrackingProbabilityWizardController({required super.initialValue});

  bool validateSync() {
    return value.dWindVelocity != 0.0 &&
        value.dAmbientTemperature != 0.0 &&
        value.dConcreteTemperature != 0.0 &&
        value.dHumidity != 0.0;
  }

  @override
  bool get isValid => validateSync();

  double calculateProbability() {
    CrackingProbability calculator = CrackingProbability()..r = value.dHumidity.toDouble();

    calculator.tc = value.dConcreteTemperature;
    switch (value.concreteTemperatureUnit) {
      case Unit.fahrenheit:
        {
          calculator.tc = fahrenheitToCelsius(value.dConcreteTemperature);
          break;
        }
      default:
        break;
    }

    calculator.ta = value.dAmbientTemperature;
    switch (value.ambientTemperatureUnit) {
      case Unit.fahrenheit:
        {
          calculator.ta = fahrenheitToCelsius(value.dAmbientTemperature);
          break;
        }
      default:
        break;
    }

    /// Convert velocity into km/h
    calculator.V = value.dWindVelocity;
    switch (value.windVelocityUnit) {
      case Unit.ms:
        {
          calculator.V = value.dWindVelocity * 3.6;
          break;
        }
      case Unit.mph:
        {
          calculator.V = value.dWindVelocity * 1.609;
          break;
        }
      default:
        break;
    }

    return calculator.calculate();
  }
}

class ConcreteCrackingProbabilityWizard extends StatefulFormWidget {
  const ConcreteCrackingProbabilityWizard({super.key, required super.controller});

  @override
  State<ConcreteCrackingProbabilityWizard> createState() => _ConcreteCrackingProbabilityWizardState();
}

class _ConcreteCrackingProbabilityWizardState extends State<ConcreteCrackingProbabilityWizard>
    with FormMixin, SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
  }

  handleNext(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Material(
          child: ProbabilityInvoiceView(
            onBack: Navigator.of(context).pop,
            controller: widget.controller as ConcreteCrackingProbabilityWizardController,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: tabController,
          builder: (context, child) {
            return Row(
              children: [
                Expanded(
                  child: LineBorderTab(
                    // title: "Default Option",
                    title: AppLocalizations.of(context)!.nN_126,
                    isActive: tabController.index == 0,
                    onSelect: () => tabController.animateTo(0),
                  ),
                ),
                Expanded(
                  child: LineBorderTab(
                    // title: "Advanced Option",
                    title: AppLocalizations.of(context)!.nN_127,
                    isActive: tabController.index == 1,
                    onSelect: () => tabController.animateTo(1),
                  ),
                ),
              ],
            );
          },
        ),
        Expanded(
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: tabController,
            children: [
              LowAccuracyForm(controller: widget.controller as ConcreteCrackingProbabilityWizardController),
              HighAccuracyForm(controller: widget.controller as ConcreteCrackingProbabilityWizardController),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, child) {
              return BoqPageBottomNavigationBar(
                isNextDisabled: !widget.controller.isValid,
                onReset: () => widget.controller.setValue(ConcreteCrackingProbabilityWizardStateValue.empty()),
                onNext: () => handleNext(context),
              );
            },
          ),
        ),
      ],
    );
  }
}

class LineBorderTab extends StatelessWidget {
  const LineBorderTab({
    super.key,
    required this.title,
    required this.isActive,
    required this.onSelect,
  });

  final String title;
  final bool isActive;
  final Function() onSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 15, 5, 0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w600 : null,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            height: 15,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: isActive ? 5 : 1,
                  color: isActive ? const Color(0xFFFF7373) : const Color(0xFF929292),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Form

const temperatureUnits = [
  Unit.celsius,
  Unit.fahrenheit,
];

const humidityUnits = [Unit.percent];

const velocityUnits = [
  Unit.ms,
  Unit.kmh,
  Unit.mph,
];

class LowAccuracyForm extends StatefulFormWidget {
  const LowAccuracyForm({super.key, required super.controller});

  @override
  State<LowAccuracyForm> createState() => _LowAccuracyFormState();
}

class _LowAccuracyFormState extends State<LowAccuracyForm> with FormMixin {
  TextEditingController concreteTemperatureTextEditingController = TextEditingController();

  Timer? _debounceTimer;
  Duration debounceDuration = const Duration(milliseconds: 500);

  late LocationData? locationData;

  fetchDeviceLocation() async {
    locationData = await locate<DeviceLocationService>().location;
  }

  handleChange(ConcreteCrackingProbabilityWizardStateValue value) {
    widget.controller.setValue(value);
  }

  handleTempChange(String temperature) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () async {
      if (locationData == null) return;

      var info = await locate<RestService>().getWeatherInfo(locationData!.latitude!, locationData!.longitude!);
      if (info == null) return;

      ConcreteCrackingProbabilityWizardStateValue value0 = widget.controller.value;
      widget.controller.setValue(value0.copyWith(
          concreteTemperature: temperature,
          ambientTemperature: info.ambientTemperature.toString(),
          humidity: info.relativeHumidity.toString(),
          windVelocity: info.windVelocity.toString()));
    });
  }

  @override
  void initState() {
    fetchDeviceLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.nN_128,
                    ),
                    TextSpan(
                      text: AppLocalizations.of(context)!.nN_128_p1,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                // "Concrete Temperature",
                AppLocalizations.of(context)!.nN_129,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFFFF0000).withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<Unit>(
                      value: value.concreteTemperatureUnit,
                      isExpanded: true,
                      onChanged: (p0) => handleChange(value.copyWith(concreteTemperatureUnit: p0)),
                      underline: const SizedBox.shrink(),
                      hint: const Text("Unit"),
                      padding: const EdgeInsets.only(right: 10),
                      items: temperatureUnits
                          .map((unit) => DropdownMenuItem<Unit>(
                                value: unit,
                                child: Text(getUnitInfo(unit)["displayName"]!),
                              ))
                          .toList(),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      controller: concreteTemperatureTextEditingController,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp("[.0-9]")),
                      ],
                      onChanged: (value) => handleTempChange(value),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void init() {
    handleValueChange();
    super.init();
  }

  @override
  void handleFormControllerEvent() {
    handleValueChange();
    super.handleFormControllerEvent();
  }

  handleValueChange() {
    final value = widget.controller.value as ConcreteCrackingProbabilityWizardStateValue;
    try {
      concreteTemperatureTextEditingController.value = TextEditingValue(
        text: value.concreteTemperature,
        selection: TextSelection.collapsed(offset: value.concreteTemperature.length),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

class HighAccuracyForm extends StatefulFormWidget {
  const HighAccuracyForm({super.key, required super.controller});

  @override
  State<HighAccuracyForm> createState() => _HighAccuracyFormState();
}

class PercentageTextInputFormatter implements TextInputFormatter {
  PercentageTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    int value = int.tryParse(newValue.text) ?? 0;
    if (value >= 0 && value <= 100) return newValue;
    return oldValue;
  }
}

class _HighAccuracyFormState extends State<HighAccuracyForm> with FormMixin {
  TextEditingController concreteTemperatureTextEditingController = TextEditingController();
  TextEditingController ambientTemperatureTextEditingController = TextEditingController();
  TextEditingController humidityTextEditingController = TextEditingController();
  TextEditingController velocityTextEditingController = TextEditingController();

  handleChange(ConcreteCrackingProbabilityWizardStateValue value) {
    widget.controller.setValue(value);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ValueListenableBuilder(
        valueListenable: widget.controller as ConcreteCrackingProbabilityWizardController,
        builder: (context, value, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        // text: "For higher accuracy,\n\n",
                        text: AppLocalizations.of(context)!.nN_134,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  // "Concrete Temperature",
                  AppLocalizations.of(context)!.nN_129,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFFFF0000).withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<Unit>(
                        value: value.concreteTemperatureUnit,
                        isExpanded: true,
                        onChanged: (p0) => handleChange(value.copyWith(concreteTemperatureUnit: p0)),
                        underline: const SizedBox.shrink(),
                        hint: const Text("Unit"),
                        padding: const EdgeInsets.only(right: 10),
                        items: temperatureUnits
                            .map((unit) => DropdownMenuItem<Unit>(
                                  value: unit,
                                  child: Text(getUnitInfo(unit)["displayName"]!),
                                ))
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        controller: concreteTemperatureTextEditingController,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp("[.0-9]")),
                        ],
                        onChanged: (p0) => handleChange(value.copyWith(concreteTemperature: p0)),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  // "Ambient Temperature",
                  AppLocalizations.of(context)!.nN_131,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFFFF0000).withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<Unit>(
                        value: value.ambientTemperatureUnit,
                        isExpanded: true,
                        onChanged: (p0) => handleChange(value.copyWith(ambientTemperatureUnit: p0)),
                        underline: const SizedBox.shrink(),
                        hint: const Text("Unit"),
                        padding: const EdgeInsets.only(right: 10),
                        items: temperatureUnits
                            .map((unit) => DropdownMenuItem<Unit>(
                                  value: unit,
                                  child: Text(getUnitInfo(unit)["displayName"]!),
                                ))
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        controller: ambientTemperatureTextEditingController,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp("[.0-9]")),
                        ],
                        onChanged: (p0) => handleChange(value.copyWith(ambientTemperature: p0)),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  // "Relative Humidity",
                  AppLocalizations.of(context)!.nN_132,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFFFF0000).withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<Unit>(
                        value: value.humidityUnit,
                        isExpanded: true,
                        onChanged: (p0) => handleChange(value.copyWith(humidityUnit: p0)),
                        underline: const SizedBox.shrink(),
                        hint: const Text("Unit"),
                        padding: const EdgeInsets.only(right: 10),
                        items: humidityUnits
                            .map((unit) => DropdownMenuItem<Unit>(
                                  value: unit,
                                  child: Text(getUnitInfo(unit)["displayName"]!),
                                ))
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        controller: humidityTextEditingController,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp("[.0-9]")),
                          PercentageTextInputFormatter()
                        ],
                        onChanged: (p0) => handleChange(value.copyWith(humidity: p0)),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  // "Wind Velocity",
                  AppLocalizations.of(context)!.nN_133,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFFFF0000).withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<Unit>(
                        value: value.windVelocityUnit,
                        isExpanded: true,
                        onChanged: (p0) => handleChange(value.copyWith(windVelocityUnit: p0)),
                        underline: const SizedBox.shrink(),
                        hint: const Text("Unit"),
                        padding: const EdgeInsets.only(right: 10),
                        items: velocityUnits
                            .map((unit) => DropdownMenuItem<Unit>(
                                  value: unit,
                                  child: Text(getUnitInfo(unit)["displayName"]!),
                                ))
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        controller: velocityTextEditingController,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp("[.0-9]")),
                        ],
                        onChanged: (p0) => handleChange(value.copyWith(windVelocity: p0)),
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void init() {
    handleValueChange();
    super.init();
  }

  @override
  void handleFormControllerEvent() {
    handleValueChange();
    super.handleFormControllerEvent();
  }

  handleValueChange() {
    final value = widget.controller.value as ConcreteCrackingProbabilityWizardStateValue;
    try {
      concreteTemperatureTextEditingController.value = TextEditingValue(
        text: value.concreteTemperature,
        selection: TextSelection.collapsed(offset: value.concreteTemperature.length),
      );

      ambientTemperatureTextEditingController.value = TextEditingValue(
        text: value.ambientTemperature,
        selection: TextSelection.collapsed(offset: value.ambientTemperature.length),
      );

      humidityTextEditingController.value = TextEditingValue(
        text: value.humidity,
        selection: TextSelection.collapsed(offset: value.humidity.length),
      );

      velocityTextEditingController.value = TextEditingValue(
        text: value.windVelocity,
        selection: TextSelection.collapsed(offset: value.windVelocity.length),
      );
    } catch (_) {}
  }
}

class ProbabilityInvoiceView extends StatelessWidget {
  const ProbabilityInvoiceView({
    super.key,
    required this.controller,
    required this.onBack,
  });

  final ConcreteCrackingProbabilityWizardController controller;
  final Function() onBack;

  ProbabilityInfoType getType(double value) {
    if (value <= 0.5) {
      return ProbabilityInfoType.favourable;
    } else if (value > 0.5 && value <= 0.7) {
      return ProbabilityInfoType.moderatelyFavourable;
    } else {
      return ProbabilityInfoType.notFavourable;
    }
  }

  @override
  Widget build(BuildContext context) {
    double probability = controller.calculateProbability();
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 15),
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Text(
                  // "CONCRETE CRACKING PROBABILITY CALCULATION",
                  AppLocalizations.of(context)!.nN_125.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const Divider(thickness: 1),
          ProbabilityInvoiceItem(
            // title: "CONCRETE CRACKING PROBABILITY",
            title: AppLocalizations.of(context)!.nN_135.toUpperCase(),
            items: [
              {
                // "name": "Concrete Temperature",
                "name": AppLocalizations.of(context)!.nN_129,
                "value": controller.value.concreteTemperature,
                "unit": getUnitInfo(controller.value.concreteTemperatureUnit)['symbol'],
              },
              {
                // "name": "Ambient Temperature",
                "name": AppLocalizations.of(context)!.nN_131,
                "value": controller.value.ambientTemperature,
                "unit": getUnitInfo(controller.value.ambientTemperatureUnit)['symbol'],
              },
              {
                // "name": "Relative Humidity",
                "name": AppLocalizations.of(context)!.nN_132,
                "value": controller.value.humidity,
                "unit": getUnitInfo(controller.value.humidityUnit)['symbol'],
              },
              {
                // "name": "Wind Velocity",
                "name": AppLocalizations.of(context)!.nN_133,
                "value": controller.value.windVelocity,
                "unit": getUnitInfo(controller.value.windVelocityUnit)['symbol'],
              }
            ],
            footers: [
              // {"title": "Evaporation Rate Index", "value": "${probability.toStringAsFixed(4)} kg/m²/h"}
              {"title": AppLocalizations.of(context)!.nN_145, "value": "${probability.toStringAsFixed(4)} kg/m²/h"}
            ],
          ),
          const SizedBox(height: 15),
          ProbabilityInfo(
            type: getType(probability),
          ),
        ],
      ),
    );
  }
}

class ProbabilityInvoiceItem extends StatelessWidget {
  const ProbabilityInvoiceItem({
    super.key,
    required this.title,
    required this.items,
    required this.footers,
  });

  final String title;
  final List<Map<String, dynamic>> items;
  final List<Map<String, String>> footers;

  Widget renderSubItem(BuildContext context, String p0, String p1) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(p0), Text(p1)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.red),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text("FACTOR", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(AppLocalizations.of(context)!.nN_143, style: const TextStyle(fontWeight: FontWeight.bold)),
                    // Text("VALUE", style: TextStyle(fontWeight: FontWeight.bold))
                    Text(AppLocalizations.of(context)!.nN_144, style: const TextStyle(fontWeight: FontWeight.bold))
                  ],
                ),
              ),
              const Divider(height: 1),
              ...items.map(
                (qty) => renderSubItem(context, qty["name"], "${qty["value"]} ${qty["unit"]}"),
              ),
              const SizedBox(height: 15),
              ...footers
                  .map(
                    (footer) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              footer['title'] ?? "",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            footer['value'] ?? "",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              const Divider(height: 1),
            ],
          ),
        )
      ],
    );
  }
}

enum ProbabilityInfoType {
  favourable,
  moderatelyFavourable,
  notFavourable,
}

Map<ProbabilityInfoType, Map<String, dynamic>> getProbabilityInfoTypes(BuildContext context) => {
      ProbabilityInfoType.favourable: {
        "color": const Color(0xFF198217),
        // "message": "The above conditions are very favourable for concrete placement",
        "message": AppLocalizations.of(context)!.nN_137,
      },
      ProbabilityInfoType.moderatelyFavourable: {
        "color": const Color(0xFFFF9C00),
        // "message": "The above conditions are moderately favourable for concrete placement",
        "message": AppLocalizations.of(context)!.nN_138,
      },
      ProbabilityInfoType.notFavourable: {
        "color": const Color(0xFFEE1C25),
        // "message": "The above conditions are not favourable for concrete placement",
        "message": AppLocalizations.of(context)!.nN_139,
      }
    };

List<Map<String, String>> getProbabilityInfo(BuildContext context) => [
      {
        "title": AppLocalizations.of(context)!.nN_140_1_title,
        "text": AppLocalizations.of(context)!.nN_140_1_text,
      },
      {
        "title": AppLocalizations.of(context)!.nN_140_2_title,
        "text": AppLocalizations.of(context)!.nN_140_2_text,
      },
      {
        "title": AppLocalizations.of(context)!.nN_140_3_title,
        "text": AppLocalizations.of(context)!.nN_140_3_text,
      },
      {
        "title": AppLocalizations.of(context)!.nN_140_4_title,
        "text": AppLocalizations.of(context)!.nN_140_4_text,
      },
      {
        "title": AppLocalizations.of(context)!.nN_140_5_title,
        "text": AppLocalizations.of(context)!.nN_140_5_text,
      },
      {
        "title": AppLocalizations.of(context)!.nN_140_6_title,
        "text": AppLocalizations.of(context)!.nN_140_6_text,
      },
      {
        "title": AppLocalizations.of(context)!.nN_140_7_title,
        "text": AppLocalizations.of(context)!.nN_140_7_text,
      },
      {
        "title": AppLocalizations.of(context)!.nN_140_8_title,
        "text": AppLocalizations.of(context)!.nN_140_8_text,
      },
    ];

class ProbabilityInfo extends StatelessWidget {
  const ProbabilityInfo({super.key, required this.type});

  final ProbabilityInfoType type;

  @override
  Widget build(BuildContext context) {
    var typeData = getProbabilityInfoTypes(context)[type];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProbabilityInfoBanner(
          text: typeData!['message'],
          color: typeData['color'],
        ),
        const GeneralProbabilityInfo(),
        if (type != ProbabilityInfoType.favourable)
          const Padding(
            padding: EdgeInsets.only(left: 15, right: 15, top: 15),
            child: MoreProbabilityInfo(),
          ),
      ],
    );
  }
}

class ProbabilityInfoBanner extends StatelessWidget {
  const ProbabilityInfoBanner({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      color: color,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class GeneralProbabilityInfo extends StatelessWidget {
  const GeneralProbabilityInfo({super.key});

  Widget buildItem(BuildContext context, Color color, String text) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: color,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: getProbabilityInfoTypes(context)
            .values
            .map((value) => Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: buildItem(
                    context,
                    value["color"],
                    value["message"],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class MoreProbabilityInfo extends StatelessWidget {
  const MoreProbabilityInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: getProbabilityInfo(context)
          .map((item) => MoreProbabilityInfoItem(
                title: item["title"]!,
                text: item["text"]!,
              ))
          .toList(),
    );
  }
}

class MoreProbabilityInfoItem extends StatefulWidget {
  const MoreProbabilityInfoItem({
    super.key,
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  State<MoreProbabilityInfoItem> createState() => _MoreProbabilityInfoItemState();
}

class _MoreProbabilityInfoItemState extends State<MoreProbabilityInfoItem> {
  bool isCollapsed = true;

  @override
  Widget build(BuildContext context) {
    int? maxLines = isCollapsed ? 2 : null;
    TextSpan bodyTextSpan = TextSpan(text: widget.text);
    // TextPainter textPainter = TextPainter(
    //   text: bodyTextSpan,
    //   maxLines: maxLines,
    //   textDirection: TextDirection.ltr,
    // )..layout(maxWidth: MediaQuery.of(context).size.width);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(bodyTextSpan, maxLines: maxLines),
              // if (textPainter.didExceedMaxLines || !isCollapsed)
              GestureDetector(
                onTap: () => setState(() => isCollapsed = !isCollapsed),
                child: Text(
                  isCollapsed ? AppLocalizations.of(context)!.nN_141 : AppLocalizations.of(context)!.nN_142,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4267B2),
                  ),
                ),
              ),
              const Divider(thickness: 1)
            ],
          ),
        )
      ],
    );
  }
}
