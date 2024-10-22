import 'package:flutter/material.dart';
import '../../l10n.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../ui.dart';

class ComplaintView extends StatefulWidget {
  final ComplaintDto data;

  const ComplaintView({super.key, required this.data});

  @override
  State<ComplaintView> createState() => _ComplaintViewState();
}

class _ComplaintViewState extends State<ComplaintView> {
  late Future action;
  late String? productCategoryName = "N/A";
  late String? productName = "N/A";

  @override
  void initState() {
    action = fetchDetails();
    super.initState();
  }

  fetchDetails() async {
    try {
      final categories = await locate<RestService>().getAllProductCategories();
      final products = await locate<RestService>().getAllProductsByCategory(id: widget.data.productCategoryId!);
      setState(() {
        productCategoryName = categories
            .firstWhere(
              (item) => item.id == widget.data.productCategoryId,
            )
            .name;
        if (products != null) {
          productName = products
              .firstWhere(
                (item) => item.id == widget.data.productId,
              )
              .name;
        }
      });
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: action,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(10),
                  //     border: Border.all(width: 1, color: Colors.black12),
                  //   ),
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  //     child: Placeholder(),
                  //   ),
                  // ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10), border: Border.all(width: 1, color: Colors.black12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ComplaintDetailItem(
                            // title: "Status",
                            title: AppLocalizations.of(context)!.nN_180,
                            child: ComplaintStatusBadge(status: widget.data.complaintStatus),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          ComplaintDetailItem(
                            // title: "Product Category",
                            title: AppLocalizations.of(context)!.nN_185,
                            child: Text(productCategoryName ?? "N/A"),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          ComplaintDetailItem(
                            // title: "Product",
                            title: AppLocalizations.of(context)!.nN_187,
                            child: Text(productName ?? "N/A"),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          ComplaintDetailItem(
                            // title: "Name",
                            title: AppLocalizations.of(context)!.nN_190,
                            child: Text(widget.data.name ?? "N/A"),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          ComplaintDetailItem(
                            // title: "Business Name",
                            title: AppLocalizations.of(context)!.nN_191,
                            child: Text(widget.data.businessName ?? "N/A"),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          ComplaintDetailItem(
                            // title: "Contact Number",
                            title: AppLocalizations.of(context)!.nN_015,
                            child: Text(widget.data.contactNumber ?? "N/A"),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          ComplaintDetailItem(
                            // title: "Location",
                            title: AppLocalizations.of(context)!.nN_073,
                            child: Text(widget.data.location ?? "N/A"),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          ComplaintDetailItem(
                            // title: "Description",
                            title: AppLocalizations.of(context)!.nN_089,
                            child: Text(widget.data.description ?? "N/A"),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          ComplaintDetailItem(
                            // title: "Created Date",
                            title: AppLocalizations.of(context)!.nN_098,
                            child: Text(widget.data.createdDate ?? "N/A"),
                          ),
                          const SizedBox(height: 10),
                          // const Divider(),
                          // ComplaintDetailItem(
                          //   // title: "Last Modified Date",
                          //   title: AppLocalizations.of(context)!.nN_180,
                          //   child: Text(widget.data.lastModifiedDate ?? "N/A"),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: widget.data.complaintImageList?.isNotEmpty ?? false,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 1, color: Colors.black12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: ComplaintDetailItem(
                          title: "Images",
                          child: SizedBox(
                            height: 200,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                ...(widget.data.complaintImageList ?? [])
                                    .map(
                                      (item) => Row(
                                        children: [
                                          Image.network(
                                            item,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, _) => Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  border: Border.all(width: 1, color: Colors.redAccent),
                                                  borderRadius: BorderRadius.circular(10)),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.error_outline_rounded),
                                                  const Text("File not loaded"),
                                                  Text(item),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10)
                                        ],
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ComplaintDetailItem extends StatelessWidget {
  final String title;
  final Widget child;

  const ComplaintDetailItem({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
