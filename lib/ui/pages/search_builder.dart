import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nawa_niwasa/ui/ui.dart';

import '../../l10n.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../ecommerce/map.dart';

class ViewBuildersPage extends StatefulWidget {
  const ViewBuildersPage({Key? key}) : super(key: key);

  @override
  State<ViewBuildersPage> createState() => _ViewBuildersPageState();
}

class _ViewBuildersPageState extends State<ViewBuildersPage> {
  Future? future;

  FilterByBuilderName filterByText = FilterByBuilderName("");

  fetchData() async {
    final builderTypes = await locate<RestService>().getAllJobTypes();
    locate<BuilderJobTypesValueNotifier>().setData(builderTypes);
    final builders = await locate<RestService>().getBuildersByCurrentLocation();
    locate<BuildersValueNotifier>().setData(builders);
  }

  @override
  void initState() {
    super.initState();
    future = fetchData();
    BuildersValueNotifier notifier = locate<BuildersValueNotifier>();
    notifier.clearFilters();
    notifier.addFilter(filterByText);
  }

  handleBuilderSelect(BuildContext context, String nic) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => StandaloneBuilderProfileView(
        nic: nic,
        // mobile: mobile,
      ),
    ));
  }

  handleSearchByLocation() async {
    final ld = await locate<DeviceLocationService>().location;
    if (context.mounted && ld.latitude != null && ld.longitude != null) {
      final LatLng? coordinates = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return LocationSelector(
            // title: "Select Location",
            title: AppLocalizations.of(context)!.nN_1057,
            initialPosition: LatLng(ld.latitude!, ld.longitude!),
            onDone: (coordinates) => Navigator.of(context).pop(coordinates),
          );
        }),
      );
      if (coordinates != null) {
        final updated = await locate<RestService>().updateDeviceLocation(
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
        );
        if (updated) {
          setState(() {
            future = fetchData();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),

          /// Filter count indicator
          // ValueListenableBuilder(
          //     valueListenable: locate<BuildersValueNotifier>(),
          //     builder: (context, snapshot, _) {
          //       return Text("${snapshot.filters.length}");
          //     }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      BuildersValueNotifier notifier = locate<BuildersValueNotifier>();
                      notifier.replaceFilter(filterByText, filterByText..text = value);
                    },
                    cursorColor: Colors.red,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 30,
                      ),
                      // hintText: 'Search Builders',
                      hintText: AppLocalizations.of(context)!.nN_066,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext context) {
                        return BuildersFilterBottomSheet(onClose: Navigator.of(context).pop);
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.tune_rounded,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: handleSearchByLocation,
                  icon: const Icon(
                    Icons.location_on_outlined,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return const StandaloneJobFormView();
                }),
              ),
              style: ButtonStyle(
                visualDensity: VisualDensity.standard,
                minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                backgroundColor: MaterialStateProperty.all(AppColors.red),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
              ),
              child: Text(
                // 'Post a Job',
                AppLocalizations.of(context)!.nN_069,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) return Text(snapshot.error.toString());

                return AnimatedBuilder(
                  animation: Listenable.merge([
                    locate<BuildersValueNotifier>(),
                    locate<BuilderJobTypesValueNotifier>(),
                  ]),
                  builder: (context, child) {
                    final builders = locate<BuildersValueNotifier>().value.withFilters;

                    if(builders.isEmpty){
                      return const Center(
                        child: EmptyDataIndicator(
                          message: "No Builders Available",
                          description: "There are no builder in your area",
                        ),
                      );
                    }
                    // List<JobTypeDto> types = locate<BuilderJobTypesValueNotifier>().value;
                    return ListView(
                      shrinkWrap: true,
                      children: builders
                          .map((value) => BuilderCard(
                                onSelect: () => handleBuilderSelect(context, value.nicNumber!),
                                name: value.displayName,
                                rating: value.rating ?? 0,
                                distance: value.distance ?? "N/A",
                                numberOfJobs: "${value.numberOfJobs ?? 0} jobs",
                                job: value.jobType ?? "N/A",
                                status: "Available",
                                imagePath: value.profileImageUrl ?? "",
                              ))
                          .toList(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BuilderCard extends StatelessWidget {
  const BuilderCard({
    super.key,
    required this.name,
    required this.rating,
    required this.distance,
    required this.numberOfJobs,
    required this.job,
    required this.status,
    required this.imagePath,
    required this.onSelect,
  });
  final String name;
  final double rating;
  final String distance;
  final String numberOfJobs;
  final String job;
  final String status;
  final String imagePath;

  final void Function() onSelect;

  @override
  Widget build(BuildContext context) {
    Color circleColor;
    if (status == 'Available') {
      circleColor = Colors.green;
    } else {
      circleColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GestureDetector(
        onTap: onSelect,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          child: Container(
            color: const Color(0xFFE5E5E5),
            height: 200.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            if (index < rating.floor()) {
                              return const Icon(Icons.star, color: Color(0xFFDFB300), size: 16);
                            } else if (index == rating.floor() && rating % 1 != 0) {
                              return const Icon(Icons.star_half, color: Color(0xFFDFB300), size: 16);
                            } else {
                              return const Icon(Icons.star, color: Color(0xFF50555C), size: 16);
                            }
                          }),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        FittedBox(
                          child: Text(
                            distance,
                            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                  color: const Color(0xFF6E6E70),
                                ),
                          ),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        FittedBox(
                          child: Text(
                            numberOfJobs,
                            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                  color: const Color(0xFF6E6E70),
                                ),
                          ),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Text(
                          job,
                          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                color: const Color(0xFFDA4540),
                              ),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: circleColor,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            FittedBox(
                              child: Text(
                                status,
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                      color: const Color(0xFF000000),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black12,
                      ),
                      child: Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, __) {
                          return const Icon(
                            Icons.perm_identity_rounded,
                            size: 50,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BuildersFilterBottomSheet extends StatelessWidget {
  const BuildersFilterBottomSheet({super.key, required this.onClose});

  static final filterByBuilderJobTypes = FilterByBuilderJobTypes([]);

  final void Function() onClose;

  filter(String type) {
    BuildersValueNotifier notifier = locate<BuildersValueNotifier>();

    if (!notifier.value.filters.contains(filterByBuilderJobTypes)) {
      notifier.value.filters.add(filterByBuilderJobTypes);
    }

    notifier.replaceFilter(filterByBuilderJobTypes, filterByBuilderJobTypes.toggle(type));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onClose,
            child: const Center(
              child: Icon(
                Icons.keyboard_arrow_down_outlined,
                color: Colors.black26,
                size: 35,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: FittedBox(
              child: Text(
                // "Sorting & Filtering",
                AppLocalizations.of(context)!.nN_1006,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              // "Builder Skills",
              // "Job Types",
              AppLocalizations.of(context)!.nN_084,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: const Color(0xFF6E6E70), fontWeight: FontWeight.bold),
            ),
          ),
          AnimatedBuilder(
            animation: Listenable.merge([
              locate<BuildersValueNotifier>(),
              locate<BuilderJobTypesValueNotifier>(),
            ]),
            builder: (context, child) {
              return Expanded(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  children: [
                    ...locate<BuilderJobTypesValueNotifier>()
                        .value
                        .map(
                          (jobType) => BuildersFilterItem(
                            title: jobType.jobTypeName ?? "N/A",
                            isSelected: filterByBuilderJobTypes.contains(jobType.jobTypeName),
                            onSelect: () => filter(jobType.jobTypeName!),
                          ),
                        )
                        .toList()
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class BuildersFilterItem extends StatelessWidget {
  const BuildersFilterItem({
    super.key,
    required this.title,
    required this.onSelect,
    this.isSelected = false,
  });

  final String title;
  final void Function() onSelect;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        trailing: Theme(
          data: Theme.of(context).copyWith(
            checkboxTheme: CheckboxThemeData(
              fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return null;
                }
                if (states.contains(MaterialState.selected)) {
                  return Colors.red;
                }
                return null;
              }),
            ),
            switchTheme: SwitchThemeData(
              thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return null;
                }
                if (states.contains(MaterialState.selected)) {
                  return Colors.red;
                }
                return null;
              }),
              trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return null;
                }
                if (states.contains(MaterialState.selected)) {
                  return Colors.red;
                }
                return null;
              }),
            ),
          ),
          child: Checkbox(
            value: isSelected,
            onChanged: (_) => onSelect(),
          ),
        ),
        title: Text(title),
      ),
    );
  }
}
