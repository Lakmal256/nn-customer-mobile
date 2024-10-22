import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nawa_niwasa/locator.dart';
import 'package:nawa_niwasa/service/service.dart';

import '../../l10n.dart';
import '../ui.dart';

class PromotionView extends StatefulWidget {
  const PromotionView({super.key, required this.order});

  final CartResponseDto order;

  @override
  State<PromotionView> createState() => _PromotionViewState();
}

class _PromotionViewState extends State<PromotionView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              IconButton(
                onPressed: Navigator.of(context).pop,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Text(
                // "PROMOTIONS",
                AppLocalizations.of(context)!.nN_228.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: StandalonePromoCodeCard(
            order: widget.order,
            onDone: Navigator.of(context).pop,
          ),
        ),
        const SizedBox(height: 10),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: StandalonePromotionList(
              order: widget.order,
            ),
          ),
        ),
      ],
    );
  }
}

class StandalonePromotionList extends StatefulWidget {
  const StandalonePromotionList({super.key, required this.order});

  final CartResponseDto order;

  @override
  State<StandalonePromotionList> createState() => _StandalonePromotionListState();
}

class _StandalonePromotionListState extends State<StandalonePromotionList> {
  Future<List<PromotionDto>>? future;

  @override
  void initState() {
    future = locate<RestService>().getAllApplicablePromotions();
    super.initState();
  }

  handleApply(BuildContext context, PromotionDto item) async {
    if (await locate<RestService>().applyPromotion(widget.order.id!, item.id!)) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Successful",
          subtitle: "Promotion was successfully applied",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } else {
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

    setState(() {
      future = locate<RestService>().getAllApplicablePromotions();
    });
    return;
  }

  Widget buildCard(BuildContext context, PromotionDto item) {
    DateFormat format = DateFormat('EEE, MMMM d h:mm a');
    String getTitle() => switch (item.type) {
          PromotionType.freeShipping => "Free Shipping",
          PromotionType.bundles => "Bundle Offer",
          PromotionType.generalDiscount => "Discount",
          PromotionType.limitedTime => "Limited Time Offer",
          _ => "Promotion",
        };
    String threshold = item.threshold != null ? '(up to LKR ${item.threshold})' : '';
    String getSubTitle() => switch (item.type) {
          PromotionType.freeShipping => "Get free shipping",
          PromotionType.bundles => "${item.percentageValue}% off $threshold",
          PromotionType.generalDiscount => "${item.percentageValue}% off $threshold",
          PromotionType.limitedTime => "Limited time offer",
          _ => "Promotion",
        };
    return DiscountCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            getTitle(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            getSubTitle(),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (item.endDate != null)
            Text(
              // getBody(),
              "Use by ${format.format(item.endDate!)}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () => handleApply(context, item),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFEE1C25),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              child: Text(
                // "Apply",
                AppLocalizations.of(context)!.nN_234,
                style: const TextStyle(
                  color: Color(0xFFEE1C25),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (snapshot.hasData) {
          var items = snapshot.data!
              .where((element) => element.isActive)
              .where((element) => element.type != PromotionType.code)
              .toList();
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (context, i) => buildCard(context, items[i]),
            separatorBuilder: (context, _) => const SizedBox(height: 10),
            itemCount: items.length,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class StandalonePromoCodeCard extends StatefulWidget {
  const StandalonePromoCodeCard({
    super.key,
    required this.onDone,
    required this.order,
  });

  final CartResponseDto order;
  final Function() onDone;

  @override
  State<StandalonePromoCodeCard> createState() => _StandalonePromoCodeCardState();
}

class _StandalonePromoCodeCardState extends State<StandalonePromoCodeCard> {
  late TextEditingController controller = TextEditingController();
  List<PromoCodeDto> promoCodes = [];
  Future? future;

  @override
  void initState() {
    fetchAllPromoCodes();
    super.initState();
  }

  bool validate() {
    var value = controller.text;
    var isContains = promoCodes.any((code) => code.promoCode == value);
    return isContains && value != "";
  }

  List<PromoCodeDto> filterPromoCodes(List<PromoCodeDto> list) {
    return list

        /// filter all active codes
        .where((code) => code.isActive)

        /// Check if products assigned to promo code are in the cart
        .where(
          (code) => code.products.any(
            (codeProduct) => widget.order.products
                .where(
                  (cartProduct) => cartProduct.product.id == codeProduct.id,
                )
                .isNotEmpty,
          ),
        )
        .toList();
  }

  fetchAllPromoCodes() async {
    setState(() {
      future = () async {
        var allCodes = await locate<RestService>().getAllPromoCodes();
        promoCodes = filterPromoCodes(allCodes);
        return;
      }.call();
    });
  }

  handleCode() async {
    var value = controller.text;
    var codes = promoCodes.where((c0) => c0.promoCode == value);
    if (codes.isNotEmpty) {
      var code = codes.first;
      if(DateTime.now().isAfter(code.endDate!)){
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Promo code has expired",
            subtitle: "Please check the validity and try again",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
        return;
      }

      if (await locate<RestService>().applyPromoCode(widget.order.id!, value)) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Successful",
            subtitle: "Promo code was successfully applied",
            color: Colors.green,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
        controller.clear();
        widget.onDone();
      }

      return;
    }

    locate<PopupController>().addItemFor(
      DismissiblePopup(
        title: "Invalid Promo Code",
        subtitle: "Sorry, Promo code is not valid",
        color: Colors.red,
        onDismiss: (self) => locate<PopupController>().removeItem(self),
      ),
      const Duration(seconds: 5),
    );

    return;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        return DiscountCardContainer(
          progressIndicator: snapshot.connectionState == ConnectionState.waiting,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Promotion",
                // AppLocalizations.of(context)!.nN_235,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  // hintText: "Enter promo code",
                  hintText: AppLocalizations.of(context)!.nN_235,
                  isDense: true,
                  filled: true,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(
                    Icons.sell_sharp,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: ValueListenableBuilder(
                  valueListenable: controller,
                  child: Text(
                    // "Apply",
                    AppLocalizations.of(context)!.nN_234,
                    style: const TextStyle(
                      color: Color(0xFFEE1C25),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  builder: (context, value, child) {
                    var isValid = validate();
                    return Opacity(
                      opacity: isValid ? 1.0 : 0.5,
                      child: TextButton(
                        onPressed: isValid ? handleCode : null,
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFFEE1C25),
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DiscountCardContainer extends StatelessWidget {
  const DiscountCardContainer({super.key, required this.child, this.progressIndicator = false});

  final Widget child;
  final bool progressIndicator;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.black54),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (progressIndicator) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
