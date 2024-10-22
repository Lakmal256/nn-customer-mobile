import 'package:flutter/material.dart';
import 'package:nawa_niwasa/util/num.dart';
import '../../l10n.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../../ui/ui.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  void initState() {
    locate<DraftCartHandler>().sync();
    super.initState();
  }

  handleCheckout() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StandaloneCheckoutView(),
      ),
    );
  }

  Widget buildEmptyIndicator(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          color: Colors.orangeAccent,
          size: 50,
        ),
        const SizedBox(height: 10),
        Text(
          // "Your Cart is Empty",
          AppLocalizations.of(context)!.nN_1063,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          // "Your shopping cart is currently empty. Start adding items now to fill it up!",
          AppLocalizations.of(context)!.nN_1064,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = AppLocalizations.of(context)!.nN_204;
    return Material(
      child: ListenableBuilder(
        listenable: locate<DraftCartHandler>(),
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (locate<DraftCartHandler>().status == CartStatus.busy) const LinearProgressIndicator(),
              if (locate<DraftCartHandler>().items.isEmpty) Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: buildEmptyIndicator(context),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => locate<DraftCartHandler>().sync(),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    children: locate<DraftCartHandler>()
                        .items
                        .map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: ProductCartItemCard(
                                title: item.product.name ?? "N/A",
                                subtitle: item.product.productDescription ?? "N/A",
                                actualPrice: "$currency : ${item.totalPrice.toCurrency()}",
                                price: "$currency : ${item.totalPriceWithDiscount.toCurrency()}",
                                quantity: item.quantity,
                                imageUrl: item.product.mobileImage ?? "",
                                onChange: (value) => locate<DraftCartHandler>().setItemQuantityDebounced(item, value),
                                onRemove: () => locate<DraftCartHandler>().removeItem(item),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // "Total amount:",
                      AppLocalizations.of(context)!.nN_214,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black38,
                      ),
                    ),
                    Text(
                      "$currency : ${locate<DraftCartHandler>().total}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEE1C25),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: FilledButton(
                  onPressed: locate<DraftCartHandler>().items.isEmpty ? null : handleCheckout,
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Color(0xFFEE1C25)),
                    visualDensity: VisualDensity.standard,
                    padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 20)),
                  ),
                  // child: const Text("CHECK OUT"),
                  child: Text(AppLocalizations.of(context)!.nN_220.toUpperCase()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
