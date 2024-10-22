import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:nawa_niwasa/locator.dart';
import 'package:pinput/pinput.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../l10n.dart';
import '../../service/service.dart';
import '../ui.dart';

class ProductView extends StatefulWidget {
  const ProductView({super.key, required this.product});
  final ProductDto product;

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> with SingleTickerProviderStateMixin {
  TextEditingController qtyTextEditingController = TextEditingController(text: "1");
  late TabController tabController;
  late String quantity;
  String? qtyError;

  @override
  void initState() {
    locate<RestService>().updateTimeStamp(widget.product.id!);
    tabController = TabController(length: 5, vsync: this);
    super.initState();
  }

  bool validate() {
    setState(() => qtyError = null);
    int? qty = int.tryParse(qtyTextEditingController.value.text);

    if (qty != null && qty > 0) return true;

    setState(() => qtyError = "Quantity cannot be empty");
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final currency = AppLocalizations.of(context)!.nN_204;
    var discountAmount = locate<FlashSaleValueNotifier>().getDiscountAmount(widget.product);
    if (!locate<FlashSaleValueNotifier>().isOnFlashSale(widget.product)) {
      discountAmount = 0.0;
    }
    var price = (widget.product.price ?? 0.0) - discountAmount;
    return Material(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: AspectRatio(
                aspectRatio: 1.2,
                child: SizedBox(
                  child: Image.network(
                    widget.product.mobileImage ?? "",
                    errorBuilder: (context, _, __) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name ?? "N/A",
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.product.productDescription ?? "N/A",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (price != widget.product.price)
                        Text(
                          "$currency : ${widget.product.price}",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(decoration: TextDecoration.lineThrough, color: Colors.black38),
                        ),
                      Text(
                        "$currency : $price",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFEE1C25),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  FilteringTextInputFormatter.deny(RegExp(r'^0')),
                ],
                controller: qtyTextEditingController,
                decoration: InputDecoration(
                  errorText: qtyError,
                  // label: const Text("Quantity"),
                  label: Text(AppLocalizations.of(context)!.nN_1041),
                ),
                onChanged: (value) {
                  setState(() => qtyError = null);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: _PillButton(
                onAddToCart: () {
                  if (locate<ListenablePermissionService>().request(['toAddItems']) && validate()) {
                    locate<DraftCartHandler>().addItem(
                      widget.product,
                      qty: int.tryParse(qtyTextEditingController.value.text) ?? 1,
                    );
                  }
                },
                onBuyNow: () {
                  if (locate<ListenablePermissionService>().request(['toBuyItems']) && validate()) {
                    int? qty = int.parse(qtyTextEditingController.value.text);
                    locate<DraftCartHandler>().addItem(widget.product, qty: qty);
                    GoRouter.of(context).go("/cart");
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Visibility(
              visible: widget.product.detailsFilePath != null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: OutlinedButton(
                  style: const ButtonStyle(
                    alignment: Alignment.center,
                    shape: MaterialStatePropertyAll(StadiumBorder())
                  ),
                  onPressed: () {
                    launchUrl(Uri.parse(widget.product.detailsFilePath!), mode: LaunchMode.externalApplication);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.download),
                      const SizedBox(width: 10),
                      Text(AppLocalizations.of(context)!.nN_1079),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: tabController,
              builder: (context, child) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: LineBorderTab(
                        // title: "Description",
                        title: AppLocalizations.of(context)!.nN_208,
                        isActive: tabController.index == 0,
                        onSelect: () => tabController.animateTo(0),
                      ),
                    ),
                    Expanded(
                      child: LineBorderTab(
                        // title: "Fact File",
                        title: AppLocalizations.of(context)!.nN_209,
                        isActive: tabController.index == 1,
                        onSelect: () => tabController.animateTo(1),
                      ),
                    ),
                    Expanded(
                      child: LineBorderTab(
                        // title: "Properties",
                        title: AppLocalizations.of(context)!.nN_210,
                        isActive: tabController.index == 2,
                        onSelect: () => tabController.animateTo(2),
                      ),
                    ),
                    Expanded(
                      child: LineBorderTab(
                        // title: "Compatibility",
                        title: AppLocalizations.of(context)!.nN_211,
                        isActive: tabController.index == 3,
                        onSelect: () => tabController.animateTo(3),
                      ),
                    ),
                    Expanded(
                      child: LineBorderTab(
                        // title: "Applications",
                        title: AppLocalizations.of(context)!.nN_212,
                        isActive: tabController.index == 4,
                        onSelect: () => tabController.animateTo(4),
                      ),
                    ),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: SizedBox(
                height: 500,
                child: TabBarView(
                  controller: tabController,
                  children: [
                    Text(widget.product.description ?? "N/A"),
                    Text(widget.product.factFile ?? "N/A"),
                    Text(widget.product.properties ?? "N/A"),
                    Text(widget.product.compatibility ?? "N/A"),
                    Text(widget.product.applications ?? "N/A"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    qtyTextEditingController.dispose();
    super.dispose();
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({super.key, required this.onAddToCart, required this.onBuyNow});

  final Function() onAddToCart;
  final Function() onBuyNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        shape: StadiumBorder(
          side: BorderSide(
            // width: 1,
            strokeAlign: 0,
            color: Color(0xFFEE1C25),
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onAddToCart,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 15),
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: Color(0xFFEE1C25),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          // "Add to cart",
                          AppLocalizations.of(context)!.nN_201,
                          style: const TextStyle(
                            color: Color(0xFFEE1C25),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: onBuyNow,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                  alignment: Alignment.center,
                  color: const Color(0xFFEE1C25),
                  child: Text(
                    // "Buy Now",
                    AppLocalizations.of(context)!.nN_206,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
