import 'package:flutter/material.dart';
import 'package:nawa_niwasa/locator.dart';
import 'package:nawa_niwasa/service/service.dart';

import '../../l10n.dart';
import '../ui.dart';

class AllComplaintView extends StatefulWidget {
  const AllComplaintView({super.key});

  @override
  State<AllComplaintView> createState() => _AllComplaintViewState();
}

class _AllComplaintViewState extends State<AllComplaintView> {
  late Future<List<ComplaintDto>> action;
  late String filterValue;

  Future<List<ComplaintDto>> fetchData() async {
    return locate<RestService>().getAllComplaints();
  }

  @override
  void initState() {
    filterValue = "";
    action = fetchData();
    super.initState();
  }

  Future handleRefresh() async {
    return setState(() {
      action = fetchData();
    });
  }

  handleCreateComplaint(BuildContext context) async {
    final controller = ComplaintWizardController(initialValue: ComplaintWizardStateValue());;

    controller.clear();

    FocusManager.instance.primaryFocus?.unfocus();

    final types = await locate<RestService>().getAllComplaintTypes();
    if (context.mounted) {
      controller.type = null;
      final type = await showComplaintTypeSelector(context, controller, types ?? []);
      if (type == null) return;
    }

    final categories = await locate<RestService>().getAllComplaintProductCategories();

    if (context.mounted) {
      controller.productCategory = null;
      final category = await showProductCategorySelector(context, controller, categories ?? []);
      if (category == null) return;
    }

    int? categoryId = controller.value.productCategory?.id;
    final products = await locate<RestService>().getAllProductsByCategory(id: categoryId!);

    var type = controller.value.type;

    /// if type is Technical Assistance product selection is nor required
    if (type?.id != 3) {
      if (context.mounted) {
        controller.product = null;
        final product = await showProductSelector(context, controller, products ?? []);
        if (product == null) return;
      }
    }

    if (context.mounted) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ComplaintWizard(controller: controller),
      ));
    }
  }

  String complaintIdToText(int? id) {
    switch (id) {
      case 3:
        return "Technical Assistance";
      case 2:
        return "Inquiries";
      case 1:
        return "Complaints";
    }
    return "";
  }

  bool handleFilter(ComplaintDto item) {
    if (filterValue == "") return true;

    var id = int.tryParse(filterValue);

    /// Filter by name & id
    return ((item.name ?? "").toLowerCase().contains(filterValue.toLowerCase()) || item.id == id);
  }

  handleItemSelect(ComplaintDto complaint) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ComplaintView(data: complaint);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  // "COMPLAINTS AND INQUIRIES",
                  AppLocalizations.of(context)!.nN_060.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                // const Divider(thickness: 1),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 10, right: 20),
            child: FilledButton(
              onPressed: () => handleCreateComplaint(context),
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
              // child: const Text("Add new complaint"),
              child: Text(AppLocalizations.of(context)!.nN_176),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                // "COMPLAINT HISTORY",
                AppLocalizations.of(context)!.nN_177.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFECECEC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          filterValue = value;
                        });
                      },
                      cursorColor: Colors.red,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        // hintText: 'SEARCH',
                        hintText: AppLocalizations.of(context)!.nN_175,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
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
                  return const Center(child: Text("Error!"));
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
                                // "No complaints found. Tap add new complaint button to create a complaint",
                                Text(AppLocalizations.of(context)!.nN_1031),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ListView(
                      children: snapshot.data!
                          .where((element) => handleFilter(element))
                          .map((value) => ComplaintHistoryCard(
                                onSelect: () => handleItemSelect(value),
                                // title: "Complain Id - ID ${value.id}",
                                title: "${AppLocalizations.of(context)!.nN_178} - ID ${value.id}",
                                // subtitle: "Complaint Type - ${complaintIdToText(value.complaintTypeId)}",
                                subtitle: "${AppLocalizations.of(context)!.nN_179} - ${complaintIdToText(value.complaintTypeId)}",
                                date: value.dateMMMdyyyy ?? "N/A",
                                status: value.complaintStatus ?? "N/A",
                              ))
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ComplaintHistoryCard extends StatelessWidget {
  final Function() onSelect;
  final String title;
  final String date;
  final String subtitle;
  final String status;

  const ComplaintHistoryCard({
    super.key,
    required this.title,
    required this.date,
    required this.subtitle,
    required this.status,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
              ),
              ComplaintStatusBadge(status: status),
            ],
          ),
        ),
      ),
    );
  }
}

