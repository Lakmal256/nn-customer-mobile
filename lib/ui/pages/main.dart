import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nawa_niwasa/router.dart';
import '../../l10n.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../../ui/ui.dart';

class AppPageWithAppbarAndBottomBar extends StatelessWidget {
  const AppPageWithAppbarAndBottomBar({
    Key? key,
    required this.child,
    this.overrideAppBarVisibility = false,
  }) : super(key: key);

  final Widget child;
  final bool overrideAppBarVisibility;

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? header;

    if (overrideAppBarVisibility || GoRouter.of(context).location != "/store") {
      header = const AppBarWithNotifications(canGoBack: false);
    }

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: header,
        bottomNavigationBar: const AppBottomNavigationBar(),
        body: child,
      ),
    );
  }
}

class PageWithAppBar extends StatelessWidget {
  const PageWithAppBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    var appBar = const AppBarWithNotifications(canGoBack: false);
    return Material(
      child: SafeArea(
        child: Column(
          children: [
            SizedBox.fromSize(
              size: appBar.preferredSize,
              child: appBar,
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class AppPageWithBottomBar extends StatelessWidget {
  const AppPageWithBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class AppBottomNavigationBar extends StatefulWidget {
  const AppBottomNavigationBar({super.key});

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GoRouter.of(context).routeInformationProvider,
      builder: (context, snapshot) {
        return Container(
          // height: 70,
          color: const Color(0xFFF0F0F0),
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppBottomBarItem(
                  // title: "Home",
                  title: AppLocalizations.of(context)!.nN_1020,
                  icon: Icons.home_outlined,
                  isSelected: GoRouter.of(context).location == AppRoutes.launcher,
                  onSelect: () {
                    if (locate<ListenablePermissionService>().request(['toViewLauncher'])) {
                      GoRouter.of(context).go(AppRoutes.launcher);
                    }
                  },
                ),
                AppBottomBarItem(
                  // title: "Store",
                  title: AppLocalizations.of(context)!.nN_1021,
                  icon: Icons.storefront_outlined,
                  isSelected: GoRouter.of(context).location == AppRoutes.store,
                  onSelect: () {
                    if (locate<ListenablePermissionService>().request(['toViewShop'])) {
                      GoRouter.of(context).go(AppRoutes.store);
                    }
                  },
                ),
                AppBottomBarItem(
                  // title: "Cart",
                  title: AppLocalizations.of(context)!.nN_1022,
                  icon: Icons.shopping_cart_outlined,
                  isSelected: GoRouter.of(context).location == AppRoutes.cart,
                  badge: const CartItemCountObserverView(),
                  onSelect: () {
                    if (locate<ListenablePermissionService>().request(['toViewCart'])) {
                      GoRouter.of(context).go(AppRoutes.cart);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CartItemCountObserverView extends StatelessWidget {
  const CartItemCountObserverView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: locate<DraftCartHandler>(),
      builder: (context, _) {
        int count = locate<DraftCartHandler>().items.length;
        if (count < 1) return const SizedBox.shrink();
        return _TextBadge(value: count.toString());
      },
    );
  }
}

class _TextBadge extends StatelessWidget {
  const _TextBadge({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: const ShapeDecoration(
        shape: StadiumBorder(),
        color: Colors.red,
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 10,
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class AppBottomBarItem extends StatelessWidget {
  const AppBottomBarItem({
    super.key,
    required this.title,
    required this.icon,
    this.isSelected = false,
    required this.onSelect,
    this.badge,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final void Function() onSelect;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    Color color = isSelected ? Colors.white : const Color(0xFF727375);

    Widget child = Icon(icon, color: color);

    if (isSelected) {
      child = Container(
        padding: const EdgeInsets.all(7.5),
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
          color: AppColors.red,
          shape: BoxShape.circle,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: child,
        ),
      );
    }

    if (badge != null) {
      child = Stack(
        clipBehavior: Clip.none,
        fit: StackFit.passthrough,
        children: [
          child,
          Positioned(
            top: -5,
            right: -5,
            child: badge!,
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onSelect,
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        tween: Tween(begin: 0.0, end: isSelected ? 1 : 0),
        builder: (context, snapshot, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform(
                transform: Matrix4.identity()
                  ..scale(1 + snapshot * 1.2)
                  ..translate(snapshot * (-8.8), snapshot * -20),
                child: SizedBox.square(
                  dimension: 32,
                  child: child,
                ),
              ),
              Transform.translate(
                offset: Offset(0, snapshot * -5),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
