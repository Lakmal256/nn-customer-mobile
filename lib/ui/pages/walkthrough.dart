import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../ui.dart';

class SplashWalkthrough extends StatefulWidget {
  const SplashWalkthrough({Key? key, required this.onDone}) : super(key: key);

  final void Function() onDone;

  @override
  State<SplashWalkthrough> createState() => _SplashWalkthroughState();
}

class _SplashWalkthroughState extends State<SplashWalkthrough> {
  static const List _imagePaths = [
    "assets/images/bg_002.png",
    "assets/images/bg_003.png"
  ];

  late int index;

  @override
  void initState() {
    index = 0;
    super.initState();
  }

  next() {
    if(index == 1) {
      return widget.onDone();
    }

    setState(() {
      index = index == 0 ? 1 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    String url = _imagePaths[index];
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            url,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 7,
                      child: Image.asset(
                        "assets/images/tm_001.png",
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 25),
                //   child: (index == 0)
                //       ? _Content(message: AppLocalizations.of(context)!.splash_message_001)
                //       : _Content(message: AppLocalizations.of(context)!.splash_message_002),
                // ),
                const SizedBox(height: 50),
                PageIndicator(
                  length: 2,
                  index: index,
                ),
                const Expanded(child: SizedBox()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: FilledButton(
                    onPressed: next,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      foregroundColor: MaterialStateProperty.all(Theme.of(context).textTheme.titleSmall?.color),
                    ),
                    child: const Text("Next"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({Key? key, required this.message}) : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4.2,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          message,
          style: const TextStyle(color: AppColors.blue),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  PageIndicator({Key? key, required int length, int index = 0})
      : items = List.generate(length, (i) => i == index),
        super(key: key);

  final List<bool> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items
          .map(
            (active) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              height: 5,
              width: 25,
              color: active ? AppColors.blue : Colors.grey,
            ),
          )
          .toList(),
    );
  }
}
