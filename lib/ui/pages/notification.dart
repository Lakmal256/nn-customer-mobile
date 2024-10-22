import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nawa_niwasa/service/service.dart';

import '../../l10n.dart';
import '../../locator.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late Future? future;

  @override
  void initState() {
    future = locate<InAppNotificationHandler>().sync();
    super.initState();
  }

  handleSelect(NotificationDto item) {
    setState(() {
      future = locate<InAppNotificationHandler>().markAsRead(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator();
              }

              return const SizedBox();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: GoRouter.of(context).pop,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Text(
                  // "Latest Notifications",
                  AppLocalizations.of(context)!.nN_1078,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: locate<InAppNotificationHandler>().sync,
              child: ListView(
                children: locate<InAppNotificationHandler>()
                    .notifications
                    .map((data) => NotificationItem(
                          data: data,
                          onSelect: () => handleSelect(data),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
    required this.data,
    required this.onSelect,
  });

  final NotificationDto data;
  final Function() onSelect;

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;

    /// If the item has not been read yet, it's gray
    if (!data.read) backgroundColor = Colors.black12;

    return GestureDetector(
      onTap: onSelect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: const Border.symmetric(
            horizontal: BorderSide(width: 1, color: Colors.black12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              const NotificationItemIcon(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title ?? "N/A",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      data.body ?? "N/A",
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationItemIcon extends StatelessWidget {
  const NotificationItemIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.black12),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(5),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const FittedBox(
            fit: BoxFit.cover,
            child: Icon(
              Icons.notifications_none_rounded,
              color: Colors.black54,
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
