import 'package:flutter/material.dart';
import '../../l10n.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../ui.dart';

class ProductsUnderCategoryView extends StatefulWidget {
  const ProductsUnderCategoryView({super.key, required this.category});

  final ProductCategoryDto category;

  @override
  State<ProductsUnderCategoryView> createState() => _ProductsUnderCategoryViewState();
}

class _ProductsUnderCategoryViewState extends State<ProductsUnderCategoryView> {
  String filterValue = "";

  setFilter(String value) {
    setState(() {
      filterValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder(
        future: locate<RestService>().getProductsByCategory(widget.category.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text(snapshot.error.toString());
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFECECEC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          cursorColor: Colors.red,
                          onChanged: (value) => setFilter(value),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            // hintText: 'SEARCH PRODUCTS',
                            hintText: AppLocalizations.of(context)!.nN_198.toUpperCase(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.category.name ?? "N/A",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              // const _CartIndicator(),
              if (snapshot.hasData && snapshot.data!.isEmpty)
                Expanded(
                  child: Center(
                    // "There are no products to show here"
                    child: Text(AppLocalizations.of(context)!.nN_1077),
                  ),
                ),
              if (snapshot.hasData && snapshot.data!.isNotEmpty)
                Expanded(
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    childAspectRatio: .75,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    children: (snapshot.data ?? [])
                        .where((item) => (item.name ?? "").toLowerCase().contains(filterValue.toLowerCase()))
                        .map((item) => ProductItemCard(
                              slot1: item.name ?? "N/A",
                              slot2: item.productDescription ?? "N/A",
                              slot3: item.mobileImage ?? "N/A",
                              onAdd: () {
                                if (locate<ListenablePermissionService>().request(['toAddItems'])) {
                                  locate<DraftCartHandler>().addItem(item);
                                }
                              },
                              onSelect: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProductView(product: item),
                                ),
                              ),
                              isOnFlashSale: locate<FlashSaleValueNotifier>().isOnFlashSale(item),
                            ))
                        .toList(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
