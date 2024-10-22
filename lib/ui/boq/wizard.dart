import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../l10n.dart';
import '../../locator.dart';
import '../../service/service.dart';

import '../ui.dart';
import 'calculation.dart';

class BoqWizardStateValue {
  BoqWizardStateValue.empty()
      : formControllers = <String, EstFormController>{},
        shouldSendEmail = false,
        estimateName = "";

  Map<String, EstFormController> formControllers;

  bool shouldSendEmail;

  String estimateName;
}

class BoqWizardController extends FormController<BoqWizardStateValue> {
  BoqWizardController({required super.initialValue});

  /// Check and Add or Remove Estimation form value based on availability
  BoqWizardController toggleExtValue(String key, dynamic formValue) {
    if (value.formControllers.containsKey(key)) {
      value.formControllers.remove(key);
    } else {
      value.formControllers.putIfAbsent(key, () => formValue);
    }
    notifyListeners();
    return this;
  }
}

class BoqWizardProgressIndicator extends StatelessWidget {
  const BoqWizardProgressIndicator({
    super.key,
    required this.wizardController,
    required this.tabController,
    required this.staticPageCount,
  });

  final BoqWizardController wizardController;
  final TabController tabController;
  final int staticPageCount;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([tabController, wizardController]),
      builder: (context, child) {
        return LinearProgressIndicator(
          value: progress,
        );
      },
    );
  }

  double get progress => (tabController.index + 1) / (staticPageCount + wizardController.value.formControllers.length);
}

class BoqWizardEstType {
  BoqWizardEstType._();

  static const concrete = "concrete";
  static const plaster = "plaster";
  static const brickWork = "brick_work";
  static const flooring = "flooring";
  static const paint = "paint";
}

class BoqWizard extends StatefulFormWidget<BoqWizardStateValue> {
  const BoqWizard({
    Key? key,
    required BoqWizardController controller,
  }) : super(key: key, controller: controller);

  @override
  State<BoqWizard> createState() => _BoqWizardState();
}

class _BoqWizardState extends State<BoqWizard> with FormMixin, TickerProviderStateMixin {
  late TabController tabController;
  List<Widget> pages = List.empty(growable: true);

  static const _staticPageCount = 2;

  @override
  void initState() {
    tabController = TabController(vsync: this, length: _staticPageCount);
    super.initState();
  }

  handleNext() {
    tabController.animateTo(tabController.index + 1);
  }

  handleBack() {
    tabController.animateTo(tabController.index - 1);
  }

