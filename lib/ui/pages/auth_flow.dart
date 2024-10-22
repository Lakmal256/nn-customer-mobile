import 'package:flutter/material.dart';

class AuthFlowPage extends StatelessWidget {
  const AuthFlowPage({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image.asset(
          //   "assets/images/bg_003.png",
          //   alignment: Alignment.bottomCenter,
          //   fit: BoxFit.cover,
          //   opacity: Animation.fromValueListenable(ValueNotifier(0.2)),
          // ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}