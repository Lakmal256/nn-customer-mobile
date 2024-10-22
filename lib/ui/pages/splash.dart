import 'package:flutter/material.dart';

import '../../locator.dart';
import '../../service/service.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key, required this.onDone}) : super(key: key);

  final Function(bool hasSession) onDone;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {

  @override
  void initState() {
    handleSplash();
    super.initState();
  }

  Future handleSplash() async {
    // try {
    //   await locate<TokenProvider>().getToken();
    //   final bool hasSession = locate<TokenProvider>().hasSession;
    //   widget.onDone(hasSession);
    // } catch (error) {
    //   widget.onDone(false);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
