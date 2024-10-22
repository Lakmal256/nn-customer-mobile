import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'router.dart';
import 'ui/ui.dart';
import 'locator.dart';
import 'l10n.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((event) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: event.notification?.title ?? "",
          subtitle: event.notification?.body ?? "",
          color: Colors.black,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: listenable,
      builder: (context, snapshot) {
        return MaterialApp.router(
          builder: (context, child) => Stack(
            fit: StackFit.expand,
            children: [
              if (child != null) child,

              /// Overlay elements
              if (locate<ProgressIndicatorController>().value) const ProgressIndicatorPopup(),
              ConnectivityIndicator(),
              Align(
                alignment: Alignment.topLeft,
                child: PopupContainer(
                  children: locate<PopupController>().value,
                ),
              )
            ],
          ),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locate<AppLocaleHandler>().value,
          theme: AppTheme.light,
          routerConfig: baseRouter,
        );
      },
    );
  }

  Listenable get listenable => Listenable.merge([
        locate<AppLocaleHandler>(),
        locate<PopupController>(),
        locate<ProgressIndicatorController>(),
      ]);
}
