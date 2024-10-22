import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nawa_niwasa/ui/ecommerce/map.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n.dart';
import '/ui/ecommerce/promo.dart';
import '/ui/ui.dart';
import '/util/num.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../locator.dart';
import '../../service/service.dart';

class StandaloneCheckoutView extends StatefulWidget {
  const StandaloneCheckoutView({super.key});

  @override
  State<StandaloneCheckoutView> createState() => _StandaloneCheckoutViewState();
}

class _StandaloneCheckoutViewState extends State<StandaloneCheckoutView> {
  late Future<void> future;
  late CartResponseDto summary;
  late int? orderId;
  bool isUserAgreedToTnC = false;

  @override
  initState() {
    locate<UserLocationService>().addListener(fetchCartDetails);
    future = fetchOrderSummary();
    super.initState();
  }

  fetchOrderSummary() async {
    var locationData = locate<UserLocationService>().value;
    var orderId = (await locate<RestService>().getDraftedCart()).id;
    summary = await locate<RestService>().getOrderSummary(
      orderId!,
      address: locationData?.address,
      latitude: locationData?.latitude.toString(),
      longitude: locationData?.longitude.toString(),
    );
    return;
  }

  fetchCartDetails() {
    setState(() {
      future = fetchOrderSummary();
    });
  }

  handlePromotionView() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Material(child: PromotionView(order: summary));
    }));
    fetchCartDetails();
  }

  handleTnCToggle(bool value) {
    setState(() {
      isUserAgreedToTnC = value;
    });
  }

  handlePlaceOrder(BuildContext context) async {
    try {
      var sessionData = await locate<RestService>().getPaymentSession(summary.id!);
      var webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {},
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith(locate<LocatorConfig>().paymentRedirectUrl)) {
                Navigator.of(context, rootNavigator: true).pop(Uri.tryParse(request.url));
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..setOnConsoleMessage((message) {
          if (kDebugMode) {
            print(message.message);
          }
        })
        ..loadHtmlString(sessionData, baseUrl: locate<LocatorConfig>().paymentGatewayEndpoint);

      if (context.mounted) {
        Uri? uri = await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => WebViewPage(controller: webViewController),
          ),
        );

        if (uri == null) return;

        var refNumber = uri.queryParameters["refNumber"];

        /// var resultIndicator = uri.queryParameters["resultIndicator"];
        /// var sessionVersion = uri.queryParameters["sessionVersion"];
        /// var checkoutVersion = uri.queryParameters["checkoutVersion"];
        await locate<RestService>().closePaymentSession(refNumber!);
        if (context.mounted) {
          await locate<DraftCartHandler>().sync();
          if (context.mounted) GoRouter.of(context).go("/store");
          return;
        }
      }
    } catch (err) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Something went wrong",
          subtitle: "Sorry, something went wrong here",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    }
  }

  Widget buildPromoWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sell_sharp,
            color: Colors.black,
          ),
          const SizedBox(width: 10),
          Text(
            // "Promotions available",
            AppLocalizations.of(context)!.nN_1042,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: handlePromotionView,
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              backgroundColor: MaterialStatePropertyAll(Color(0xFFD9D9D9)),
            ),
            child: Text(
              // "Add",
              AppLocalizations.of(context)!.nN_1043,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: LocationHeader(),
        ),
        Expanded(
          child: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              final currency = AppLocalizations.of(context)!.nN_204;
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));

              var data = summary;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: CheckoutView(
                        items: data.products
                            .map((item) => CheckoutItem(
                                  product: item.product,
                                  quantity: item.quantity,
                                  total: item.totalPriceWithDiscount,
                                ))
                            .toList(),
                        promoSlot: buildPromoWidget(context),
                        receiptBottomItems: [
                          ReceiptBottomItem(
                            // title: "Items Total",
                            title: AppLocalizations.of(context)!.nN_225,
                            value: "$currency: ${data.itemTotal.toCurrency()}",
                          ),
                          ReceiptBottomItem(
                            // title: "Handling Charges:",
                            title: AppLocalizations.of(context)!.nN_226,
                            value: "$currency: ${data.dHandlingCharge.toCurrency()}",
                          ),
                          if (data.dDeliveryCharge > 0.0)
                            ReceiptBottomItem(
                              // title: "Delivery Charge:",
                              title: AppLocalizations.of(context)!.nN_227,
                              value: "$currency: ${data.dDeliveryCharge.toCurrency()}",
                            ),
                          if (data.appliedPromotionTypes.contains(PromotionType.generalDiscount))
                            ReceiptBottomItem(
                              // title: "General Promotion",
                              title: AppLocalizations.of(context)!.nN_1044,
                              value: "- $currency: ${data.generalPromotionTotal.toCurrency()}",
                            ),
                          if (data.appliedPromotionTypes.contains(PromotionType.code))
                            ReceiptBottomItem(
                              // title: "Promo Code Promotion",
                              title: AppLocalizations.of(context)!.nN_1045,
                              value: "- $currency: ${data.discountTotal.toCurrency()}",
                            ),
                          if (data.appliedPromotionTypes.contains(PromotionType.limitedTime))
                            ReceiptBottomItem(
                              // title: "Limited Time Offers",
                              title: AppLocalizations.of(context)!.nN_1046,
                              value: "- $currency: ${data.limitedTimeOfferTotal.toCurrency()}",
                            ),
                          if (data.appliedPromotionTypes.contains(PromotionType.bundles))
                            ReceiptBottomItem(
                              // title: "Bundle Offers",
                              title: AppLocalizations.of(context)!.nN_1047,
                              value: "- $currency: ${data.bundleProductTotal.toCurrency()}",
                            ),
                        ],
                        total: summary.totalPayment,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.black12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StandaloneTnCForm(
                            value: isUserAgreedToTnC,
                            onToggle: handleTnCToggle,
                          ),
                          const SizedBox(height: 10),
                          FilledButton(
                            onPressed: isUserAgreedToTnC ? () => handlePlaceOrder(context) : null,
                            style: const ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(Color(0xFFEE1C25)),
                              visualDensity: VisualDensity.standard,
                              padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 20)),
                            ),
                            // child: const Text("PLACE ORDER"),
                            child: Text(AppLocalizations.of(context)!.nN_230.toUpperCase()),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Image.asset('assets/images/payment-gateway-banner.jpeg'),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    locate<UserLocationService>().removeListener(fetchCartDetails);
    super.dispose();
  }
}

