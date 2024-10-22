import 'package:flutter/material.dart';

import '../widgets.dart' as w;

class WidgetCatalog extends StatelessWidget {
  const WidgetCatalog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: const [
          SizedBox(
            height: 100,
            child: Scaffold(
              appBar: w.AppBarWithNotifications(canGoBack: true,),
            ),
          ),
          Divider()
        ],
      ),
    );
  }
}
