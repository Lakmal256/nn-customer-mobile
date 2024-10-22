import 'package:flutter/material.dart';
import 'package:nawa_niwasa/service/dto.dart';

class JobListItem extends StatelessWidget {
  /// Job Location
  final String slot1;

  /// Job ID
  final String slot2;

  /// Job Type
  final String slot3;

  /// Job Title
  final String slot4;

  /// Job Description
  final String slot5;

  /// Job Status
  final String slot6;

  /// Job Date
  final String slot7;

  /// Job icon path
  final String slot8;

  /// Job accessibility
  final String slot9;

  /// Job Status
  final JobStatus slot10;

  final Function() onSelect;

  const JobListItem({
    super.key,
    required this.slot1,
    required this.slot2,
    required this.slot3,
    required this.slot4,
    required this.slot5,
    required this.slot6,
    required this.slot7,
    required this.slot8,
    required this.slot9,
    required this.slot10,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 5),
              color: Colors.black12,
              blurRadius: 8,
            ),
          ],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      slot3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(slot2),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          slot8,
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, __) => const FittedBox(
                            fit: BoxFit.fill,
                            child: Icon(
                              Icons.person,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      slot4,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.redAccent,
                                  size: 15,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  slot1,
                                  style: const TextStyle(color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: const ShapeDecoration(shape: StadiumBorder(), color: Color(0xFF6E6E70)),
                            child: Text(
                              slot9,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 5),
              child: JobStatusIndicator(
                status: slot10,
                text: slot6,
                extra: Text(
                  slot7,
                  style: const TextStyle(fontSize: 12, color: Colors.black38),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobStatusIndicator extends StatelessWidget {
  const JobStatusIndicator({
    super.key,
    required this.status,
    this.extra,
    required this.text,
  });

  final String text;
  final JobStatus status;
  final Widget? extra;

  Widget buildStatus(BuildContext context) {
    Color color;

    switch (status) {
      case JobStatus.completed:
        color = const Color(0xFF12B418);
      case JobStatus.inProgress:
        color = const Color(0xFF173C79);
      case JobStatus.rejected:
        color = const Color(0xFFEE1C25);
      case JobStatus.pending:
        color = const Color(0xFFFFA500);
      default:
        color = const Color(0xFF000000);
    }

    return Row(
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: color,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(fontSize: 12, height: 1.2),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: buildStatus(context),
          ),
        ),
        const SizedBox(width: 10),
        if (extra != null) extra!,
      ],
    );
  }
}