  Widget getPage(BuildContext context, String key) {
    final estFormController = widget.controller.value.formControllers[key];
    switch (key) {
      case BoqWizardEstType.concrete:
        return ConcreteEstForm(
          controller: estFormController as ConcreteEstFormController,
          onBack: handleBack,
          onNext: handleNext,
          onReset: estFormController.reset,
        );
      case BoqWizardEstType.plaster:
        return PlasterEstForm(
          controller: estFormController as PlasterEstFormController,
          onBack: handleBack,
          onNext: handleNext,
          onReset: estFormController.reset,
        );
      case BoqWizardEstType.brickWork:
        return BrickEstForm(
          controller: estFormController as BrickEstFormController,
          onBack: handleBack,
          onNext: handleNext,
          onReset: estFormController.reset,
        );
      case BoqWizardEstType.flooring:
        return FlooringEstForm(
          controller: estFormController as FlooringEstFormController,
          onBack: handleBack,
          onNext: handleNext,
          onReset: estFormController.reset,
        );
      case BoqWizardEstType.paint:
        return PaintEstForm(
          controller: estFormController as PaintEstFormController,
          onBack: handleBack,
          onNext: handleNext,
          onReset: estFormController.reset,
        );

      /// Unknown Estimation Form
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller as BoqWizardController;
    return Column(
      children: [
        BoqWizardProgressIndicator(
          tabController: tabController,
          staticPageCount: _staticPageCount,
          wizardController: controller,
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              InitiateBoqPage(
                controller: controller,
                onNext: handleNext,
              ),

              /// Dynamic calculation form pages / tabs
              ...pages,

              BoqInvoicePage(
                controller: controller,
                onBack: handleBack,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void init() {
    handleFormValueChange();
    super.init();
  }

  @override
  void handleFormControllerEvent() {
    handleFormValueChange();
    super.handleFormControllerEvent();
  }

  handleFormValueChange() {
    final formControllers = widget.controller.value.formControllers;
    int length = formControllers.length;
    length = length + _staticPageCount;

    /// Check if BoqWizardController est form controller count changed
    /// if so update the tab controller
    if (length != tabController.length) {
      int index = tabController.index;
      if (length < tabController.length && index > 0) index = index - 1;

      setState(() {
        /// Update dynamic estimation forms from controllers
        pages = formControllers.keys.map((key) => getPage(context, key)).toList();

        /// Update tab length & index
        tabController = TabController(
          length: length,
          vsync: this,
          initialIndex: index,
        );
      });
    }
  }
}

class InitiateBoqPage extends StatefulFormWidget<BoqWizardStateValue> {
  const InitiateBoqPage({
    Key? key,
    required BoqWizardController controller,
    required this.onNext,
  }) : super(key: key, controller: controller);

  final void Function() onNext;

  @override
  State<InitiateBoqPage> createState() => _CreateBoqPageState();
}

class _CreateBoqPageState extends State<InitiateBoqPage> with FormMixin {
  TextEditingController boqEstimateNameTextController = TextEditingController();

  handleGenerateEmailSwitch(bool state) {
    widget.controller.setValue(widget.controller.value..shouldSendEmail = state);
  }

  handleInitNext() {
    if (widget.controller.value.estimateName == "") {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Estimation name is required",
          subtitle: "Please provide a name for the estimation",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
      return;
    }
    if (widget.controller.value.formControllers.isEmpty) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Estimations are empty",
          subtitle: "Please select estimation items to calculate",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
      return;
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, snapshot, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Page header section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            // "CREATE ESTIMATE",
                            AppLocalizations.of(context)!.nN_102.toUpperCase(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Divider(thickness: 1),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: boqEstimateNameTextController,
                        autocorrect: true,
                        keyboardType: TextInputType.text,
                        onChanged: (value) => widget.controller.setValue(
                          snapshot..estimateName = value,
                        ),
                        decoration: InputDecoration(
                          // hintText: "Estimation name",
                          hintText: AppLocalizations.of(context)!.nN_1038,
                          // errorText: formValue.getError("uName"),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => handleGenerateEmailSwitch(!snapshot.shouldSendEmail),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    // "Email Estimate",
                                    AppLocalizations.of(context)!.nN_1039,
                                    style:
                                        Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  // const Text("Email me a PDF of this estimate."),
                                  Text(AppLocalizations.of(context)!.nN_1040),
                                ],
                              ),
                            ),
                            Switch(
                              onChanged: handleGenerateEmailSwitch,
                              value: snapshot.shouldSendEmail,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      child: Text(
                        // "Select Estimate Items",
                        AppLocalizations.of(context)!.nN_103,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    BoqItemSelector(
                      value: snapshot,
                      controller: widget.controller as BoqWizardController,
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: FilledButton(
                onPressed: handleInitNext,
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
                // child: const Text("Next >>"),
                child: Text(AppLocalizations.of(context)!.nN_1010),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void init() {
    boqEstimateNameTextController.value = boqEstimateNameTextController.value.copyWith(
      text: widget.controller.value.estimateName,
    );
    super.init();
  }

  @override
  void handleFormControllerEvent() {
    try {
      final value = widget.controller.value;

      boqEstimateNameTextController.value = boqEstimateNameTextController.value.copyWith(
        text: value.estimateName,
      );
    } on Exception catch (_) {}
    super.handleFormControllerEvent();
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }
}

class BoqItemSelector extends StatefulWidget {
  const BoqItemSelector({
    super.key,
    required this.value,
    required this.controller,
  });

  final BoqWizardStateValue value;
  final BoqWizardController controller;

  @override
  State<BoqItemSelector> createState() => _BoqItemSelectorState();
}

class _BoqItemSelectorState extends State<BoqItemSelector> {
  late Future<List<BoqConfigDto>> action;

  Future<List<BoqConfigDto>> fetchConfig() async {
    return locate<RestService>().getBoqConfig();
  }

  @override
  void initState() {
    action = fetchConfig();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: action,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          if (snapshot.hasData) {
            return Column(
              children: [
                ...snapshot.data!.map((boqItem) {
                  Widget child = const SizedBox.shrink();
                  switch (boqItem.name) {
                    case "Concrete Calculation":
                      child = BoqCalculationListItem(
                        imageUrl: boqItem.imageUrl,
                        onChecked: (_) => widget.controller.toggleExtValue(
                          BoqWizardEstType.concrete,
                          ConcreteEstFormController(
                            title: boqItem.data?['boqName'],
                            extra: boqItem.data,
                          ),
                        ),
                        isChecked: widget.value.formControllers.containsKey(
                          BoqWizardEstType.concrete,
                        ),
                        title: boqItem.data?['boqName'],
                        subtitle: boqItem.data?['boqDescription'],
                      );
                      break;
                    case "Plaster Calculation":
                      child = BoqCalculationListItem(
                        imageUrl: boqItem.imageUrl,
                        onChecked: (_) => widget.controller.toggleExtValue(
                          BoqWizardEstType.plaster,
                          PlasterEstFormController(
                            title: boqItem.data?['boqName'],
                            extra: boqItem.data,
                          ),
                        ),
                        isChecked: widget.value.formControllers.containsKey(
                          BoqWizardEstType.plaster,
                        ),
                        title: boqItem.data?['boqName'],
                        subtitle: boqItem.data?['boqDescription'],
                      );
                      break;
                    case "Brick Work Calculation":
                      child = BoqCalculationListItem(
                        imageUrl: boqItem.imageUrl,
                        onChecked: (_) => widget.controller.toggleExtValue(
                          BoqWizardEstType.brickWork,
                          BrickEstFormController(
                            title: boqItem.data?['boqName'],
                            extra: boqItem.data,
                          ),
                        ),
                        isChecked: widget.value.formControllers.containsKey(
                          BoqWizardEstType.brickWork,
                        ),
                        title: boqItem.data?['boqName'],
                        subtitle: boqItem.data?['boqDescription'],
                      );
                      break;
                    case "Flooring Calculation":
                      child = BoqCalculationListItem(
                        imageUrl: boqItem.imageUrl,
                        onChecked: (_) => widget.controller.toggleExtValue(
                          BoqWizardEstType.flooring,
                          FlooringEstFormController(
                            title: boqItem.data?['boqName'],
                            extra: boqItem.data,
                          ),
                        ),
                        isChecked: widget.value.formControllers.containsKey(
                          BoqWizardEstType.flooring,
                        ),
                        title: boqItem.data?['boqName'],
                        subtitle: boqItem.data?['boqDescription'],
                      );
                      break;
                    case "Paint Calculation":
                      child = BoqCalculationListItem(
                        imageUrl: boqItem.imageUrl,
                        onChecked: (_) => widget.controller.toggleExtValue(
                          BoqWizardEstType.paint,
                          PaintEstFormController(
                            title: boqItem.data?['boqName'],
                            extra: boqItem.data,
                          ),
                        ),
                        isChecked: widget.value.formControllers.containsKey(
                          BoqWizardEstType.paint,
                        ),
                        title: boqItem.data?['boqName'],
                        subtitle: boqItem.data?['boqDescription'],
                      );
                      break;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: child,
                  );
                }).toList(),
              ],
            );
          }

          return const SizedBox.shrink();
        });
  }
}

class BoqCalculationListItem extends StatelessWidget {
  const BoqCalculationListItem({
    super.key,
    required this.onChecked,
    required this.isChecked,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  final void Function(bool?) onChecked;
  final bool isChecked;
  final String title;
  final String subtitle;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChecked(!isChecked),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: const BoxDecoration(
          color: Color(0xFFF0F0F0),
        ),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                errorBuilder: (context, _, __) => Container(
                  alignment: Alignment.center,
                  decoration: const ShapeDecoration(
                    shape: CircleBorder(),
                    color: Color(0xFFE9BBBA),
                  ),
                  child: const Icon(
                    Icons.question_mark_rounded,
                    color: AppColors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Checkbox(
              onChanged: onChecked,
              value: isChecked,
            )
          ],
        ),
      ),
    );
  }
}

class BoqInvoicePage extends StatefulWidget {
  BoqInvoicePage({super.key, required this.onBack, required this.controller});

  final BoqWizardController controller;
  // final Boq boq;

  final void Function() onBack;

  @override
  State<BoqInvoicePage> createState() => _BoqInvoicePageState();
}

class _BoqInvoicePageState extends State<BoqInvoicePage> {
  late final boq = Boq(widget.controller, context);

  handleSaveEstimate(BuildContext context) async {
    try {
      locate<ProgressIndicatorController>().show();
      final estimate = boq.generate();

      List<Map<String, dynamic>> boqs = estimate.map((item) {
        final m0 = {
          "name": item.title,
          "unitType": item.unitType,
          "ests": item.quantities
              .map((item) => {
                    "title": item['name'],
                    "value": item['value'],
                    "unit": item['unit'],
                  })
              .toList(),
          "footer": item.footers,
        };

        if (item.type != null) {
          m0.addAll({
            "type": {
              "title": item.type?['code'],
              "value": item.type?['displayName'],
            },
          });
        }

        return m0;
      }).toList();

      final pdfData = await generateBoqPdf({"boqs": boqs, "name": boq.name});
      final base64EncodedFile = base64Encode(pdfData);

      String? path = await locate<RestService>().uploadBase64EncodeAsync(
        "data:application/pdf;base64,$base64EncodedFile",
      );

      if (path == null) throw Exception();

      Map<String, dynamic> data = {
        "pdf": path,
        "boqs": boqs,
      };

      final boqReference = await locate<RestService>().saveBoq(
        shouldSendEmail: widget.controller.value.shouldSendEmail,
        boqName: boq.name,
        data: data,
      );

      if (boqReference == null) return;

      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Successfully saved",
          subtitle: "BOQ receipt saved successfully",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );

      final pdfReference = await locate<RestService>().generateBoqEstimationDocument(
        id: boqReference.boqEstimationId!,
      );

      if (pdfReference == null) return;

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return Material(
                child: BoqFinalizeView(
                  name: boqReference.name ?? "",
                  pdfPath: pdfReference,
                  shouldSendEmail: widget.controller.value.shouldSendEmail,
                ),
              );
            },
          ),
        );
      }
    } on DuplicateBoqEstimateException {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Duplicate estimation name",
          subtitle: "Estimation name already exists",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } catch (err) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Something went wrong",
          subtitle: err.toString(),
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } finally {
      locate<ProgressIndicatorController>().hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: ValueListenableBuilder(
              valueListenable: widget.controller,
              builder: (context, value, child) {
                return BoqView(
                  onBack: widget.onBack,
                  data: boq.generate(),
                  name: widget.controller.value.estimateName,
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: FilledButton(
            onPressed: () => handleSaveEstimate(context),
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
            // child: const Text("Save Estimate"),
            child: Text(AppLocalizations.of(context)!.nN_122),
          ),
        )
      ],
    );
  }
}

class EstimateHeader extends StatelessWidget {
  const EstimateHeader({super.key, required this.onBack});

  final Function() onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Text(
              // "ESTIMATE CALCULATION",
              AppLocalizations.of(context)!.nN_1073.toUpperCase(),
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

class BoqView extends StatelessWidget {
  const BoqView({
    super.key,
    required this.data,
    required this.name,
    this.onBack,
  });

  final String name;
  final List<Estimate> data;
  final Function()? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onBack != null)
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 25),
            child: EstimateHeader(onBack: onBack!),
          ),
        if (name != "")
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        Column(
          children: [
            ...data
                .map(
                  (est) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: BoqInvoiceItem(
                      title: est.title,
                      quantities: est.quantities,
                      footers: est.footers,
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ],
    );
  }
}

class BoqInvoiceItem extends StatelessWidget {
  const BoqInvoiceItem({
    super.key,
    required this.title,
    required this.quantities,
    required this.footers,
  });

  final String title;
  final List<Map<String, dynamic>> quantities;
  final List<Map<String, String>> footers;

  Widget renderSubItem(BuildContext context, String material, String qty) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(material), Text(qty)],
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
            // "$title BOQ",
            AppLocalizations.of(context)!.nN_121(title),
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
                    Text(AppLocalizations.of(context)!.nN_118, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(AppLocalizations.of(context)!.nN_119, style: const TextStyle(fontWeight: FontWeight.bold))
                  ],
                ),
              ),
              const Divider(height: 1),
              ...quantities.map(
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

class BoqFinalizeView extends StatelessWidget {
  const BoqFinalizeView({super.key, required this.pdfPath, required this.name, this.shouldSendEmail = false});

  final bool shouldSendEmail;
  final String pdfPath;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  // "YOUR ESTIMATE SAVED!",
                  AppLocalizations.of(context)!.nN_124.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  if (shouldSendEmail)
                    TextSpan(
                      // "Your estimate is saved and a PDF copy of the estimate has been emailed to you.
                      // Alternatively, you can share this estimate with others below."
                      text: AppLocalizations.of(context)!.nN_1075,
                    ),
                  if (!shouldSendEmail)
                    TextSpan(
                      // "You can share this estimate with others below.",
                      text: AppLocalizations.of(context)!.nN_1076,
                    )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ShareEstimateButton(
                link: pdfPath,
                subject: name,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShareEstimateButton extends StatelessWidget {
  const ShareEstimateButton({
    super.key,
    required this.link,
    required this.subject,
  });

  final String link;
  final String subject;

  handleShare() async {
    Share.share(link, subject: subject);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: handleShare,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            // "Share Estimate",
            AppLocalizations.of(context)!.nN_1074,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.share),
        ],
      ),
    );
  }
}

