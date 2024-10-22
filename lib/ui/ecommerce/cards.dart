import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../l10n.dart';

class ProductItemCard extends StatelessWidget {
  const ProductItemCard(
      {super.key,
      required this.slot1,
      required this.slot2,
      required this.slot3,
      required this.onAdd,
      required this.onSelect,
      this.isOnFlashSale = false});

  final bool isOnFlashSale;

  /// Title
  final String slot1;

  /// Subtitle
  final String slot2;

  /// Image url
  final String slot3;

  final Function() onAdd;
  final Function() onSelect;

  Widget buildControl(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 10,
        ),
        color: const Color(0xFFEE1C25),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
              ),
              const SizedBox(width: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppLocalizations.of(context)!.nN_201,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        GestureDetector(
          onTap: onSelect,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(15),
            ),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Image.network(
                      slot3,
                      fit: BoxFit.contain,
                      errorBuilder: (context, _, __) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      slot1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      slot2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 5),
                  buildControl(context),
                ],
              ),
            ),
          ),
        ),
        if (isOnFlashSale)
          Align(
            alignment: Alignment.topRight,
            child: Transform.translate(
              offset: const Offset(20, -20),
              child: FractionallySizedBox(
                widthFactor: .5,
                child: Image.asset(
                  "assets/images/flash_sale_badge.png",
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ProductCartItemCard extends StatelessWidget {
  const ProductCartItemCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.actualPrice,
    required this.quantity,
    required this.onChange,
    required this.onRemove,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final String price;

  /// Price without any discount
  final String actualPrice;
  final int quantity;
  final Function(int) onChange;
  final Function() onRemove;

  handleAdd() {
    int nextQuantity = quantity + 1;
    onChange(nextQuantity);
  }

  handleReduce() {
    int nextQuantity = quantity - 1;
    if (nextQuantity < 1) return;
    onChange(nextQuantity);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 4,
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, _, __) => const SizedBox.shrink(),
              ),
            ),
          ),
          Flexible(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              subtitle,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onRemove,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(CupertinoIcons.delete),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CountEditor(
                        onAdd: handleAdd,
                        onReduce: handleReduce,
                        value: quantity,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.bottomRight,
                          child: Text(
                            actualPrice,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFEE1C25),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CountEditor extends StatelessWidget {
  const CountEditor({
    super.key,
    required this.value,
    required this.onAdd,
    required this.onReduce,
  });

  final int value;
  final Function() onAdd;
  final Function() onReduce;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onReduce,
          child: Container(
            height: 40,
            width: 40,
            decoration: ShapeDecoration(
              shape: const CircleBorder(),
              color: Colors.white,
              shadows: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 3,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: const Icon(
              Icons.remove,
              color: Colors.black38,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(value.toString()),
        ),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            height: 40,
            width: 40,
            decoration: ShapeDecoration(
              shape: const CircleBorder(),
              color: Colors.white,
              shadows: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 3,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Colors.black38,
            ),
          ),
        ),
      ],
    );
  }
}