class ComplaintStatusBadge extends StatelessWidget {
  final String? status;
  const ComplaintStatusBadge({super.key, required this.status});

  Color getStatusColor(String? status) {
    switch (status) {
      case "NEW":
        return Colors.green;
      case "IN_PROGRESS":
        return Colors.teal;
      case "CLOSED":
        return Colors.indigo;
      case "RESOLVED":
        return const Color(0xFF083657);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: ShapeDecoration(shape: const StadiumBorder(), color: getStatusColor(status)),
      child: Text(
        status ?? "N/A",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// TODO: make this dialog as a shared widget
class SelectionDialog extends StatelessWidget {
  final String title;
  final Widget content;
  const SelectionDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 15),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(color: AppColors.red),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            constraints: const BoxConstraints.tightFor(width: double.infinity),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.cancel_outlined),
                  color: Colors.white,
                ),
              ],
            ),
          ),
          content,
        ],
      ),
    );
  }
}

class SelectorDialog<T> extends StatelessWidget {
  final Function(T? value)? onDone;
  final List<DropdownMenuItem<T>> values;
  final T value;
  final String title;
  final String? hint;
  const SelectorDialog({
    super.key,
    this.hint,
    this.onDone,
    required this.title,
    required this.values,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SelectionDialog(
      title: title,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            DropdownButton<T>(
              value: value,
              isExpanded: true,
              onChanged: onDone,
              underline: const SizedBox.shrink(),
              hint: Text(hint ?? ""),
              padding: const EdgeInsets.only(left: 10),
              items: values,
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: value != null ? () => Navigator.of(context).pop(value) : null,
              style: ButtonStyle(
                visualDensity: VisualDensity.standard,
                minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                backgroundColor: MaterialStateProperty.all(const Color(0xFF878787)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
              ),
              child: const Text("Continue"),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

Future<ComplaintTypeDto?> showComplaintTypeSelector(
  BuildContext context,
  ComplaintWizardController controller,
  List<ComplaintTypeDto> types,
) =>
    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, _) {
          return SelectorDialog(
            // title: "Select type of support",
            title: AppLocalizations.of(context)!.nN_183,
            // hint: "Select a type",
            hint: AppLocalizations.of(context)!.nN_184,
            value: value.type,
            onDone: (type) => controller.type = type,
            values: types
                .map((type) => DropdownMenuItem<ComplaintTypeDto>(
                      value: type,
                      child: Text(type.name ?? "N/A"),
                    ))
                .toList(),
          );
        },
      ),
    );

Future<ComplaintProductCategoryDto?> showProductCategorySelector(
  BuildContext context,
  ComplaintWizardController controller,
  List<ComplaintProductCategoryDto> categories,
) =>
    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, _) {
          return SelectorDialog(
            // title: "Product Category",
            title: AppLocalizations.of(context)!.nN_185,
            // hint: "Select a category",
            hint: AppLocalizations.of(context)!.nN_186,
            value: value.productCategory,
            onDone: (category) => controller.productCategory = category,
            values: categories
                .map((type) => DropdownMenuItem<ComplaintProductCategoryDto>(
                      value: type,
                      child: Text(type.name ?? "N/A"),
                    ))
                .toList(),
          );
        },
      ),
    );

Future<ComplaintProductDto?> showProductSelector(
  BuildContext context,
  ComplaintWizardController controller,
  List<ComplaintProductDto> products,
) =>
    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, _) {
          return SelectorDialog(
            // title: "Product",
            title: AppLocalizations.of(context)!.nN_187,
            // hint: "Select a product",
            hint: AppLocalizations.of(context)!.nN_188,
            value: value.product,
            onDone: (product) => controller.product = product,
            values: products
                .map((type) => DropdownMenuItem<ComplaintProductDto>(
                      value: type,
                      child: Text(type.name ?? "N/A"),
                    ))
                .toList(),
          );
        },
      ),
    );
