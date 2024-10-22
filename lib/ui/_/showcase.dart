import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Showcase extends StatelessWidget {
  const Showcase({Key? key, required this.page}) : super(key: key);

  final Widget page;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ShowcaseNavigator(),
      body: page,
    );
  }
}

class ShowcaseNavigatorLink {
  String name;
  String path;

  ShowcaseNavigatorLink(this.name, this.path);
}

List<ShowcaseNavigatorLink> _links = [
  ShowcaseNavigatorLink("Typography", "/typography"),
  ShowcaseNavigatorLink("Widgets", "/widgets"),
  ShowcaseNavigatorLink("Form", "/form"),
];

class ShowcaseNavigator extends StatelessWidget implements PreferredSizeWidget {
  const ShowcaseNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: _links
                  .map(
                    (link) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FilledButton(
                        onPressed: () => context.go(link.path),
                        child: Text(link.name),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const Divider(height: 1)
      ],),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