class Estimate {
  String title;
  String? unitType;
  Map<String, dynamic>? type;
  List<Map<String, dynamic>> quantities;
  List<Map<String, String>> footers;

  Estimate({
    this.type,
    required this.title,
    required this.unitType,
    required this.quantities,
    required this.footers,
  });
}

class Boq {
  final BoqWizardController controller;

  final BuildContext context;

  Boq(this.controller, this.context);

  Map<String, dynamic> getQty(String key, EstFormController controller) {
    switch (key) {
      case BoqWizardEstType.concrete:
        final typedController = controller as ConcreteEstFormController;
        return {
          "type": typedController.value.type,
          "footerTitle": "Total Volume of ${typedController.title}",
          ...calculateConcreteEst(
            type: typedController.value.type!['code'],
            unitType: typedController.value.unitType!,
            length: typedController.value.dLength,
            lengthUnit: typedController.value.lengthUnit,
            width: typedController.value.dWidth,
            widthUnit: typedController.value.widthUnit,
            depth: typedController.value.dDepth,
            depthUnit: typedController.value.depthUnit,
          )
        };
      case BoqWizardEstType.plaster:
        final typedController = controller as PlasterEstFormController;
        return {
          "type": typedController.value.type,
          "footerTitle": "Total Area of ${typedController.title}",
          // "footerTitle": AppLocalizations.of(context)!.nN_120(typedController.title),
          ...calculatePlasterEst(
            type: typedController.value.type!['code'],
            unitType: typedController.value.unitType!,
            length: typedController.value.dLength,
            lengthUnit: typedController.value.lengthUnit,
            width: typedController.value.dWidth,
            widthUnit: typedController.value.widthUnit,
          )
        };
      case BoqWizardEstType.brickWork:
        final typedController = controller as BrickEstFormController;
        return {
          "type": typedController.value.type,
          "footerTitle": "Total Area of ${typedController.title}",
          // "footerTitle": AppLocalizations.of(context)!.nN_120(typedController.title),
          ...calculateBrickWorkEst(
            type: typedController.value.type!['code'],
            unitType: typedController.value.unitType!,
            length: typedController.value.dLength,
            lengthUnit: typedController.value.lengthUnit,
            width: typedController.value.dWidth,
            widthUnit: typedController.value.widthUnit,
          )
        };
      case BoqWizardEstType.flooring:
        final typedController = controller as FlooringEstFormController;
        return {
          "footerTitle": "Total Area of ${typedController.title}",
          // "footerTitle": AppLocalizations.of(context)!.nN_120(typedController.title),
          ...calculateFlooringEst(
            unitType: typedController.value.unitType!,
            length: typedController.value.dLength,
            lengthUnit: typedController.value.lengthUnit,
            width: typedController.value.dWidth,
            widthUnit: typedController.value.widthUnit,
          )
        };
      case BoqWizardEstType.paint:
        final typedController = controller as PaintEstFormController;
        return {
          "footerTitle": "Total Area of ${typedController.title}",
          // "footerTitle": AppLocalizations.of(context)!.nN_120(typedController.title),
          ...calculatePaintEst(
            length: typedController.value.dLength,
            lengthUnit: typedController.value.lengthUnit,
            width: typedController.value.dWidth,
            widthUnit: typedController.value.widthUnit,
          )
        };
    }
    return {};
  }

