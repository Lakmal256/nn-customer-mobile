import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n.dart';
import '../../locator.dart';
import '../../service/service.dart';

import '../boq/boq.dart';
import '../colors.dart';

class BoqWizardView extends StatefulWidget {
  const BoqWizardView({super.key});

  @override
  State<BoqWizardView> createState() => _BoqWizardViewState();
}

class _BoqWizardViewState extends State<BoqWizardView> with SingleTickerProviderStateMixin {
  late TabController tabController;
  late BoqWizardController boqWizardController;
  late ConcreteCrackingProbabilityWizardController crackingProbabilityWizardController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    boqWizardController = BoqWizardController(
      initialValue: BoqWizardStateValue.empty(),
    );
    crackingProbabilityWizardController = ConcreteCrackingProbabilityWizardController(
      initialValue: ConcreteCrackingProbabilityWizardStateValue.empty(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: tabController,
            builder: (context, snapshot) {
              return SizedBox(
                height: 58,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: IntrinsicHeight(
                        child: BoqOptionTab(
                          // title: "BOQ Calculators",
                          title: AppLocalizations.of(context)!.nN_092,
                          isActive: tabController.index == 0,
                          onSelect: () => tabController.animateTo(0),
                        ),
                      ),
                    ),
                    Expanded(
                      child: BoqOptionTab(
                        // title: "Concrete Cracking\n Probability Calculator",
                        title: AppLocalizations.of(context)!.nN_093,
                        isActive: tabController.index == 1,
                        onSelect: () => tabController.animateTo(1),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                BoqWizard(
                  controller: boqWizardController,
                ),
                ConcreteCrackingProbabilityWizard(
                  controller: crackingProbabilityWizardController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BoqOptionTab extends StatelessWidget {
  const BoqOptionTab({
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        color: isActive ? const Color(0xFFEE1C25) : const Color(0xFFD9D9D9),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.w600 : null,
                color: isActive ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class AllBoqView extends StatefulWidget {
  const AllBoqView({super.key});

  @override
  State<AllBoqView> createState() => _AllBoqViewState();
}

class _AllBoqViewState extends State<AllBoqView> {
  late Future<List<BoqDto>> action;

  Future<List<BoqDto>> fetchData() async {
    return locate<RestService>().getAllEstimations();
  }

  @override
  void initState() {
    action = fetchData();
    super.initState();
  }

  handleBoqView(BuildContext context, BoqDto data) async {
    var name = data.name ?? "N/A";
    var pdfPath = await locate<RestService>().generateBoqEstimationDocument(id: data.boqEstimationId!);
    if (pdfPath == null) return;
    var estimates = (data.data?['boqs'] ?? [])
        .map<Estimate>(
          (value) => Estimate(
            unitType: value['unitType'],
            title: value['name'],
            quantities: (value['ests'] as List)
                .map((item) => {
                      "name": item["title"],
                      "value": item["value"],
                      "unit": item["unit"],
                    })
                .toList(),
            footers: (value['footer'] as List)
                .map((item) => {
                      "title": item['title'] as String,
                      "value": item['value'] as String,
                    })
                .toList(),
          ),
        )
        .toList();
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return Material(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: BoqView(
                        data: estimates,
                        name: name,
                        onBack: Navigator.of(context).pop,
                      ),
                    ),
                  ),
                  ShareEstimateButton(
                    link: pdfPath,
                    subject: name,
                  )
                ],
              ),
            );
          },
        ),
      );
    }
  }

  Future handleRefresh() async {
    return setState(() {
      action = fetchData();
    });
  }

  handleOptions(BoqDto boqDto) async {
    BoqBottomSheetOption? option = await showBoqItemBottomSheet(context, boqDto);
    if (option == null) return;

    if (context.mounted) {
      switch (option) {
        case BoqBottomSheetOption.view:
          handleBoqView(context, boqDto);
        case BoqBottomSheetOption.delete:
          if (boqDto.boqEstimationId == null) return;
          await locate<RestService>().deleteBoq(boqDto.boqEstimationId!);
          handleRefresh();
        case BoqBottomSheetOption.download:
          var pdfPath = await locate<RestService>().generateBoqEstimationDocument(id: boqDto.boqEstimationId!);
          launchUrl(
            Uri.parse(pdfPath!),
            mode: LaunchMode.externalApplication,
          );
      }
    }
  }

  Widget buildEstItem(BuildContext context, BoqDto boqDto) {
    return InkWell(
      onTap: () => handleBoqView(context, boqDto),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: [
            const Icon(
              Icons.file_present_outlined,
              color: Colors.black26,
              size: 50,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    boqDto.name ?? "N/A",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(boqDto.lastModifiedDate ?? "N/A"),
                ],
              ),
            ),
            IconButton.outlined(
              onPressed: () => handleOptions(boqDto),
              icon: const Icon(Icons.more_horiz_rounded),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  // "YOUR ESTIMATES",
                  AppLocalizations.of(context)!.nN_1009.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(thickness: 1),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.standard,
                      onPressed: () => GoRouter.of(context).push("/create-boq"),
                      icon: Container(
                        constraints: const BoxConstraints.expand(),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.red,
                        ),
                        child: const FittedBox(
                          fit: BoxFit.fill,
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: action,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  // return const Center(child: Text("Error!"));
                  return Center(child: Text(snapshot.error.toString()));
                }

                /// when data list is empty
                if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.black26,
                            size: 50,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // "No estimates found. Tap add button to create an estimate.",
                                Text(AppLocalizations.of(context)!.nN_1033),
                                const SizedBox(height: 10),
                                TextButton.icon(
                                  onPressed: handleRefresh,
                                  icon: const Icon(Icons.refresh_rounded),
                                  // "Refresh",
                                  label: Text(AppLocalizations.of(context)!.nN_1032),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: handleRefresh,
                  child: ListView(
                    children: (snapshot.data ?? []).map((value) => buildEstItem(context, value)).toList(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: FilledButton(
              onPressed: () => GoRouter.of(context).push("/create-boq"),
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
              // child: const Text("Create New Estimate"),
              child: Text(AppLocalizations.of(context)!.nN_102),
            ),
          ),
        ],
      ),
    );
  }
}

enum BoqBottomSheetOption { view, delete, download }

class BoqBottomSheetView extends StatelessWidget {
  const BoqBottomSheetView({super.key, required this.data});

  final BoqDto data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.file_present_outlined,
                color: Colors.black26,
                size: 50,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name ?? "N/A",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(data.lastModifiedDate ?? "N/A"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 70,
            child: Row(
              children: [
                Expanded(
                  child: BoqItemOptionItem(
                    icon: const Icon(Icons.remove_red_eye_outlined),
                    // text: "View",
                    text: AppLocalizations.of(context)!.nN_1034,
                    action: () => Navigator.of(context).pop(BoqBottomSheetOption.view),
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: BoqItemOptionItem(
                    icon: const Icon(Icons.delete_outline_rounded),
                    // text: "Delete",
                    text: AppLocalizations.of(context)!.nN_1035,
                    action: () => Navigator.of(context).pop(BoqBottomSheetOption.delete),
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: BoqItemOptionItem(
                    icon: const Icon(Icons.cloud_download_outlined),
                    // text: "Download",
                    text: AppLocalizations.of(context)!.nN_1036,
                    action: () => Navigator.of(context).pop(BoqBottomSheetOption.download),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BoqItemOptionItem extends StatelessWidget {
  const BoqItemOptionItem({
    super.key,
    required this.text,
    required this.icon,
    required this.action,
  });

  final String text;

  final Widget icon;

  final Function() action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black12,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [icon, Text(text)],
        ),
      ),
    );
  }
}

showBoqItemBottomSheet(BuildContext context, BoqDto data) => showModalBottomSheet(
      context: context,
      builder: (context) => BoqBottomSheetView(data: data),
    );
