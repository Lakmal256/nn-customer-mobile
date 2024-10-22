import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'locator.dart';
import 'service/service.dart';
import 'ui/ui.dart';

GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey();
GlobalKey<NavigatorState> appShellNavigationKey = GlobalKey();

class AppRoutes {
  AppRoutes._();

  static const root = "/";
  static const login = "/login";
  static const home = "/home";
  static const splash = "/splash";
  static const walkthrough = "/walkthrough";
  static const locale = "/locale";
  static const launcher = "/launcher";
  static const profile = "/profile";
  static const builders = "/builders";
  static const createBoq = "/create-boq";
  static const viewAllBoq = "/view-all-boq";
  static const viewAllComplaint = "/view-all-complaint";
  static const viewAllJobs = "/view-all-jobs";
  static const technicalAssistance = "/technical-assistance";
  static const store = "/store";
  static const cart = "/cart";
  static const messages = "/messages";
  static const chat = "/chat";
  static const notification = "/notification";
}

final routerRefreshListenable = Listenable.merge([
  locate<AuthSessionShockerEventHandler>(),
  locate<ListenablePermissionService>(),
]);

GoRouter baseRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.root,
  refreshListenable: routerRefreshListenable,
  redirect: (context, state) async {
    if (!(await locate<AppLocaleHandler>().readLocate()).hasLocale) {
      return AppRoutes.locale;
    }
    if (locate<AuthSessionShockerEventHandler>().shouldAuthenticate) {
      return AppRoutes.login;
    }
    if (!locate<ListenablePermissionService>().isPermitted) {
      return AppRoutes.login;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.root,
      redirect: (context, state) => AppRoutes.login,
    ),

    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginFormStandaloneView(),
    ),

    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => SplashView(
        onDone: (hasSession) => hasSession ? context.go(AppRoutes.profile) : context.go(AppRoutes.login),
      ),
    ),

    GoRoute(
      path: AppRoutes.walkthrough,
      builder: (context, state) => SplashWalkthrough(
        onDone: () => context.go(AppRoutes.root),
      ),
    ),

    GoRoute(
      path: AppRoutes.locale,
      builder: (context, state) => SelectLocaleView(
        onDone: () => GoRouter.of(context).go(AppRoutes.root),
      ),
    ),

    ShellRoute(
      navigatorKey: appShellNavigationKey,
      builder: (context, state, child) => AppPageWithAppbarAndBottomBar(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          redirect: (context, state) => AppRoutes.launcher,
        ),

        GoRoute(
          path: AppRoutes.launcher,
          builder: (context, state) => const Launcher(),
        ),

        /// User starter page
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileView(),
        ),

        /// Builder starter page
        GoRoute(
          path: AppRoutes.builders,
          builder: (context, state) => const ViewBuildersPage(),
        ),

        /// Complaint starter page
        GoRoute(
          path: AppRoutes.viewAllComplaint,
          builder: (context, state) => const AllComplaintView(),
        ),

        /// Job starter page
        GoRoute(
          path: AppRoutes.viewAllJobs,
          builder: (context, state) => const MyJobsView(),
        ),

        /// Technical assistance starter page
        GoRoute(
          path: AppRoutes.technicalAssistance,
          builder: (context, state) => const TechnicalAssistanceView(),
        ),

        /// E-commerce starter page
        GoRoute(
          path: AppRoutes.store,
          builder: (context, state) => const ECommerceMainView(),
        ),

        GoRoute(
          path: AppRoutes.cart,
          builder: (context, state) => const CartView(),
        ),

        /// Boq
        GoRoute(
          path: AppRoutes.createBoq,
          builder: (context, state) => const BoqWizardView(),
        ),

        GoRoute(
          path: AppRoutes.viewAllBoq,
          builder: (context, state) => const AllBoqView(),
        ),

        // DM
        GoRoute(
          path: AppRoutes.messages,
          builder: (context, state) => const MyMessagesView(),
        ),

        GoRoute(
          path: AppRoutes.chat,
          builder: (context, state) => ChatView(
            id: int.tryParse(state.queryParams['id'] ?? ''),
            name: state.queryParams['name'],
          ),
        ),

        // Notification
        GoRoute(
          path: AppRoutes.notification,
          builder: (context, state) => const NotificationsView(),
        ),
      ],
    ),

    /// Dev Routes
    ShellRoute(
      builder: (context, state, child) => Showcase(page: child),
      routes: [
        GoRoute(path: "/data-test", builder: (context, state) => const DataTestPage()),
        GoRoute(path: "/map", builder: (context, state) => const MapSandboxPage()),
        GoRoute(path: "/auth-test", builder: (context, state) => const AuthSandboxPage()),
        GoRoute(path: "/form", builder: (context, state) => TestFormPage()),
        GoRoute(path: "/widgets", builder: (context, state) => const WidgetCatalog()),
        GoRoute(path: "/typography", builder: (context, state) => const TypographyCatalog()),
        GoRoute(path: "/location", builder: (context, state) => const LocationSandbox()),
      ],
    ),
  ],
);