  List<Estimate> generate() {
    return controller.value.formControllers.keys.map((key) {
      final value = controller.value.formControllers[key];
      final qty = getQty(key, value!);
      return Estimate(
        type: qty['type'],
        title: value.title,
        unitType: qty['volumeUnit'],
        quantities: qty['values'],
        footers: [
          {
            "title": qty['footerTitle'],
            "value": "${qty['volume']} ${qty['volumeUnit']}",
          }
        ],
      );
    }).toList();
  }

  String get name => controller.value.estimateName;
}

Future<Uint8List> generateBoqPdf(Map<String, dynamic> data) async {
  final pdf = pw.Document();

  pw.Widget buildTextColumn(String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      child: pw.Text(value),
    );
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                data['name'],
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              ...data['boqs']
                  .map(
                    (item) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 10),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("${item['name']}"),
                          pw.Table(
                            columnWidths: const {
                              0: pw.FlexColumnWidth(),
                              1: pw.FlexColumnWidth(),
                            },
                            border: pw.TableBorder.all(width: 1),
                            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                            children: [
                              ...(item['ests'] as List)
                                  .map(
                                    (est) => pw.TableRow(
                                      children: [
                                        buildTextColumn(est['title']),
                                        buildTextColumn('${est['value']} ${est['unit']}'),
                                      ],
                                    ),
                                  )
                                  .toList(),
                              ...(item['footer'] as List)
                                  .map(
                                    (est) => pw.TableRow(
                                      children: [
                                        buildTextColumn(est['title']),
                                        buildTextColumn(est['value']),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList()
            ],
          ),
        );
      },
    ),
  );

  return pdf.save();
}