class StandaloneTnCForm extends StatelessWidget {
  const StandaloneTnCForm({super.key, required this.onToggle, required this.value});

  final bool value;
  final void Function(bool) onToggle;

  handleTnCLink() async {
    await launchUrl(Uri.https(locate<LocatorConfig>().webBaseUrl, '/htmls/terms-and-conditions.html'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 10),
      decoration: const BoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Checkbox(
            value: value,
            onChanged: (_) => onToggle(!value),
          ),
          const SizedBox(width: 10),
          RichText(
            maxLines: 1,
            text: TextSpan(
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    overflow: TextOverflow.ellipsis,
                  ),
              children: [
                TextSpan(
                  // text: 'I accept the ',
                  text: AppLocalizations.of(context)!.nN_1048,
                ),
                TextSpan(
                  // text: 'Terms and Conditions',
                  text: AppLocalizations.of(context)!.nN_1049,
                  recognizer: TapGestureRecognizer()..onTap = handleTnCLink,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.red,
                        decoration: TextDecoration.underline,
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

class LocationHeader extends StatefulWidget {
  const LocationHeader({super.key});

  @override
  State<LocationHeader> createState() => _LocationHeaderState();
}

class _LocationHeaderState extends State<LocationHeader> {
  late Future future;

  @override
  initState() {
    future = getDeviceLocation();
    super.initState();
  }

  getDeviceLocation() async {
    if (locate<UserLocationService>().value == null) {
      await locate<DeviceLocationService>().requestServicePermission();
      await locate<DeviceLocationService>().requestLocationPermission();
      final ld = await locate<DeviceLocationService>().location;
      final response = await locate<ReverseGeocodingService>().getAddress("${ld.latitude},${ld.longitude}");
      locate<UserLocationService>().value = UserLocationData(latitude: ld.latitude!, longitude: ld.longitude!)
        ..address = response.formattedAddress;
    }
    return;
  }

  handleLocationChange() async {
    var locationData = locate<UserLocationService>().value;

    if (locationData == null) return;

    final LatLng? data = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return LocationSelector(
          // title: "Delivery Location",
          title: AppLocalizations.of(context)!.nN_1050,
          initialPosition: LatLng(locationData.latitude, locationData.longitude),
          onDone: (coordinates) => Navigator.of(context).pop(coordinates),
        );
      }),
    );

    if (data == null) return;

    final response = await locate<ReverseGeocodingService>().getAddress("${data.latitude},${data.longitude}");
    locate<UserLocationService>().value = UserLocationData(latitude: data.latitude, longitude: data.longitude)
      ..address = response.formattedAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFEEEEEE),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Text(
            // "Delivery Location",
            AppLocalizations.of(context)!.nN_1050,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 5),
        FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }
            return const SizedBox.shrink();
          },
        ),
        ValueListenableBuilder(
          valueListenable: locate<UserLocationService>(),
          builder: (context, snapshot, child) {
            if (snapshot?.address == null) {
              return const SizedBox.shrink();
            }

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEEEEEE),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.black),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Deliver to • ${locate<UserService>().value?.data.displayName}"),
                              Text(
                                snapshot?.address ?? "N/A",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  OutlinedButton(
                    onPressed: handleLocationChange,
                    style: const ButtonStyle(
                      shape: MaterialStatePropertyAll(StadiumBorder()),
                    ),
                    // child: const Text("Change"),
                    child: Text(AppLocalizations.of(context)!.nN_1051),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class CheckoutItem {
  final ProductDto product;
  final int quantity;
  final double total;

  CheckoutItem({required this.product, this.quantity = 1, required this.total});
}

class ReceiptBottomItem {
  final String title;
  final String value;

  ReceiptBottomItem({required this.title, required this.value});
}

class CheckoutView extends StatelessWidget {
  const CheckoutView({
    super.key,
    required this.items,
    required this.total,
    required this.promoSlot,
    required this.receiptBottomItems,
  });

  final List<CheckoutItem> items;
  final Widget promoSlot;
  final List<ReceiptBottomItem> receiptBottomItems;
  final double total;

  Widget buildFooterSubItem(BuildContext context, String title, String value) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black38,
            ),
          ),
        ),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FixedColumnWidth(70),
              1: FlexColumnWidth(4),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(2),
              4: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEEEEE),
                  ),
                  children: [
                    const SizedBox(height: 50),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          // "Product Name",
                          AppLocalizations.of(context)!.nN_221,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          // "Qty",
                          AppLocalizations.of(context)!.nN_205,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          // "Price",
                          AppLocalizations.of(context)!.nN_222,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          // "Total",
                          AppLocalizations.of(context)!.nN_223,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ]),
              ...items
                  .map((item) => TableRow(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 1,
                              color: Color(0xFFE8E8E8),
                            ),
                          ),
                        ),
                        children: [
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: SizedBox.square(
                              dimension: 70,
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Image.network(item.product.mobileImage ?? ""),
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Text(
                              item.product.name ?? "N/A",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Text(item.quantity.toString()),
                            ),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Text("${item.product.price?.toCurrency()}"),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Text(
                              item.total.toCurrency(),
                              style: const TextStyle(color: Color(0xFFEE1C25)),
                            ),
                          ),
                        ],
                      ))
                  .toList(),
            ],
          ),
          promoSlot,
          const Divider(color: Color(0xFFE8E8E8), height: 1),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                ...receiptBottomItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: buildFooterSubItem(context, item.title, item.value),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Text(
                        // "Total Payment:",
                        AppLocalizations.of(context)!.nN_229,
                        style: const TextStyle(
                          color: Colors.black38,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Text(
                        "${AppLocalizations.of(context)!.nN_204}: ${total.toCurrency()}",
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEE1C25),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
