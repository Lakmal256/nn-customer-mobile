import 'package:get_it/get_it.dart';
import 'service/service.dart';

import 'ui/ui.dart';

GetIt getIt = GetIt.instance;

class LocatorConfig {
  LocatorConfig({
    required this.authority,
    this.pathPrefix,
    required this.imageBaseUrl,
    required this.paymentRedirectUrl,
    required this.paymentGatewayEndpoint,
    required this.webBaseUrl,
    required this.weatherApiKey,
    required this.googleMapApiKey,
    required this.googlePlacesApiKey,
    required this.googleClientId,
  });

  final String authority;

  final String? pathPrefix;

  final String imageBaseUrl;

  final String paymentRedirectUrl;

  final String paymentGatewayEndpoint;

  /// Insee web url
  /// using this to get pages like T&c
  final String webBaseUrl;

  final String weatherApiKey;

  final String googleMapApiKey;

  final String googlePlacesApiKey;

  final String googleClientId;
}

setupServiceLocator(LocatorConfig config) async {
  /// To access locator config as a singleton
  getIt.registerSingleton(config);

  final authSessionEventHandler = AuthSessionShockerEventHandler();
  final authService = RestAuthService(
    config: RestAuthServiceConfig(
      authority: config.authority,
      pathPrefix: config.pathPrefix,
    ),
  )..setEventHandler(authSessionEventHandler);

  final restService = RestService(
    authService: authService,
    config: RestServiceConfig(
      authority: config.authority,
      pathPrefix: config.pathPrefix,
      weatherApiKey: config.weatherApiKey,
    ),
  );

  getIt.registerSingleton(authService);
  getIt.registerSingleton(authSessionEventHandler);
  getIt.registerSingleton(restService);
  getIt.registerSingleton(UserService(null));

  final PermissionService permissionService = PermissionService();
  getIt.registerSingleton(permissionService);
  /// Primary use for router rebuild notifier
  getIt.registerSingleton(ListenablePermissionService(permissionService));

  final AppPreference preference = AppPreference();
  getIt.registerSingleton(preference);

  /// UI
  getIt.registerSingleton(PopupController());
  getIt.registerSingleton(AppLocaleHandler(null, preference: preference));
  getIt.registerLazySingleton(() => ProgressIndicatorController());

  /// Data
  getIt.registerSingleton(BuildersValueNotifier(BuildersDataStore([])));
  getIt.registerSingleton(BuilderJobTypesValueNotifier([]));
  getIt.registerSingleton(MyJobPostsValueNotifier(MyJobPostsStore(data: [])));
  getIt.registerSingleton(ProductsDataValueNotifier(ProductsDataStore.empty()));
  getIt.registerSingleton(FlashSaleValueNotifier(FlashSaleResponseDto.empty()));

  /// Cart
  getIt.registerSingleton(DraftCartHandler(restService: restService));

  /// In-App Notifications
  getIt.registerSingleton(InAppNotificationHandler(restService: restService));

  /// FCM Helper
  getIt.registerSingleton(CloudMessagingHelperService(restService: restService));

  /// Main Banner
  getIt.registerSingleton(BannerItemHandler(restService: restService));

  /// Location
  getIt.registerSingleton(ReverseGeocodingService(apiKey: config.googleMapApiKey));
  getIt.registerSingleton(DeviceLocationService.init());
  getIt.registerSingleton(UserLocationService(null));
}

T locate<T extends Object>() => GetIt.instance<T>();
