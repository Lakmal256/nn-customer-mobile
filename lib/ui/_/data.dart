import 'package:flutter/material.dart';

import '../../locator.dart';
import '../../service/service.dart';
import '../ui.dart';

class DataTestPage extends StatelessWidget {
  const DataTestPage({super.key});

  addFilter() {
    BuildersValueNotifier notifier = locate<BuildersValueNotifier>();
    // notifier.addFilter(filterByText);
  }

  removeFilter() {
    BuildersValueNotifier notifier = locate<BuildersValueNotifier>();
    // notifier.removeFilter(filterByText);
  }

  addData() async {
    BuildersValueNotifier notifier = locate<BuildersValueNotifier>();
    final data = await locate<RestService>().getAllBuilders();
    notifier.setData(data);
  }

  @override
  Widget build(BuildContext context) {
    final data = [
      {
        "name": "Brick Work Calculation",
        "unitType": "m²",
        "type": {"title": "112P5_brick", "value": "Type 112.50"},
        "ests": [
          {"title": "Cement", "value": "0.130", "unit": "bags (50kg)"},
          {"title": "Sand", "value": "0.010", "unit": "m³"},
          {"title": "Bricks", "value": "54.000", "unit": "Nr."}
        ],
        "footer": [
          {"title": "Total Area of Brick Work Calculation", "value": "1.000 m²"}
        ]
      },
      {
        "name": "Flooring Calculation",
        "unitType": "m²",
        "type": {"title": null, "value": null},
        "ests": [
          {"title": "Cement", "value": "0.134", "unit": "bags (50kg)"},
          {"title": "Sand", "value": "0.006", "unit": "m³"},
          {"title": "Tiles", "value": "9.570", "unit": "Nr."},
          {"title": "Adhesive", "value": "0.300", "unit": "(20kg)"}
        ],
        "footer": [
          {"title": "Total Area of Flooring Calculation", "value": "1.000 m²"}
        ]
      }
    ];
    return Scaffold(
      body: ValueListenableBuilder(
          valueListenable: locate<BuildersValueNotifier>(),
          builder: (context, snapshot, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Table",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  ...data
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${item['name']}"),
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(),
                                  1: FlexColumnWidth(),
                                },
                                border: TableBorder.all(width: 1),
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: [
                                  ...(item['ests'] as List)
                                      .map(
                                        (est) => TableRow(
                                          children: [
                                            Text(est['title']),
                                            Text('${est['value']} ${est['unit']}'),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                  ...(item['footer'] as List)
                                      .map(
                                        (est) => TableRow(
                                          children: [
                                            Text(est['title']),
                                            Text(est['value']),
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
            return Column(
              children: [
                ...snapshot.withFilters
                    .map(
                      (value) => BuilderCard(
                        onSelect: () => {},
                        name: "${value.firstName} ${value.secondName}",
                        rating: 4,
                        distance: "300 meters away",
                        numberOfJobs: "45 customer jobs",
                        job: "${value.jobType}",
                        status: "${value.availability}",
                        imagePath: 'assets/images/builder_avatar_2.png',
                      ),
                    )
                    .toList(),
                TextButton(
                  onPressed: addData,
                  child: const Text("Add Data"),
                ),
                TextButton(
                  onPressed: addFilter,
                  child: const Text("Add Filter"),
                ),
                TextButton(
                  onPressed: removeFilter,
                  child: const Text("Remove Filter"),
                ),
              ],
            );
          }),
    );
  }
}
