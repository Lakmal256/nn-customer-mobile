import 'package:flutter/material.dart';

import '../l10n.dart';

class PopupController extends ValueNotifier<List<Widget>> {
  PopupController() : super([]);

  addItem(Widget widget) {
    value.add(widget);
    notifyListeners();
  }

  addItemFor(Widget widget, Duration duration) async {
    addItem(widget);
    await Future.delayed(duration, () => removeItem(widget));
  }

  removeItem(Widget widget) {
    value.remove(widget);
    notifyListeners();
  }

  clear() {
    value.clear();
    notifyListeners();
  }
}

class PopupContainer extends StatelessWidget {
  const PopupContainer({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Column(children: children),
        ),
      ),
    );
  }
}

class DismissiblePopup extends StatelessWidget {
  const DismissiblePopup({
    Key? key,
    required this.onDismiss,
    required this.color,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final Function(Widget) onDismiss;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: GlobalKey(),
      child: AlertCard(
        child: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600, color: color),
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            OutlinedButton(
              style: const ButtonStyle(
                textStyle: MaterialStatePropertyAll(TextStyle(color: Colors.black)),
                shape: MaterialStatePropertyAll(StadiumBorder())
              ),
              onPressed: () => onDismiss(this),
              // child: const Text("Ok"),
              child: Text(AppLocalizations.of(context)!.nN_022),
            ),
          ],
        ),
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  const AlertCard({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: .5, color: Colors.black26),
          borderRadius: BorderRadius.circular(15),
        ),
        child: child);
  }
}
