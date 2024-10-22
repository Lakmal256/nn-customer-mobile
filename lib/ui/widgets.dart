import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../l10n.dart';
import '../locator.dart';
import '../service/service.dart';
import '../util/util.dart';
import 'ui.dart';

class AppBarWithNotifications extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWithNotifications({Key? key, required this.canGoBack}) : super(key: key);

  final bool canGoBack;

  @override
  Widget build(BuildContext context) {
    Widget icon = const Icon(Icons.menu);

    if (canGoBack) {
      icon = const Icon(Icons.arrow_back_rounded);
    }

    return Container(
      constraints: const BoxConstraints.expand(),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFECECEC),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // icon,
                const SizedBox(),
                if (locate<PermissionService>().request(['toViewNotificationIndicator']))
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: StandaloneNotificationIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class StandaloneNotificationIndicator extends StatelessWidget {
  const StandaloneNotificationIndicator({super.key});

  handleNavigation(BuildContext context) {
    GoRouter.of(context).push("/notification");
  }

  @override
  Widget build(BuildContext context) {
    int count = locate<InAppNotificationHandler>().count;

    return GestureDetector(
      onTap: () => handleNavigation(context),
      child: ListenableBuilder(
        listenable: locate<InAppNotificationHandler>(),
        builder: (context, _) {
          return NotificationIndicator(
            value: count > 0 ? count.toString() : null,
          );
        },
      ),
    );
  }
}

class NotificationIndicator extends StatelessWidget {
  const NotificationIndicator({super.key, required this.value});

  final String? value;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (value != null)
          Transform.translate(
            offset: const Offset(-18, -10),
            child: TextBadge(value: value!),
          ),
        const Icon(
          Icons.notifications,
          color: Color(0xFF50555C),
          size: 30,
        ),
      ],
    );
  }
}

class TextBadge extends StatelessWidget {
  const TextBadge({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: const ShapeDecoration(
        shape: StadiumBorder(),
        color: Colors.red,
      ),
      child: Text(
        value,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class PageWithBackground extends StatelessWidget {
  const PageWithBackground({
    Key? key,
    required this.background,
    required this.child,
  }) : super(key: key);

  final Widget background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [background, child],
    );
  }
}

class PageWithBackgroundImage extends PageWithBackground {
  PageWithBackgroundImage({super.key, required Widget child, required String path})
      : super(
          child: child,
          background: Image.asset(
            path,
            alignment: Alignment.bottomCenter,
            fit: BoxFit.cover,
          ),
        );
}

// class FacebookSignOnButton extends StatelessWidget {
//   const FacebookSignOnButton({super.key, required this.onPressed});
//
//   final VoidCallback onPressed;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: AspectRatio(
//         aspectRatio: 6.2,
//         child: Container(
//           decoration: BoxDecoration(
//             color: const Color(0xFF2474f2),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           child: Row(
//             children: [
//               Image.asset("assets/images/f_logo_white_512.png"),
//               const SizedBox(width: 15),
//               Expanded(
//                 child: FractionallySizedBox(
//                   heightFactor: 0.65,
//                   child: FittedBox(
//                     fit: BoxFit.contain,
//                     child: Text(
//                       // "Continue with Facebook",
//                       AppLocalizations.of(context)!.nN_030,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                       // style: GoogleFonts.mon,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 15),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
class FacebookSignOnButton extends StatelessWidget {
  const FacebookSignOnButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SocialButton(
      onPressed: onPressed,
      color: Colors.white,
      icon: Image.asset(
        "assets/images/f_logo_RGB-Blue_58.png",
        fit: BoxFit.cover,
      ),
      // text: "Continue with Facebook",
      text: AppLocalizations.of(context)!.nN_030,
      foregroundColor: Colors.black,
    );

    return GestureDetector(
      onTap: onPressed,
      child: AspectRatio(
        aspectRatio: 6.2,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2474f2),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Image.asset("assets/images/f_logo_white_512.png"),
              const SizedBox(width: 15),
              Expanded(
                child: FractionallySizedBox(
                  heightFactor: 0.65,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      // "Continue with Facebook",
                      AppLocalizations.of(context)!.nN_030,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      // style: GoogleFonts.mon,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class GoogleSignOnButton extends StatelessWidget {
  const GoogleSignOnButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SocialButton(
      onPressed: onPressed,
      color: Colors.white,
      icon: Image.asset(
        "assets/images/g_logo_white_512.png",
        fit: BoxFit.cover,
      ),
      // text: "Continue with Google",
      text: AppLocalizations.of(context)!.nN_031,
      foregroundColor: Colors.black,
    );
  }
}

class AppleSignOnButton extends StatelessWidget {
  const AppleSignOnButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SocialButton(
      onPressed: onPressed,
      color: Colors.white,
      icon: const Padding(
        padding: EdgeInsets.only(top: 2, bottom: 5),
        child: AspectRatio(
          aspectRatio: 0.85,
          child: CustomPaint(
            painter: AppleLogoPainter(
              color: Colors.black,
            ),
          ),
        ),
      ),
      // text: "Continue with Apple",
      text: AppLocalizations.of(context)!.nN_1059,
      foregroundColor: Colors.black,
    );
  }
}

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.onPressed,
    required this.color,
    required this.foregroundColor,
    required this.text,
    required this.icon,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.height = 50,
  });

  final VoidCallback onPressed;
  final BorderRadius borderRadius;
  final double height;
  final Color color;
  final Color foregroundColor;
  final String text;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black12),
          borderRadius: borderRadius,
          color: color,
        ),
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: icon,
              ),
              const SizedBox(width: 5),
              Text(
                text,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: foregroundColor,
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

Future<Source?> showSourceSelector(BuildContext context) =>
    showDialog(context: context, barrierColor: Colors.black12, builder: (context) => const SourceSelector());

class SourceSelector extends StatelessWidget {
  const SourceSelector({Key? key}) : super(key: key);

  Widget buildItem(BuildContext context, Source source) {
    switch (source) {
      case Source.camera:
        return SourceSelectorItem(
          icon: const Icon(Icons.camera_alt_outlined),
          // text: "Camera",
          text: AppLocalizations.of(context)!.nN_1060,
        );
      case Source.gallery:
        return SourceSelectorItem(
          icon: const Icon(Icons.photo_size_select_actual_outlined),
          // text: "Photo & Video Library",
          text: AppLocalizations.of(context)!.nN_1061,
        );
      case Source.files:
        return SourceSelectorItem(
          icon: const Icon(Icons.folder_outlined),
          // text: "Documents",
          text: AppLocalizations.of(context)!.nN_1062,
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.black26,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.5),
            child: ListView(
              clipBehavior: Clip.antiAlias,
              shrinkWrap: true,
              children: Source.values
                  .map(
                    (source) => RawMaterialButton(
                      onPressed: () => Navigator.of(context).pop(source),
                      child: buildItem(context, source),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: FilledButton(
            onPressed: Navigator.of(context).pop,
            style: ButtonStyle(
              visualDensity: VisualDensity.standard,
              minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
              backgroundColor: MaterialStateProperty.all(AppColors.red),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            // child: const Text("Cancel"),
            child: Text(AppLocalizations.of(context)!.nN_161),
          ),
        )
      ],
    );
  }
}

class SourceSelectorItem extends StatelessWidget {
  const SourceSelectorItem({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [icon, const SizedBox(width: 15), Text(text, style: Theme.of(context).textTheme.button)],
      ),
    );
  }
}
